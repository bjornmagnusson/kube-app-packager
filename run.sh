#!/usr/bin/env bash
HELM_CHART_VERSION_FROM_ENV=${HELM_CHART_VERSION:-"N/A"}
HELM_CHART_VERSION_COMMAND=""
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  HELM_CHART_VERSION_COMMAND="--version $HELM_CHART_VERSION_FROM_ENV"
fi
echo "Packaging Kubernetes Application (chart = $HELM_CHART_NAME, chart version = $HELM_CHART_VERSION_FROM_ENV, image = $DOCKER_IMAGE)"
cd /app

DOCKER_IMAGE_TAR=image.tar

# fetch docker image
echo "Fetching Docker image $DOCKER_IMAGE"
IMAGE=$DOCKER_IMAGE
docker pull $DOCKER_IMAGE
docker save --output $DOCKER_IMAGE_TAR $DOCKER_IMAGE
if [[ ! -f $DOCKER_IMAGE_TAR ]]; then
  echo "Failed to save $DOCKER_IMAGE to $DOCKER_IMAGE_TAR"
fi

# fetch helm chart
echo "Fetching Helm Chart $HELM_CHART_NAME-$HELM_CHART_VERSION_FROM_ENV"
helm repo update
helm fetch $HELM_CHART_REPOSITORY/$HELM_CHART_NAME $HELM_CHART_VERSION_COMMAND

# package application (docker image + helm chart = app tarball)
APPLICATION_NAME=$APP_NAME
HELM_CHART_TAR=$HELM_CHART_NAME
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  APPLICATION_NAME="$APPLICATION_NAME-$APP_VERSION"
  HELM_CHART_TAR="$HELM_CHART_TAR-$HELM_CHART_VERSION_FROM_ENV"
else
  HELM_CHART_TAR="$HELM_CHART_TAR-*"
fi
HELM_CHART_TAR=$HELM_CHART_TAR.tgz
APPLICATION_TAR=$APPLICATION_NAME.tgz
echo "Bundling Helm Chart and Docker image into $APPLICATION_TAR"
tar -zcf $APPLICATION_TAR $DOCKER_IMAGE_TAR $HELM_CHART_TAR
rm $DOCKER_IMAGE_TAR $HELM_CHART_TAR

ls $APPLICATION_TAR
tar -tvf $APPLICATION_TAR
echo "Successfully packaged application $APPLICATION_NAME into $APPLICATION_TAR"
