require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

def docker_provision(config)
  #image tags used at pull and run steps;
  postgresql_tag = "5.0"
  redmine_tag = "ssl-5.0"
  jenkins_tag = "5.0"
  nexus_tag = "5.0"
  sonar_tag = "4.0"
  ldap_tag = "5.0"
  phpldapadmin_tag = "ssl-5.0"
  gitblit_tag = "ssl-5.0"
  testlink_tag = "ssl-5.0"
  manager_tag = "ssl-5.0"
  ambassador_tag = "latest"

  config.vm.provision "docker" do |d|
    d.pull_images "cpuguy83/docker-grand-ambassador:#{ambassador_tag}"
    d.pull_images "toolscloud/ldap:#{ldap_tag}"
    d.pull_images "toolscloud/postgresql:#{postgresql_tag}"
    d.pull_images "toolscloud/phpldapadmin:#{phpldapadmin_tag}"
    d.pull_images "toolscloud/gitblit:#{gitblit_tag}"
    d.pull_images "toolscloud/sonatype-nexus:#{nexus_tag}"
    d.pull_images "toolscloud/redmine:#{redmine_tag}"
    d.pull_images "toolscloud/jenkins:#{jenkins_tag}"
    d.pull_images "toolscloud/sonar-server:#{sonar_tag}"
    d.pull_images "toolscloud/testlink:#{testlink_tag}"
    d.pull_images "toolscloud/manager:#{manager_tag}"

    d.run "ambassador", image: "cpuguy83/docker-grand-ambassador:#{ambassador_tag} \
-name ldap -name gitblit -name nexus -name jenkins -name redmine -name postgresql \
-name pla -name sonar -name testlink -name mysql \
-sock /docker.sock -wait=true -log-level=\"debug\"",
    args: "-v /var/run/docker.sock:/docker.sock"

    d.run "ldap", image: "toolscloud/ldap:#{ldap_tag}",
    args: "-v /applications/ldap/usr/local/etc/openldap:/usr/local/etc/openldap \
-v /applications/ldap/var/lib/ldap:/var/lib/ldap"

    d.run "postgresql", image: "toolscloud/postgresql:#{postgresql_tag}",
    args: "-v /applications/postgresql/var/lib/postgresql:/var/lib/postgresql \
-v /applications/postgresql/run/postgresql:/run/postgresql"

    d.run "pla", image: "toolscloud/phpldapadmin:#{phpldapadmin_tag}",
    args: "--link ambassador:ldap"

    d.run "gitblit", image: "toolscloud/gitblit:#{gitblit_tag}",
    args: "-p 9418:9418 -p 29418:29418 --link ambassador:ldap \
-v /applications/gitblit-data:/opt/gitblit-data -p 8085:8085"

    d.run "nexus", image: "toolscloud/sonatype-nexus:#{nexus_tag}",
    args: "--link ambassador:ldap \
-v /applications/nexus/opt/sonatype-work:/opt/sonatype-work"

    d.run "redmine", image: "toolscloud/redmine:#{redmine_tag}",
    args: "--link ambassador:postgresql --link ambassador:ldap \
--link ambassador:git -e 'DB_TYPE=postgres' -e 'DB_NAME=redmine_production' \
-e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
-v /applications/redmine/data:/home/redmine/data \
-v /applications/redmine/var/log/redmine:/var/log/redmine"

    d.run "jenkins", image: "toolscloud/jenkins:#{jenkins_tag}",
    args: "-p 50000:50000 --link ambassador:ldap --link ambassador:postgresql \
--link ambassador:git --link ambassador:nexus \
-u root -v /applications/jenkins_home:/var/jenkins_home"

    d.run "sonar", image: "toolscloud/sonar-server:#{sonar_tag}",
    args: "--link ambassador:postgresql --link ambassador:ldap \
--link ambassador:git -e 'DBMS=postgresql'"

    d.run "testlink", image: "toolscloud/testlink:#{testlink_tag}",
    args: "--link ambassador:postgresql --link ambassador:ldap"

    d.run "manager", image: "toolscloud/manager:#{manager_tag}",
    args: "-v /applications/manager/var/log/apache2:/var/log/apache2 \
--link ambassador:postgresql --link ambassador:ldap --link ambassador:jenkins \
--link redmine:redmine --link ambassador:nexus --link ambassador:sonar \
--link gitblit:git --link ambassador:pla --link ambassador:testlink -p 80:80 -p 443:443"

  end
end

Vagrant.configure("2") do |config|
  config.vm.hostname = "basemachine-tc"
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.define "localvm"

  config.vm.provider "virtualbox" do |vb, override|
    config.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
    config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    vb.name = "localvm"
    vb.memory = 3072
    vb.cpus = 2

    override.vm.network "private_network", ip: "192.168.56.4"
  end

  config.vm.provider "aws" do |aws, override|
    override.vm.box = "ubuntu_aws"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    aws.access_key_id = CONF["access_key_id"]
    aws.secret_access_key = CONF["secret_access_key"]
    aws.keypair_name = CONF["aws_keypair_name"]
    aws.security_groups = CONF["aws_security_groups"]
    aws.ami = "ami-84423ae4"
    aws.instance_type = "m4.large"
    aws.region = "us-west-1"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = CONF["ssh_private_key_path"]
    aws.block_device_mapping = [{
      'DeviceName' => '/dev/sda1',
      'Ebs.VolumeSize' => 20,
      'Ebs.VolumeType' => 'gp2',
      'Ebs.DeleteOnTermination' => 'true'
    }]
  end

  docker_provision(config)

end
