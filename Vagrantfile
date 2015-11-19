require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

$createDockerFolder = <<SCRIPT
sudo mkdir -p /home/vagrant/.docker /root/.docker
chown -R vagrant:vagrant /home/vagrant/.docker
SCRIPT

$handleDockerhubKey = <<SCRIPT
sudo chmod +rw /home/vagrant/.docker/config.json
sudo cp /home/vagrant/.docker/config.json /root/.docker/config.json
SCRIPT

def docker_provision(config)
  config.vm.provision "shell", inline: $createDockerFolder
  config.vm.provision "file", source: "~/.docker/config.json", destination: "~/.docker/config.json"
  config.vm.provision "shell", inline: $handleDockerhubKey

  #image tags used at pull and run steps;
  data_tag = "1.0"
  postgresql_tag = "dev"
  redmine_tag = "dev"
  jenkins_tag = "dev"
  nexus_tag = "dev"
  sonar_tag = "dev"
  ldap_tag = "dev"
  phpldapadmin_tag = "dev"
  gitblit_tag = "dev"
  testlink_tag = "dev"
  manager_tag = "dev"
  ambassador_tag = "latest"

  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:#{data_tag}"
    d.pull_images "toolscloud/postgresql:#{postgresql_tag}"
    d.pull_images "mysql:5.6"
    d.pull_images "toolscloud/redmine:#{redmine_tag}"
    d.pull_images "toolscloud/jenkins:#{jenkins_tag}"
    d.pull_images "toolscloud/sonatype-nexus:#{nexus_tag}"
    d.pull_images "toolscloud/sonar-server:#{sonar_tag}"
    d.pull_images "toolscloud/ldap:#{ldap_tag}"
    d.pull_images "toolscloud/phpldapadmin:#{phpldapadmin_tag}"
    d.pull_images "toolscloud/gitblit:#{gitblit_tag}"
    d.pull_images "andretadeu/testlink:#{testlink_tag}"
    d.pull_images "toolscloud/manager:#{manager_tag}"
    d.pull_images "cpuguy83/docker-grand-ambassador:#{ambassador_tag}"

    d.run "ambassador", image: "cpuguy83/docker-grand-ambassador:#{ambassador_tag} \
-name ldap -name gitblit -name nexus -name jenkins -name redmine -name postgresql \
-name pla -name sonar -name testlink -name mysql \
-sock /docker.sock -wait=true -log-level=\"debug\"",
    args: "-v /var/run/docker.sock:/docker.sock"

    d.run "data", image: "toolscloud/data:#{data_tag}"

    d.run "ldap", image: "toolscloud/ldap:#{ldap_tag}",
    args: "--volumes-from data -v /applications/ldap/usr/local/etc/openldap:/usr/local/etc/openldap "

    d.run "postgresql", image: "toolscloud/postgresql:#{postgresql_tag}",
    args: "--volumes-from data \
-v /applications/postgresql/var/lib/postgresql:/var/lib/postgresql \
-v /applications/postgresql/run/postgresql:/run/postgresql"

    d.run "mysql", image: "mysql:5.6",
    args: "-e 'MYSQL_ROOT_PASSWORD=1qazxsw2Mysql' -e 'MYSQL_USER=testlink' \
-e 'MYSQL_PASSWORD=T3stL1nk151d345ikr5' -e 'MYSQL_DATABASE=testlink' \
-v /applications/mysql/etc/mysql/conf.d:/etc/mysql/conf.d \
-v /applications/mysql/var/lib/mysql:/var/lib/mysql"

    d.run "pla", image: "toolscloud/phpldapadmin:#{phpldapadmin_tag}",
    args: "--link ambassador:ldap"

    d.run "gitblit", image: "toolscloud/gitblit:#{gitblit_tag}",
    args: "-p 9418:9418 -p 29418:29418 --link ambassador:ldap"

    d.run "nexus", image: "toolscloud/sonatype-nexus:#{nexus_tag}",
    args: "-p 8080:8081 --link ambassador:ldap --volumes-from data -v /applications/nexus/opt/sonatype-work:/opt/sonatype-work"

    d.run "redmine", image: "toolscloud/redmine:#{redmine_tag}",
    args: "-p 8081:8081 -p 8444:8444 --link ambassador:postgresql --link ambassador:ldap --link ambassador:git \
-e 'DB_TYPE=postgres' -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/redmine/var/log/redmine:/var/log/redmine"

    d.run "jenkins", image: "toolscloud/jenkins:#{jenkins_tag}",
    args: "-p 50000:50000 --link ambassador:ldap --link ambassador:postgresql \
--link ambassador:git --link ambassador:nexus \
--volumes-from data -u root -v /applications/jenkins_home:/var/jenkins_home"

    d.run "sonar", image: "toolscloud/sonar-server:#{sonar_tag}",
    args: "--link ambassador:postgresql --link ambassador:ldap --link ambassador:git -e 'DBMS=postgresql'"

    d.run "testlink", image: "andretadeu/testlink:#{testlink_tag}",
    args: "--link ambassador:mysql -p 8082:80"

    d.run "manager", image: "toolscloud/manager:#{manager_tag}",
    args: "--link ambassador:postgresql --link ambassador:ldap --link ambassador:jenkins \
--link ambassador:redmine --link ambassador:nexus --link ambassador:sonar --link ambassador:git \
--link ambassador:pla --link ambassador:testlink -p 8000:80 -p 4443:443"

  end
end

Vagrant.configure("2") do |config|
  config.vm.hostname = "basemachine-tc"
  config.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.define "localvm"

  config.vm.provider "virtualbox" do |vb, override|
    vb.name = "localvm"
    vb.memory = 3072
    vb.cpus = 2

    override.vm.network "private_network", ip: "192.168.56.4"

    #manager
    override.vm.network :forwarded_port, host: 4443, guest: 4443
    override.vm.network :forwarded_port, host: 8000, guest: 8000

    #redmine
    override.vm.network :forwarded_port, host: 8081, guest: 8081
    override.vm.network :forwarded_port, host: 8444, guest: 8444

    #testlink
    override.vm.network :forwarded_port, host: 8082, guest: 8082
  end

  config.vm.provider "aws" do |aws, override|
    override.vm.box = "ubuntu_aws"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id = CONF["access_key_id"]
    aws.secret_access_key = CONF["secret_access_key"]
    aws.keypair_name = CONF["aws_keypair_name"]
    aws.security_groups = CONF["aws_security_groups"]
    aws.ami = "ami-adbeb5e8"
    aws.instance_type = "m3.medium"
    aws.region = "us-west-1"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = CONF["ssh_private_key_path"]
  end

  docker_provision(config)

end
