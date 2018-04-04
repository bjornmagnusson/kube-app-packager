#!/bin/sh

test () {
  echo "Testing $1"
  docker run --volumes-from configs $1 --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
}

docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp ${DOCKER_CERT_PATH}/ca.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/cert.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/key.pem configs:/cfg

APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31,prom/mysqld-exporter:v0.10.0 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=0.0.1-SNAPSHOT --env APP_NAME=mariadb"
test $APP_ENV
#docker run --volumes-from configs $APP_ENV --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=0.0.1-SNAPSHOT --env APP_NAME=mariadb"
docker run --volumes-from configs $APP_ENV --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=2.1.17 --env APP_NAME=mariadb"
docker run --volumes-from configs $APP_ENV --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
