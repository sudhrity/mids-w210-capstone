#!/bin/bash
APP_NAME=mlapi
IMAGE_NAME=project
NAMESPACE=sudhrity

kubectl config use-context minikube

# minikube
minikube start --kubernetes-version=v1.21.7 --extra-config=apiserver.service-node-port-range=1-65535
APP_HOST=`minikube ip`

kubectl config use-context minikube -n sudhrity
kubectl delete -k ${APP_NAME}/.k8s/overlays/dev 

kubectl delete service project-service -n sudhrity

eval $(minikube -p minikube docker-env)

docker rmi -f ${NAMESPACE}/${IMAGE_NAME}

docker build --no-cache -t ${NAMESPACE}/${IMAGE_NAME} ./${APP_NAME}/
 
kubectl kustomize ${APP_NAME}/.k8s/overlays/dev
kubectl apply -k ${APP_NAME}/.k8s/overlays/dev

sleep 60

kubectl get all -n sudhrity

kubectl expose deployment project --type=LoadBalancer --name=project-service -n sudhrity

#APP_URL=`minikube service list | grep http | awk -F'|' '{print $5}'`

APP_PORT=$(kubectl get service project-service -n sudhrity --output json | jq '.spec.ports[0].nodePort')

sleep 20

curl -X 'POST' \
 "${APP_HOST}:${APP_PORT}/predict" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I hate you.", "I love you."]}'

echo

curl -X 'GET' \
 "${APP_HOST}:${APP_PORT}/predict" \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I love you."]}'

echo 


