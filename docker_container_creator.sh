#!/bin/bash

sudo docker run --name=mysql -d \
  -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
  -v /opt/mysql/data:/var/lib/mysql \
  sameersbn/mysql:latest

sudo docker run --name=redmine -d --link mysql:mysql \
   -p 8081:80 -p 8444:443 \
  -v /opt/redmine/data:/home/redmine/data \
  sameersbn/redmine:2.6.0-1

sudo docker run --name='gitlab' -d \
  -e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' \
  -p 10022:22 -p 8082:80 -p 8445:443 \
  -v /var/run/docker.sock:/run/docker.sock \
  -v $(which docker):/bin/docker \
  sameersbn/gitlab:7.5.2
