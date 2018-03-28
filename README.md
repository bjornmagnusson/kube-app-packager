app-packager
===========

App packager is responsible for packaging an Kubernetes Application in an shippable format.
Done by packaging a Helm Chart together with docker images into tarball

Environment Variables
===========
- HELM_CHART_NAME: Helm chart name
- HELM_CHART_REPOSITORY: Helm repository to use
- HELM_CHART_VERSION: Helm Chart version
- DOCKER_IMAGE: Docker image used in Helm Chart
- APP_VERSION: Version of application to be built
- APP_NAME: Name of application to be built

Usage
===========
Example on how to use.

Add compose file to use for deploy (docker-compose.package.yml):
```Docker
version: '2.1'

services:
  package:
    image: bjornmagnusson/kube-app-packager
    volumes:
      - ./:/helm
    environment:
    DOCKER_IMAGE: mariadb:10.1.31
    HELM_CHART_REPOSITORY: stable
    HELM_CHART_NAME: mariadb
    HELM_CHART_VERSION: 2.1.17
    APP_VERSION: 0.0.1-SNAPSHOT
    APP_NAME: "mariadb"
```

Package application by running `docker-compose -f docker-compose.package.yml up --abort-on-container-exit`
