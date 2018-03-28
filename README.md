app-packager
===========

App packager is responsible for packaging an Kubernetes Application in an shippable format.
Done by packaging a Helm Chart together with docker images into tarball

Environment Variables
===========
- HELM_CHART_NAME: Helm chart name
- DOCKER_IMAGE: Docker image used in Helm Chart
- VERSION: version of Helm chart

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
      HELM_CHART_NAME: "chart"
      DOCKER_IMAGE: "chart"     
      VERSION: "1.2.3"
```

Package application by running `docker-compose -f docker-compose.package.yml up`
