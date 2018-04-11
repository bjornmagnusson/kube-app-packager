#!/usr/bin/env bash
HELM_CHART_VERSION_FROM_ENV=${HELM_CHART_VERSION:-"N/A"}
HELM_CHART_VERSION_COMMAND=""
if [[ $HELM_CHART_VERSION_FROM_ENV != "N/A" ]]; then
  HELM_CHART_VERSION_COMMAND="--version $HELM_CHART_VERSION_FROM_ENV"
fi
echo "Packaging Kubernetes Application (chart = $HELM_CHART_NAME, chart version = $HELM_CHART_VERSION_FROM_ENV, images = $DOCKER_IMAGES)"
cd /tmp
DOCKER_IMAGES_TAR=images.tar

# fetch docker image
echo "Fetching Docker images ($DOCKER_IMAGES)"
DOCKER_IMAGES_ARR=$(echo "$DOCKER_IMAGES" | sed "s/,/ /g")
for DOCKER_IMAGE in $DOCKER_IMAGES_ARR; do
  echo "Fetching Docker image $DOCKER_IMAGE"
  docker pull $DOCKER_IMAGE
done
DOCKER_IMAGES_UNTAGGED=""
UNTAG_REPOSITORIES_ARR=$(echo "$UNTAG_REPOSITORIES" | sed "s/,/ /g")
if [[ $UNTAG_REPOSITORIES_ARR != "" ]]; then
  for DOCKER_IMAGE in $DOCKER_IMAGES_ARR; do
    DOCKER_IMAGE_UNTAGGED=$DOCKER_IMAGE
    for UNTAG_REPOSITORY in $UNTAG_REPOSITORIES_ARR; do
      if [[ $DOCKER_IMAGE == $UNTAG_REPOSITORY* ]]; then
        echo "Untagging docker image $DOCKER_IMAGE from $UNTAG_REPOSITORY"
        OFFSET=$((${#UNTAG_REPOSITORY}+1))
        LENGTH=$((${#DOCKER_IMAGE}-$OFFSET))
        DOCKER_IMAGE_UNTAGGED=${DOCKER_IMAGE:OFFSET:LENGTH}
        docker tag $DOCKER_IMAGE $DOCKER_IMAGE_UNTAGGED
        echo "Untagged into $DOCKER_IMAGE_UNTAGGED"
      fi
    done
    DOCKER_IMAGES_UNTAGGED="$DOCKER_IMAGES_UNTAGGED $DOCKER_IMAGE_UNTAGGED"
  done
else
  DOCKER_IMAGES_UNTAGGED=$DOCKER_IMAGES_ARR
fi
docker save --output $DOCKER_IMAGES_TAR $DOCKER_IMAGES_UNTAGGED
if [[ ! -f $DOCKER_IMAGES_TAR ]]; then
  echo "Failed to save $DOCKER_IMAGES_UNTAGGED to $DOCKER_IMAGES_TAR"
  exit 1
fi

# fetch helm chart
echo "Fetching Helm Chart ($HELM_CHART_NAME-$HELM_CHART_VERSION_FROM_ENV)"
helm repo update
helm fetch $HELM_CHART_REPOSITORY/$HELM_CHART_NAME $HELM_CHART_VERSION_COMMAND
if [[ $? != "0" ]]; then
  echo "Failed to fetch Helm Chart $HELM_CHART_NAME-$HELM_CHART_VERSION_FROM_ENV"
  exit 1
fi

# Scripts as array
SCRIPTS_ARR=$(echo "$SCRIPTS" | sed "s/,/ /g")
if [[ $SCRIPTS_ARR != "" ]]; then
  echo "Collecting scripts ($SCRIPTS)"
  SCRIPTS=""
  for SCRIPT in $SCRIPTS_ARR; do
    SCRIPTS="$SCRIPTS $SCRIPT"
    cp -r /app/$SCRIPT .
  done
fi

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
echo "Bundling Helm Chart, Docker images and scripts into $APPLICATION_TAR"
tar -zcf $APPLICATION_TAR $DOCKER_IMAGES_TAR $HELM_CHART_TAR $SCRIPTS
rm $DOCKER_IMAGES_TAR $HELM_CHART_TAR

ls $APPLICATION_TAR
if [[ $? != "0" ]]; then
  echo "Failed to find $APPLICATION_TAR"
  exit 1
fi
echo "Successfully packaged application $APPLICATION_NAME into $APPLICATION_TAR"
