#!/bin/sh
WORKSPACE=$1
cd $WORKSPACE
mkdir -p docker-cert
cp ${DOCKER_CERT_PATH}/* docker-cert/

docker create -v /cfg --name configs alpine:3.4 /bin/true
docker cp docker-cert/ca.pem configs:/cfg
docker cp docker-cert/cert.pem configs:/cfg
docker cp docker-cert/key.pem configs:/cfg

docker run --volumes-from configs --env DOCKER_IMAGES="mariadb:10.1.31,prom/mysqld-exporter:v0.10.0" --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION="2.1.17" --env APP_VERSION="0.0.1-SNAPSHOT" --env APP_NAME="mariadb" --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
docker run --volumes-from configs --env DOCKER_IMAGES="mariadb:10.1.31" --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION="2.1.17" --env APP_VERSION="0.0.1-SNAPSHOT" --env APP_NAME="mariadb" --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
docker run --volumes-from configs --env DOCKER_IMAGES="mariadb:10.1.31" --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION="2.1.17" --env APP_VERSION="2.1.17" --env APP_NAME="mariadb" --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
