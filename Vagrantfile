require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

def docker_provision(config)
  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:latest"
    d.pull_images "toolscloud/postgresql:latest"
    d.pull_images "sameersbn/redis:latest"
    d.pull_images "sameersbn/redmine:latest"
    d.pull_images "sameersbn/gitlab:latest"
    d.pull_images "jenkins:1.585" 
    d.pull_images "griff/sonatype-nexus:latest"
    d.pull_images "toolscloud/sonar-mysql:latest"
    d.pull_images "toolscloud/sonar-server:latest"

    d.run "data", image: "toolscloud/data"

    d.run "redis", image: "redis",
      cmd: "redis-server --appendonly yes",
      args: "--volumes-from data -v /applications/docker/data:/data"

    d.run "postgresql", image: "toolscloud/postgresql",
      args: "--volumes-from data \
-v /applications/var/lib/postgresql:/var/lib/postgresql \
-v /applications/run/postgresql:/run/postgresql"

    d.run "redis", image: "sameersbn/redis",
      args: "-v /applications/opt/redis:/var/lib/redis"

    d.run "redmine", image: "sameersbn/redmine",
      args: "--link postgresql:postgresql -p 8081:80 -p 8444:443 \
-e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' \
--volumes-from data -v /applications/redmine/data:/home/redmine/data \
-v /applications/var/log/redmine:/var/log/redmine"

    d.run "gitlab", image: "sameersbn/gitlab",      
      args: "-e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' \
--link postgresql:postgresql --link redis:redis -p 10022:22 -p 8082:80 -p 8445:443 \
--volumes-from data -v /applications/var/run/docker.sock:/run/docker.sock"

    d.run "jenkins", image: "jenkins",
      args: "-p 8083:8080 -p 5000:5000 --volumes-from data"

    d.run "nexus", image: "griff/sonatype-nexus",
      args: "-p 8084:8081 --volumes-from data -v /applications/opt/sonatype-work:/opt/sonatype-work"

    d.run "smysql", image: "toolscloud/sonar-mysql",
      args: "-p 3306:3306"

    d.run "sonar", image: "toolscloud/sonar-server",
      args: "-p 9000:9000 --link smysql:db"
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

end
