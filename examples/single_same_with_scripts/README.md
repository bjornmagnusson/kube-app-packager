MariaDB / Single Docker image with scripts example
======

This example will package Docker images `mariadb:10.1.31`
and Helm Chart `stable/mariadb` with version `2.1.17` together with the scripts `scripts/script2.sh` and `script1.sh`
into an tarball named `mariadb-2.1.17.tar`.

Example is using Docker-in-Docker for hosting isolated temporary Docker daemon.
This is not an requirement, any Docker daemon will work fine.

How to use
======
Package application by running `docker-compose -f docker-compose.package.yml up --abort-on-container-exit`
