#!/bin/bash

echo "Remove existed container"
docker rm -f web-demo
# docker-compose -f /home/ec2-user/docker-compose.yml down || true