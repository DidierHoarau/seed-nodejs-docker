#!/bin/bash

set -e

SERVICE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
SERVICE_NAME=$(cat ${SERVICE_DIR}/package.json | grep '"name"' | head -n1 | cut -f4 -d\")
SERVICE_VERSION=$(cat ${SERVICE_DIR}/package.json | grep '"version"' | head -n1 | cut -f4 -d\")
CONTAINER_IMAGE="${SERVICE_NAME}-dev:${SERVICE_VERSION}"
POD_ID="${SERVICE_NAME}"
NAMESPACE=dev

docker build -t ${CONTAINER_IMAGE} _dev

kubectl create ns ${NAMESPACE} > /dev/null 2>&1 || true
kubectl -n ${NAMESPACE} delete pod --grace-period=0 --force ${POD_ID} > /dev/null 2>&1 || true
kubectl kustomize ${SERVICE_DIR}/_dev/kubernetes-template \
    | sed "s/\\\${SERVICE_NAME}/${SERVICE_NAME}/g" \
    | sed "s;\\\${SERVICE_DIR};${SERVICE_DIR};g" \
    | sed "s/\\\${CONTAINER_IMAGE}/${CONTAINER_IMAGE}/g" \
    | kubectl apply -n ${NAMESPACE} -f - 

echo "==> Docker Environment Started"
echo "==> PORTS: $(kubectl -n ${NAMESPACE} describe svc | grep NodePort | tr -s ' ' | cut -f3 -d' ')"
kubectl -n ${NAMESPACE} exec -ti ${POD_ID} -- npm install
kubectl -n ${NAMESPACE} exec -ti ${POD_ID} -- npm run dev
