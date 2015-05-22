require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

def docker_provision(config)
  config.vm.provision "file", source: "~/.dockercfg", destination: "~/.dockercfg"
  config.vm.provision "shell", inline: "sudo cp /home/vagrant/.dockercfg /root/.dockercfg"
  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:latest"
    d.pull_images "toolscloud/postgresql:latest"
    d.pull_images "toolscloud/redmine:latest"
    d.pull_images "toolscloud/jenkins:latest" 
    d.pull_images "toolscloud/sonatype-nexus:latest"
    d.pull_images "toolscloud/sonar-server:latest"
    d.pull_images "toolscloud/ldap:latest"
    d.pull_images "toolscloud/phpldapadmin:latest"
    d.pull_images "toolscloud/gitblit:latest"
    d.pull_images "toolscloud/manager:latest"
    d.pull_images "cpuguy83/docker-grand-ambassador:latest"

    d.run "ldap_ambassador", image: "cpuguy83/docker-grand-ambassador:latest -name ldap -sock /docker.sock -wait=true -log-level=\"debug\"",
    args: "-v /var/run/docker.sock:/docker.sock"

    d.run "data", image: "toolscloud/data:latest"

    d.run "ldap", image: "toolscloud/ldap:latest",
      args: "--volumes-from data -v /applications/ldap/usr/local/etc/openldap:/usr/local/etc/openldap"

    d.run "postgresql", image: "toolscloud/postgresql:latest",
      args: "--volumes-from data \
-v /applications/postgresql/var/lib/postgresql:/var/lib/postgresql \
-v /applications/postgresql/run/postgresql:/run/postgresql"

    d.run "gitblit", image: "toolscloud/gitblit:latest",
      args: "-p 8447:443 -p 9418:9418 -p 29418:29418 --link ldap_ambassador:ldap"

    d.run "redmine", image: "toolscloud/redmine:latest",
      args: "--link postgresql:postgresql --link ldap_ambassador:ldap --link gitblit:git \
-e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/redmine/var/log/redmine:/var/log/redmine"

    d.run "nexus", image: "toolscloud/sonatype-nexus:latest",
      args: "-p 8080:8081 --link ldap_ambassador:ldap --volumes-from data -v /applications/nexus/opt/sonatype-work:/opt/sonatype-work"

    d.run "jenkins", image: "toolscloud/jenkins:latest",
      args: "-p 50000:50000 --link ldap_ambassador:ldap --link postgresql:postgresql \
--link gitblit:git --link nexus:nexus \
--volumes-from data -u root -v /applications/jenkins_home:/var/jenkins_home"

    d.run "sonar", image: "toolscloud/sonar-server:latest",
      args: "--link postgresql:db --link ldap_ambassador:ldap --link gitblit:git -e 'DBMS=postgresql'"

    d.run "pla", image: "toolscloud/phpldapadmin:latest",
    args: "--link ldap_ambassador:ldap"

    d.run "manager", image: "toolscloud/manager:latest",
      args: "--link postgresql:postgresql --link ldap_ambassador:ldap --link jenkins:jenkins \
--link redmine:redmine --link nexus:nexus --link sonar:sonar --link gitblit:git \
--link pla:pla -p 8000:80 -p 4443:443"

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
    override.vm.network :forwarded_port, host: 4443, guest: 4443
    override.vm.network :forwarded_port, host: 8000, guest: 8000
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
