#!/bin/bash

sudo docker run --name=mysql -d \
  -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
  -v /opt/mysql/data:/var/lib/mysql \
  sameersbn/mysql:latest

sudo docker run --name=redmine -d -p 80:80 --link mysql:mysql \
  -v /opt/redmine/data:/home/redmine/data \
  sameersbn/redmine:2.6.0-1
