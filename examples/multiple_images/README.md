MariaDB / Multiple Docker images example
======

This example will package Docker images `mariadb:10.1.31` and `prom/mysqld-exporter:v0.10.0`
and Helm Chart `stable/mariadb` with version `2.1.17`
into an tarball named `mariadb-0.0.1-SNAPSHOT.tar`.

Example is using Docker-in-Docker for hosting isolated temporary Docker daemon.
This is not an requirement, any Docker daemon will work fine.

How to use
======
Package application by running `docker-compose -f docker-compose.package.yml up --abort-on-container-exit`
