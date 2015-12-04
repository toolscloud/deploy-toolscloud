#!/bin/bash

#image tags used at pull and run steps;
data_tag="1.0"
postgresql_tag="dev"
redmine_tag="dev"
jenkins_tag="dev"
nexus_tag="dev"
sonar_tag="dev"
ldap_tag="dev"
phpldapadmin_tag="dev"
gitblit_tag="dev"
testlink_tag="dev"
manager_tag="dev"
ambassador_tag="latest"

docker run -d --name ambassador  -v /var/run/docker.sock:/docker.sock cpuguy83/docker-grand-ambassador:${ambassador_tag} \
     -name ldap -name gitblit -name nexus -name jenkins -name redmine -name postgresql \
     -name pla -name sonar -name testlink -name mysql \
     -sock /docker.sock -wait=true -log-level="debug"

docker run -d --name data \
    -v /applications:/APP_DOCKER/applications \
    toolscloud/data:${data_tag}

docker run -d --name ldap \
    --volumes-from data -v /applications/ldap/usr/local/etc/openldap:/usr/local/etc/openldap \
    toolscloud/ldap:${ldap_tag}

docker run -d --name postgresql \
    --volumes-from data \
    -v /applications/postgresql/var/lib/postgresql:/var/lib/postgresql \
    -v /applications/postgresql/run/postgresql:/run/postgresql \
    toolscloud/postgresql:${postgresql_tag}

docker run -d --name pla \
    --link ambassador:ldap \
    toolscloud/phpldapadmin:${phpldapadmin_tag}

docker run -d --name gitblit \
    -p 9418:9418 -p 29418:29418 --link ambassador:ldap \
    toolscloud/gitblit:${gitblit_tag}

docker run -d --name nexus \
    --link ambassador:ldap --volumes-from data -v /applications/nexus/opt/sonatype-work:/opt/sonatype-work \
    toolscloud/sonatype-nexus:${nexus_tag}

docker run -d --name redmine \
    --link ambassador:postgresql --link ambassador:ldap --link ambassador:git \
    -e 'DB_TYPE=postgres' -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
    --volumes-from data -v /applications/redmine/data:/home/redmine/data \
    -v /applications/redmine/var/log/redmine:/var/log/redmine \
    toolscloud/redmine:${redmine_tag}

docker run -d --name jenkins \
    -p 50000:50000 --link ambassador:ldap --link ambassador:postgresql \
    --link ambassador:git --link ambassador:nexus \
    --volumes-from data -u root -v /applications/jenkins_home:/var/jenkins_home \
    toolscloud/jenkins:${jenkins_tag}

docker run -d --name sonar \
    --link ambassador:postgresql --link ambassador:ldap --link ambassador:git -e 'DBMS=postgresql' \
    toolscloud/sonar-server:${sonar_tag}

docker run -d --name testlink \
    --link ambassador:postgresql --link ambassador:ldap  \
    toolscloud/testlink:${testlink_tag}

docker run -d --name manager \
    -v /applications/manager/var/log/apache2:/var/log/apache2  \
    --link ambassador:postgresql --link ambassador:ldap --link ambassador:jenkins \
    --link redmine:redmine --link ambassador:nexus --link ambassador:sonar --link gitblit:git \
    --link ambassador:pla --link ambassador:testlink -p 8000:80 -p 4443:443 \
    toolscloud/manager:${manager_tag}
