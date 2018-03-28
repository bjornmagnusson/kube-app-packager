#!/usr/bin/env bash
HELM_CHART_VERSION_FROM_ENV=${HELM_CHART_VERSION:-"N/A"}
HELM_CHART_VERSION_COMMAND=""
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  HELM_CHART_VERSION_COMMAND="--version $HELM_CHART_VERSION_FROM_ENV"
fi
echo "Packaging Application (chart = $HELM_CHART_NAME, chart version = $HELM_CHART_VERSION_FROM_ENV, image = $DOCKER_IMAGE)"
cd /app

# fetch dcoker image
echo "Fetching Docker image $DOCKER_IMAGE"
IMAGE=$DOCKER_IMAGE
docker pull $DOCKER_IMAGE
docker save --output image.tar $IMAGE

# fetch helm chart
echo "Fetching Helm Chart $HELM_CHART_NAME-$HELM_CHART_VERSION_FROM_ENV"
helm fetch $HELM_CHART_REPOSITORY/$HELM_CHART_NAME $HELM_CHART_VERSION_COMMAND

# package application (docker image + helm chart = app tarball)
APPLICATION_NAME=$APP_NAME
HELM_CHART_TAR="$HELM_CHART_NAME"
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  APPLICATION_NAME="$APPLICATION_NAME-$APP_VERSION"
  HELM_CHART_TAR="$HELM_CHART_TAR-$HELM_CHART_VERSION_FROM_ENV"
else
  HELM_CHART_TAR="$HELM_CHART_TAR-*"
fi
HELM_CHART_TAR="$HELM_CHART_TAR.tgz"
tar -cf $APPLICATION_NAME.tar image.tar $HELM_CHART_TAR

ls $APPLICATION_NAME.tar
tar -tvf $APPLICATION_NAME.tar
echo "Successfully packaged application $APPLICATION_NAME"
