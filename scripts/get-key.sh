#!/bin/bash

CONTAINER_NAME="k3s-cluster-nods"
HOST_PORT="2222"

docker build -t $CONTAINER_NAME .

docker rm -f $CONTAINER_NAME 2>/dev/null

docker run -d --name $CONTAINER_NAME -p $HOST_PORT:22 $CONTAINER_NAME

docker cp $CONTAINER_NAME:/home/ansible/.ssh/id_ed25519 ./ansible_key