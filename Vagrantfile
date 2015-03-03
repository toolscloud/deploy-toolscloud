require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

def docker_provision(config)
  config.vm.provision "file", source: "~/.dockercfg", destination: "~/.dockercfg"
  config.vm.provision "shell", inline: "sudo cp /home/vagrant/.dockercfg /root/.dockercfg"
  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:latest"
    d.pull_images "toolscloud/postgresql:latest"
    #d.pull_images "sameersbn/redis:latest"
    d.pull_images "toolscloud/redmine:latest"
    #d.pull_images "sameersbn/gitlab:latest"
    d.pull_images "jenkins:1.585" 
    d.pull_images "toolscloud/sonatype-nexus:latest"
    d.pull_images "toolscloud/sonar-server:latest"
    d.pull_images "toolscloud/ldap:latest"
    d.pull_images "toolscloud/phpldapadmin:latest"
    #d.pull_images "toolscloud/manager:latest"
    d.pull_images "toolscloud/gitblit:latest"

    d.run "data", image: "toolscloud/data"

    d.run "postgresql", image: "toolscloud/postgresql",
      args: "--volumes-from data \
-v /applications/var/lib/postgresql:/var/lib/postgresql \
-v /applications/run/postgresql:/run/postgresql"

    #d.run "redis", image: "sameersbn/redis",
    #  args: "--volumes-from data -v /applications/opt/redis:/var/lib/redis"

    d.run "redmine", image: "toolscloud/redmine",
      args: "--link postgresql:postgresql --link ldap:ldap -p 8081:80 -p 8444:443 \
-e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/var/log/redmine:/var/log/redmine"

=begin
    d.run "gitlab", image: "sameersbn/gitlab",      
      args: "-e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' \
-e 'SMTP_USER=summaemailfortest@gmail.com' -e 'SMTP_PASS=teste123' \
-e 'GITLAB_HOST=git.local.host' -e 'GITLAB_EMAIL=gitlab@local.host' \
--link postgresql:postgresql --link redis:redisio -p 10022:22 -p 8082:80 -p 8445:443 \
--volumes-from data -v /applications/var/log/gitlab:/var/log/gitlab -v /applications/home/git/data:/home/git/data"
=end

    d.run "jenkins", image: "jenkins:1.585",
      args: "-p 8083:8080 -p 5000:5000 --link ldap:ldap --volumes-from data"

    d.run "nexus", image: "toolscloud/sonatype-nexus",
      args: "-p 8084:8081 --link ldap:ldap --volumes-from data -v /applications/opt/sonatype-work:/opt/sonatype-work"

    d.run "sonar", image: "toolscloud/sonar-server",
      args: "-p 9000:9000 --link postgresql:db --link ldap:ldap -e 'DBMS=postgresql'"

    d.run "ldap", image: "toolscloud/ldap",
      args: "-p 389:389 --volumes-from data -v /applications/usr/local/etc/openldap:/usr/local/etc/openldap"

    d.run "pla", image: "toolscloud/phpldapadmin",
      args: "-p 8085:80 -p 8446:443 --link ldap:ldap"

    #d.run "manager", image: "toolscloud/manager",
    #  args: "--link postgresql:postgresql --link ldap:ldap"

    d.run "gitblit", image: "toolscloud/gitblit",
      args: "-p 8086:80 -p 8447:443 -p 9418:9418 -p 29418:29418 --link ldap:ldap"
  end
end

Vagrant.configure("2") do |config|

  config.vm.define :localvm do |test|
    test.vm.hostname = "basemachine-tc"
    test.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
    test.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

    test.vm.provider :virtualbox do |v|
      v.memory = 3072
      v.cpus = 2
    end

    docker_provision(test)

    test.vm.network :forwarded_port, host: 50000, guest: 50000
    test.vm.network :forwarded_port, host: 8081, guest: 8081
    test.vm.network :forwarded_port, host: 8082, guest: 8082
    test.vm.network :forwarded_port, host: 8083, guest: 8083
    test.vm.network :forwarded_port, host: 8084, guest: 8084
    test.vm.network :forwarded_port, host: 8085, guest: 8085
    test.vm.network :forwarded_port, host: 8086, guest: 8086
    test.vm.network :forwarded_port, host: 8444, guest: 8444
    test.vm.network :forwarded_port, host: 8445, guest: 8445
    test.vm.network :forwarded_port, host: 8446, guest: 8446
    test.vm.network :forwarded_port, host: 8447, guest: 8447
    test.vm.network :forwarded_port, host: 9000, guest: 9000
  end

  config.vm.define :awsvm do |awsvm|
    awsvm.vm.hostname = "basemachine-tc"
    awsvm.vm.box = "ubuntu_aws"
    awsvm.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    docker_provision(awsvm)

    awsvm.vm.provider :aws do |aws, override|
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
  end

  config.vm.define :localvm2 do |test2|
    test2.vm.hostname = "basemachine-tc2"
    test2.vm.box = "trusty-server-cloudimg-amd64-vagrant-disk1"
    test2.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

    test2.vm.provider :virtualbox do |v|
      v.memory = 2048
      v.cpus = 2
    end

    test2.vm.network :forwarded_port, host: 3000, guest: 3000
    test2.vm.network :forwarded_port, host: 8081, guest: 8081
    test2.vm.network :forwarded_port, host: 8082, guest: 8082
    test2.vm.network :forwarded_port, host: 8083, guest: 8083
    test2.vm.network :forwarded_port, host: 8444, guest: 8444
    test2.vm.network :forwarded_port, host: 8445, guest: 8445
    test2.vm.network :forwarded_port, host: 8446, guest: 8446
    test2.vm.network :forwarded_port, host: 9000, guest: 9000

    test2.vm.provision "file", source: "~/.dockercfg", destination: "~/.dockercfg"
    test2.vm.provision "shell", inline: "sudo cp /home/vagrant/.dockercfg /root/.dockercfg"
	test2.vm.provision "docker" do |d|
      d.pull_images "toolscloud/data:latest"
      d.pull_images "toolscloud/postgresql:latest"
      d.pull_images "toolscloud/ldap:latest"
      d.pull_images "toolscloud/redmine:latest"
      #d.pull_images "toolscloud/phpldapadmin:latest"
      #d.pull_images "toolscloud/manager:latest"
      d.pull_images "toolscloud/sonar-server"
      d.pull_images "toolscloud/gitblit:latest"

      d.run "data", image: "toolscloud/data"

      d.run "postgresql", image: "toolscloud/postgresql",
        args: "--volumes-from data \
-v /applications/var/lib/postgresql:/var/lib/postgresql \
-v /applications/run/postgresql:/run/postgresql"

      d.run "ldap", image: "toolscloud/ldap",
        args: "-p 389:389 -v /applications/usr/local/etc/openldap:/usr/local/etc/openldap"

      d.run "redmine", image: "toolscloud/redmine",
        args: "--link postgresql:postgresql --link ldap:ldap -p 8081:80 -p 8444:443 \
-e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/var/log/redmine:/var/log/redmine"

      d.run "sonar", image: "toolscloud/sonar-server",
        args: "-p 9000:9000 --link postgresql:db --link ldap:ldap -e 'DBMS=postgresql'"
=begin
      d.run "pla", image: "toolscloud/phpldapadmin",
        args: "-p 8080:80 -p 8443:443 --link ldap:ldap"

      d.run "manager", image: "toolscloud/manager",
        args: "-p 8081:80 -p 8444:443 -p 3000:3000 --link ldap:ldap"
=end
      d.run "gitblit", image: "toolscloud/gitblit",
        args: "-p 8083:80 -p 8446:443 -p 9418:9418 -p 29418:29418 --link ldap:ldap"
	end
  end
end
