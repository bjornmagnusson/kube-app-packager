#!/bin/bash
docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp ${DOCKER_CERT_PATH}/ca.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/cert.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/key.pem configs:/cfg

TEST_FILES=$1/test/*
for test_file in $TEST_FILES; do
  echo "Found test file $test_file"
done

for test_file in $TEST_FILES; do
  echo "Testing $test_file"

  APP_ENV=""
  while read env_var; do
     APP_ENV="$APP_ENV --env $env_var"
  done < $test_file

  docker create -v /app --name app alpine:3.7 /bin/true
  docker run \
    --volumes-from configs \
    $APP_ENV \
    --env DOCKER_HOST=${DOCKER_HOST} \
    --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} \
    --env DOCKER_CERT_PATH=/cfg \
    --volumes-from app \
    --name $(basename $test_file) \
  bjornmagnusson/kube-app-packager

  if [[ $? != "0" ]]; then
    echo "Test failed for $test_file"
    exit 1
  fi

  docker inspect $(basename $test_file)
  APP_NAME=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" multipleimages_package_1 | grep APP_NAME | cut -d= -f2)
  APP_VERSION=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" multipleimages_package_1 | grep APP_VERSION | cut -d= -f2)
  APP_PACKAGE="$APP_NAME-$APP_VERSION.tgz"
  docker cp app:/app/$APP_PACKAGE $1
  ls $1
  ls $1/$APP_PACKAGE
  if [[ $? != "0" ]]; then
    echo "Test failed for $test_file"
    exit 1
  fi
  git clean -f
  docker rm app
done
