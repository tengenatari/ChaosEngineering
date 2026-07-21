Первый сценарий:
внесение задержки между пользователем и core API 5 секунд время ответа должно увеличиться примерно на 5 секунд
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: harbor-core-delay
  namespace: harbor
spec:
  hosts:
    - harbor-core
  http:
    - fault:
        delay:
          percentage:
            value: 100
          fixedDelay: 5s
      route:
        - destination:
            host: harbor-core
            port:
              number: 80
```
Второй сценарий:
Все запросы к API выдают 500 ошибку

```shell
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: harbor-core-abort
  namespace: harbor
spec:
  hosts:
    - "*"
  gateways:
    - harbor-gateway
  http:
    - match:
        - uri:
            prefix: /api/
      fault:
        abort:
          percentage:
            value: 100
          httpStatus: 500
      route:
        - destination:
            host: harbor-core
            port:
              number: 80
    - route:
        - destination:
            host: harbor-portal
            port:
              number: 80
```

Третий сценарий:
внесение задержки между БД 3 секунды
пуш образов будет начинаться только через 3 секунды
```yaml
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: harbor-registry-delay
  namespace: harbor
spec:
  hosts:
    - harbor-registry
  http:
    - fault:
        delay:
          percentage:
            value: 100
          fixedDelay: 3s
      route:
        - destination:
            host: harbor-registry
            port:
              number: 5000
```