#!/bin/bash

sudo docker run --name=data -d -v /applications toolscloud/data

sudo docker run --name=postgresql -d \
  -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
  -v /opt/mysql/data:/var/lib/mysql \
  --volumes-from data \
  toolscloud/postgresql:latest

sudo docker run --name=redmine -d --link postgresql:postgresql \
  -p 8081:80 -p 8444:443 \
  -v /opt/redmine/data:/home/redmine/data \
  --volumes-from data \
  toolscloud/redmine:latest

sudo docker run --name='gitlab' -d --link postgresql:postgresql \
  -e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' \
  -p 10022:22 -p 8082:80 -p 8445:443 \
  --volumes-from data \
  -v /var/run/docker.sock:/run/docker.sock \
  -v $(which docker):/bin/docker \
  toolscloud/gitlab:latest
