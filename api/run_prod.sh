#!/bin/bash
APP_NAME=mlapi
IMAGE_NAME=project
NAMESPACE=sudhrity
kubectl config use-context w255-aks

# minikube
minikube start --kubernetes-version=v1.21.7 --extra-config=apiserver.service-node-port-range=1-65535
#APP_HOST=`minikube ip`

kubectl config use-context w255-aks
az acr login --name w255mids

kubectl delete -k ${APP_NAME}/.k8s/overlays/prod

docker rmi -f ${IMAGE_NAME}
docker rmi -f ${IMAGE_FQDN}

docker build --no-cache -t ${IMAGE_NAME} ./${APP_NAME}/
 
IMAGE_PREFIX=$(az account list --all | jq '.[].user.name' | grep -i berkeley.edu | awk -F@ '{print $1}' | tr -d '"' | uniq)
ACR_DOMAIN=w255mids.azurecr.io
IMAGE_FQDN="${ACR_DOMAIN}/${IMAGE_PREFIX}/${IMAGE_NAME}"
az acr login --name w255mids


#TAG=$(echo $RANDOM | md5sum | head -c 8; echo;)
#sed "s/\[TAG\]/${TAG}/g" ${APP_NAME}/.k8s/overlays/prod/patch-deployment-lab4_copy.yaml > ${APP_NAME}/.k8s/overlays/prod/patch-deployment-lab4.yaml

TAG=latest
docker tag ${IMAGE_NAME} ${IMAGE_FQDN}:${TAG}
docker push ${IMAGE_FQDN}:${TAG}
docker pull ${IMAGE_FQDN}:${TAG}

kubectl kustomize ${APP_NAME}/.k8s/overlays/prod
kubectl apply -k ${APP_NAME}/.k8s/overlays/prod

sleep 60

kubectl get all -n sudhrity

APP_HOST=${NAMESPACE}.mids-w255.com
APP_PORT=443

# wait for the /health endpoint to return a 200 and then move on
finished=false
while ! $finished; do
    health_status=$(curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://${APP_HOST}:${APP_PORT}/health")
    if [ $health_status == "200" ]; then
        finished=true
        echo "API is ready"
    else
        echo "API not responding yet https://${APP_HOST}:${APP_PORT}/health"
        sleep 5
        # set this to avoid github action infinite loop. run.sh works locally but health check fails
        # when executed as a github action
        finished=true

    fi
done

sleep 30

# check a few endpoints and their http response
#curl -o /dev/null -s -w "%{http_code}\n" -X GET "https://${APP_HOST}:${APP_PORT}/docs"

curl -iLX 'GET' \
 'https://sudhrity.mids-w255.com/predict' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{"text": ["I love you."]}'

echo

# output and tail the logs for the container
kubectl logs -f -n ${NAMESPACE} -l app=${IMAGE_NAME}

