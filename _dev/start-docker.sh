#!/bin/bash

set -e

SERVICE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SERVICE_NAME=$(cat ${SERVICE_DIR}/package.json | grep '"name"' | head -n1 | cut -f4 -d\")
SERVICE_VERSION=$(cat ${SERVICE_DIR}/package.json | grep '"version"' | head -n1 | cut -f4 -d\")
DOCKER_IMAGE="${SERVICE_NAME}-dev:${SERVICE_VERSION}"
DOCKER_ID="${SERVICE_NAME}-dev"

echo "DOCKER_IMAGE: ${DOCKER_IMAGE}"
docker build -t ${DOCKER_IMAGE} _dev

docker rm -f ${DOCKER_ID} || true > /dev/null 2>&1
docker run -d \
    --user $(id -u):$(id -g)\
    -p 3000 \
    -v ${SERVICE_DIR}:/workspace \
    --name ${DOCKER_ID} \
    ${DOCKER_IMAGE}

echo "==> Docker Environment Started"
echo "==> PORTS: $(docker inspect ${DOCKER_ID} | grep '"HostPort":' | cut -f4 -d\")"
docker exec -it ${DOCKER_ID} npm install
docker exec -it ${DOCKER_ID} npm run dev
