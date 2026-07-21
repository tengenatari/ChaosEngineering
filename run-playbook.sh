#!/bin/bash
docker build -t ansible-runner .
docker run --rm \
  -v $(pwd):/ansible \
  -e ANSIBLE_HOST_KEY_CHECKING=False \
  ansible-runner -i hosts.ini --private-key ansible_key k3s.yml