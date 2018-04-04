#!/bin/bash
docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp ${DOCKER_CERT_PATH}/ca.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/cert.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/key.pem configs:/cfg

APP_ENV_CONCAT=""
ls -al $1/.circleci
cat $1/.circleci/test_multi_image | while read env_var
do
   APP_ENV_CONCAT="$APP_ENV_CONCAT --env $env_var"
done
echo "APP_ENV_CONCAT: $APP_ENV_CONCAT"
APP_ENV1="$APP_ENV_CONCAT"
APP_ENV2="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=0.0.1-SNAPSHOT --env APP_NAME=mariadb"
APP_ENV3="--env DOCKER_IMAGES=mariadb:10.1.31 --env HELM_CHART_REPOSITORY=stable --env HELM_CHART_NAME=mariadb --env HELM_CHART_VERSION=2.1.17 --env APP_VERSION=2.1.17 --env APP_NAME=mariadb"

for APP_ENV in "$APP_ENV1" "$APP_ENV2" "$APP_ENV3"; do
  echo "Testing $APP_ENV"
  docker run \
    --volumes-from configs \
    $APP_ENV \
    --env DOCKER_HOST=${DOCKER_HOST} \
    --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} \
    --env DOCKER_CERT_PATH=/cfg \
  bjornmagnusson/kube-app-packager
  if [[ $? != "0" ]]; then
    echo "Test failed for $APP_ENV"
    exit 1
  fi
done
