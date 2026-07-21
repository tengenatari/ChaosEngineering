#!/bin/bash

SCENARIO=$1
NAMESPACE=${2:-harbor}
REMOTE_HOST="130.193.44.189"
SSH_KEY="ansible_key"
REMOTE_USER="ansible"
SCENARIO_FILE="cases/${SCENARIO}"

echo "Копирование файла сценария на ВМ"
scp -i $SSH_KEY -o StrictHostKeyChecking=no $SCENARIO_FILE ${REMOTE_USER}@${REMOTE_HOST}:/tmp/${SCENARIO}

echo "Запуск демонстрации на ВМ"
ssh -i $SSH_KEY -t ${REMOTE_USER}@${REMOTE_HOST} << EOF

echo "Статус подов в Harbor:"
sudo kubectl get pods -n $NAMESPACE
echo ""
echo "Сервисы в Harbor:"
sudo kubectl get svc -n $NAMESPACE

# Используем Ingress Gateway (порт 30080)
NODE_IP=\$(sudo kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
HARBOR_PORT=30080

echo ""
echo "Проверка работы ДО внедрения ошибки:"
echo "Время ответа API:"
time curl -k -s -o /dev/null -w "HTTP Status: %{http_code}\\n" http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health

echo "Время доступа к репозиториям"

curl -u admin:Harbor12345 http://10.130.0.21:30080/api/v2.0/projects/library/repositories

echo ""
echo "Детальный ответ:"
curl -k -s http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health | python3 -m json.tool 2>/dev/null || echo "Не удалось получить JSON ответ"

echo ""
echo "Внедрение ошибки"
sudo kubectl apply -f /tmp/${SCENARIO}

echo "Ожидание применения (5 секунд)"
sleep 5

echo ""
echo "Проверка работы ПОСЛЕ внедрения ошибки:"
echo "Время ответа API:"
time curl -k -s -o /dev/null -w "HTTP Status: %{http_code}\\n" http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health
echo "Время доступа к репозиториям"

curl -u admin:Harbor12345 http://10.130.0.21:30080/api/v2.0/projects/library/repositories

echo ""
echo "Детальный ответ после внедрения ошибки:"
curl -k -s http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health | python3 -m json.tool 2>/dev/null || echo "Не удалось получить JSON ответ"

echo "Откат изменений"
sudo kubectl delete -f /tmp/${SCENARIO}

echo "Ожидание отката (5 секунд)"
sleep 5

echo ""
echo "Проверка после отката:"
echo "Время ответа API (после отката):"
time curl -k -s -o /dev/null -w "HTTP Status: %{http_code}\\n" http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health

echo ""
echo "Детальный ответ после отката:"
curl -k -s http://\${NODE_IP}:\${HARBOR_PORT}/api/v2.0/health | python3 -m json.tool 2>/dev/null || echo "Не удалось получить JSON ответ"

sudo rm -f /tmp/${SCENARIO}
echo ""
echo "Конец"


EOF