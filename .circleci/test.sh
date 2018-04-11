#!/bin/bash
CWD=${1:-.}

docker create -v /cfg --name configs alpine:3.7 /bin/true
docker cp ${DOCKER_CERT_PATH}/ca.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/cert.pem configs:/cfg
docker cp ${DOCKER_CERT_PATH}/key.pem configs:/cfg

TEST_FILES=$CWD/test/*
for test_file in $TEST_FILES; do
  echo "Found test file $test_file"
done

for test_file in $TEST_FILES; do
  if [ -d "$test_file" ]; then
    echo "$test_file is a directory, skipping"
    continue
  elif [[ ${test_file: -3} == ".sh" ]]; then
    echo "$test_file is shell script, skipping"
    continue
  fi
  echo "Testing $test_file"

  APP_ENV=""
  while read env_var; do
     APP_ENV="$APP_ENV --env $env_var"
  done < $test_file

  docker create -v /app --name app alpine:3.7 /bin/true
  if [[ ${test_file: -12} == "with_scripts" ]]; then
    docker cp $CWD/test/scripts app:/app
    docker cp $CWD/test/test_single_with_scripts_install.sh app:/app
  fi
  APP_PACKAGE_CONTAINER=$(basename $test_file)
  docker run \
    --volumes-from configs \
    $APP_ENV \
    --env DOCKER_HOST=${DOCKER_HOST} \
    --env DOCKER_TLS_VERIFY=${DOCKER_TLS_VERIFY} \
    --env DOCKER_CERT_PATH=/cfg \
    --volumes-from app \
    --name $APP_PACKAGE_CONTAINER \
  bjornmagnusson/kube-app-packager

  if [[ $? != "0" ]]; then
    echo "Test failed for $test_file"
    exit 1
  fi

  APP_NAME=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" $APP_PACKAGE_CONTAINER | grep APP_NAME | cut -d= -f2)
  APP_VERSION=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" $APP_PACKAGE_CONTAINER | grep APP_VERSION | cut -d= -f2)
  APP_PACKAGE="$APP_NAME-$APP_VERSION.tgz"
  docker cp app:/app/$APP_PACKAGE $CWD

  ls $CWD/$APP_PACKAGE
  if [[ $? != "0" ]]; then
    echo "Test failed for $test_file"
    exit 1
  fi

  echo "Validating package content"
  tar tf $CWD/$APP_PACKAGE
  mkdir $CWD/$APP_PACKAGE_CONTAINER
  echo "Unpacking package into $CWD/$APP_PACKAGE_CONTAINER"
  tar zxvf $1/$APP_PACKAGE -C $CWD/$APP_PACKAGE_CONTAINER
  cd $CWD/$APP_PACKAGE_CONTAINER

  SCRIPTS=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" $APP_PACKAGE_CONTAINER | grep SCRIPTS | cut -d= -f2)
  SCRIPTS_ARR=$(echo "$SCRIPTS" | sed "s/,/ /g")
  for SCRIPT in $SCRIPTS_ARR; do
    echo "Validating $SCRIPT exist in package"
    ls $SCRIPT
    if [[ $? != "0" ]]; then
      echo "Test failed for $test_file, failed to find $SCRIPT"
      exit 1
    fi
  done

  UNTAG_REPOSITORIES=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" $APP_PACKAGE_CONTAINER | grep UNTAG_REPOSITORIES | cut -d= -f2)
  UNTAG_REPOSITORIES_ARR=$(echo "$UNTAG_REPOSITORIES" | sed "s/,/ /g")
  if [[ $UNTAG_REPOSITORIES_ARR != "" ]]; then
    DOCKER_IMAGES=$(docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}" $APP_PACKAGE_CONTAINER | grep DOCKER_IMAGES | cut -d= -f2)
    DOCKER_IMAGES_ARR=$(echo "$DOCKER_IMAGES" | sed "s/,/ /g")
    for DOCKER_IMAGE in $DOCKER_IMAGES_ARR; do
      echo "Deleting Docker image $DOCKER_IMAGE"
      docker rmi -f $DOCKER_IMAGE
    done
  fi
  docker load --input images.tar
  for UNTAG_REPOSITORY in $UNTAG_REPOSITORIES_ARR; do
    echo "Validating repository $UNTAG_REPOSITORY has been untagged"
    docker images | grep $UNTAG_REPOSITORY
    if [[ $? != "1" ]]; then
      echo "Test failed for $test_file, failed to untag $UNTAG_REPOSITORY images"
      exit 1
    fi
  done

  echo "Cleaning up"
  rm -rf $CWD/$APP_PACKAGE $CWD/$APP_PACKAGE_CONTAINER
  docker rm app
done
