#!/bin/sh

function test {
  docker run --volumes-from configs $1 --env DOCKER_HOST=${DOCKER_HOST} --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} --env DOCKER_CERT_PATH=/cfg bjornmagnusson/kube-app-packager
}

WORKSPACE=$1
cd $WORKSPACE
mkdir -p docker-cert
cp ${DOCKER_CERT_PATH}/* docker-cert/

docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp docker-cert/ca.pem configs:/cfg
docker cp docker-cert/cert.pem configs:/cfg
docker cp docker-cert/key.pem configs:/cfg

APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31,prom/mysqld-exporter:v0.10.0 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=0.0.1-SNAPSHOT --env APP_NAME=mariadb"
test $APP_ENV
APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=0.0.1-SNAPSHOT --env APP_NAME=mariadb"
test $APP_ENV
APP_ENV="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=2.1.17 --env APP_NAME=mariadb"
test $APP_ENV
