#!/bin/bash

set -e

IMAGE=$1

echo "Stopping old container..."

docker stop devops-web || true

docker rm devops-web || true

echo "Pulling latest image..."

docker pull $IMAGE

echo "Starting new container..."

docker run -d \
--restart always \
--name devops-web \
-p 80:80 \
$IMAGE

echo "Deployment Completed"
