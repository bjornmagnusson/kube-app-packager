#!/bin/bash
docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp ${DOCKER_CERT_PATH}/ca.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/cert.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/key.pem configs:/cfg

for test_file in "$1/test/test_multi_image" "$1/test/test_single_image" "$1/test/test_single_same_name"; do
  echo "Testing $test_file"
  APP_ENV=""
  while read env_var; do
     APP_ENV="$APP_ENV --env $env_var"
  done < $test_file
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
