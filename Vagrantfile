require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

def docker_provision(config)
  config.vm.provision "shell", inline: "sudo mkdir -p /home/vagrant/.docker /root/.docker; chown -R vagrant:vagrant /home/vagrant/.docker; sudo apt-get update"
  config.vm.provision "file", source: "~/.docker/config.json", destination: "~/.docker/config.json"
  config.vm.provision "shell", inline: "sudo chmod +rw /home/vagrant/.docker/config.json"
  config.vm.provision "shell", inline: "sudo cp /home/vagrant/.docker/config.json /root/.docker/config.json"
  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:1.0"
    d.pull_images "toolscloud/postgresql:2.0"
    d.pull_images "toolscloud/redmine:2.0"
    d.pull_images "toolscloud/jenkins:2.0"
    d.pull_images "toolscloud/sonatype-nexus:1.0"
    d.pull_images "toolscloud/sonar-server:2.0"
    d.pull_images "toolscloud/ldap:2.0"
    d.pull_images "toolscloud/phpldapadmin:1.0"
    d.pull_images "toolscloud/gitblit:2.0"
    d.pull_images "toolscloud/manager:2.0"
    d.pull_images "cpuguy83/docker-grand-ambassador:latest"

    d.run "ambassador", image: "cpuguy83/docker-grand-ambassador:latest \
-name ldap -name gitblit -name nexus -name jenkins -name redmine -name postgresql \
-name pla -name sonar -sock /docker.sock -wait=true -log-level=\"debug\"",
    args: "-v /var/run/docker.sock:/docker.sock"

    d.run "data", image: "toolscloud/data:1.0"

    d.run "ldap", image: "toolscloud/ldap:2.0",
    args: "--volumes-from data -v /applications/ldap/usr/local/etc/openldap:/usr/local/etc/openldap "

    d.run "postgresql", image: "toolscloud/postgresql:2.0",
    args: "--volumes-from data \
-v /applications/postgresql/var/lib/postgresql:/var/lib/postgresql \
-v /applications/postgresql/run/postgresql:/run/postgresql"

    d.run "pla", image: "toolscloud/phpldapadmin:1.0",
    args: "--link ambassador:ldap"

    d.run "gitblit", image: "toolscloud/gitblit:2.0",
    args: "-p 9418:9418 -p 29418:29418 --link ambassador:ldap"

    d.run "nexus", image: "toolscloud/sonatype-nexus:1.0",
    args: "-p 8080:8081 --link ambassador:ldap --volumes-from data -v /applications/nexus/opt/sonatype-work:/opt/sonatype-work"

    d.run "redmine", image: "toolscloud/redmine:2.0",
    args: "-p 8081:8081 -p 8444:8444 --link ambassador:postgresql --link ambassador:ldap --link ambassador:git \
-e 'DB_TYPE=postgres' -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/redmine/var/log/redmine:/var/log/redmine"

    d.run "jenkins", image: "toolscloud/jenkins:2.0",
    args: "-p 50000:50000 --link ambassador:ldap --link ambassador:postgresql \
--link ambassador:git --link ambassador:nexus \
--volumes-from data -u root -v /applications/jenkins_home:/var/jenkins_home"

    d.run "sonar", image: "toolscloud/sonar-server:2.0",
    args: "--link ambassador:postgresql --link ambassador:ldap --link ambassador:git -e 'DBMS=postgresql'"

    d.run "manager", image: "toolscloud/manager:2.0",
    args: "--link ambassador:postgresql --link ambassador:ldap --link ambassador:jenkins \
--link ambassador:redmine --link ambassador:nexus --link ambassador:sonar --link ambassador:git \
--link ambassador:pla -p 8000:80 -p 4443:443"

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
    override.vm.network :forwarded_port, host: 4443, guest: 4443
    override.vm.network :forwarded_port, host: 8000, guest: 8000
    override.vm.network :forwarded_port, host: 8081, guest: 8081
    override.vm.network :forwarded_port, host: 8444, guest: 8444

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
