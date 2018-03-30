#!/usr/bin/env bash
HELM_CHART_VERSION_FROM_ENV=${HELM_CHART_VERSION:-"N/A"}
HELM_CHART_VERSION_COMMAND=""
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  HELM_CHART_VERSION_COMMAND="--version $HELM_CHART_VERSION_FROM_ENV"
fi
echo "Packaging Kubernetes Application (chart = $HELM_CHART_NAME, chart version = $HELM_CHART_VERSION_FROM_ENV, images = $DOCKER_IMAGES)"
cd /tmp
ls -al /app
ls -al /app/*
DOCKER_IMAGES_TAR=images.tar

# fetch docker image
echo "Fetching Docker images $DOCKER_IMAGES"
DOCKER_IMAGES_ARR=$(echo "$DOCKER_IMAGES" | sed "s/,/ /g")
for DOCKER_IMAGE in $DOCKER_IMAGES_ARR; do
  echo "Fetching Docker image $DOCKER_IMAGE"
  docker pull $DOCKER_IMAGE
done
docker save --output $DOCKER_IMAGES_TAR $DOCKER_IMAGES_ARR
if [[ ! -f $DOCKER_IMAGES_TAR ]]; then
  echo "Failed to save $DOCKER_IMAGES to $DOCKER_IMAGES_TAR"
  exit 1
fi

# fetch helm chart
echo "Fetching Helm Chart $HELM_CHART_NAME-$HELM_CHART_VERSION_FROM_ENV"
helm repo update
helm fetch $HELM_CHART_REPOSITORY/$HELM_CHART_NAME $HELM_CHART_VERSION_COMMAND

# package application (docker images + helm chart = app tarball)
APPLICATION_NAME=$APP_NAME
HELM_CHART_TAR=$HELM_CHART_NAME
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  APPLICATION_NAME="$APPLICATION_NAME-$APP_VERSION"
  HELM_CHART_TAR="$HELM_CHART_TAR-$HELM_CHART_VERSION_FROM_ENV"
else
  HELM_CHART_TAR="$HELM_CHART_TAR-*"
fi
HELM_CHART_TAR=$HELM_CHART_TAR.tgz
APPLICATION_TAR="/app/$APPLICATION_NAME.tgz"
echo "Bundling Helm Chart and Docker image into $APPLICATION_TAR"
tar -zcf $APPLICATION_TAR $DOCKER_IMAGES_TAR $HELM_CHART_TAR
rm $DOCKER_IMAGES_TAR $HELM_CHART_TAR

ls $APPLICATION_TAR
if [[ $? != "0" ]]; then
  echo "Failed to find $APPLICATION_TAR"
  exit 1
fi
tar -tvf $APPLICATION_TAR
if [[ $? != "0" ]]; then
  echo "Failed to open $APPLICATION_TAR"
fi
echo "Successfully packaged application $APPLICATION_NAME into $APPLICATION_TAR"
