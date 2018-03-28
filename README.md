kube-app-packager
===========

kube-app-packager is responsible for packaging an Kubernetes Application in an shippable format.
Done by packaging a Helm Chart together with used Docker image into tarball
Application tarball will be available in the current directory

By default, only stable Helm repository is enabled.

Requirements
=======
- Docker
- Docker Compose

Environment Variables
===========
- HELM_CHART_REPOSITORY: Helm repository to use
- HELM_CHART_NAME: Helm chart name
- HELM_CHART_VERSION: Helm Chart version
- DOCKER_IMAGE: Docker image used in Helm Chart
- APP_NAME: Name of application to be built
- APP_VERSION: Version of application to be built

Usage
===========
Example on how to use is available in examples/ folder.

Add compose file to use for packaging (docker-compose.package.yml):
```Docker
version: '2.1'

services:
  package:
    image: bjornmagnusson/kube-app-packager
    volumes:
      - ./:/app
    environment:
    DOCKER_IMAGE: docker_image:docker_image_tag
    HELM_CHART_REPOSITORY: helm-chart-repository-name
    HELM_CHART_NAME: helm-chart-name
    HELM_CHART_VERSION: helm-chart-version
    APP_VERSION: app-version
    APP_NAME: app-name
```

Package application by running `docker-compose -f docker-compose.package.yml up --abort-on-container-exit`
