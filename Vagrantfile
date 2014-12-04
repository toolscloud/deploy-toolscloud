require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

Vagrant.configure("2") do |config|
  config.vm.hostname = "basemachine-tc"
  config.vm.box = "ubuntu_aws"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  #config.vm.provision :shell, path: "docker_container_creator.sh"
  
  config.vm.provision "docker" do |d|
    d.pull_images "toolscloud/data:latest"
    d.pull_images "toolscloud/postgresql:latest"
    d.pull_images "toolscloud/redmine:latest"
    d.pull_images "toolscloud/gitlab:latest"

    d.run "data", image: "toolscloud/data",
      args: "-v $(pwd)/applications:/applications"

    d.run "postgresql", image: "toolscloud/postgresql",
      args: "-d -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' \
-e 'DB_PASS=!AdewhmOP@12' --volumes-from data \
-v /applications/var/lib/postgresql:/applications/var/lib/postgresql \
-v /applications/run/postgresql:/applications/run/postgresql"

    d.run "redmine", image: "toolscloud/redmine",
      args: "-d --link postgresql:postgresql -p 8081:80 -p 8444:443 \
--volumes-from data -v /applications/redmine/data:/applications/redmine/data \
-v /applications/var/log/redmine:/applications/var/log/redmine"

    d.run "gitlab", image: "toolscloud/gitlab",      
      args: "-d -e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' \
--link postgresql:postgresql -p 10022:22 -p 8082:80 -p 8445:443 -volumes-from data \
-v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker"

  end

  config.vm.provider :aws do |aws, override|
    aws.access_key_id = CONF["access_key_id"]
    aws.secret_access_key = CONF["secret_access_key"]
    aws.keypair_name = "summa-cloud"
    aws.security_groups = [ "summa-cloud" ]
    aws.ami = "ami-014f4144"
    aws.instance_type = "m3.medium"
    aws.region = "us-west-1"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = CONF["ssh_private_key_path"]
  end

  config.vm.provider :virtualbox do |vb|
    config.vm.box = "vagrant_ubuntu_12.04.3_amd64_virtualbox"
    config.vm.box_url = "http://nitron-vagrant.s3-website-us-east-1.amazonaws.com/vagrant_ubuntu_12.04.3_amd64_virtualbox.box"
  end

end
