require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

Vagrant.configure("2") do |config|
  config.vm.hostname = "basemachine-tc"
  config.vm.box = "ubuntu_aws"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  #config.vm.provision :shell, path: "docker_container_creator.sh"
  
  config.vm.provision "docker" do |d|
      d.pull_images "sameersbn/mysql:latest"
      d.pull_images "sameersbn/redmine:2.6.0-1"
      d.pull_images "sameersbn/gitlab:7.5.2"

      d.run "mysql", image: "sameersbn/mysql",
        args: "-d -e 'DB_NAME=redmine_production' -e 'DB_USER=redmine' -e 'DB_PASS=!AdewhmOP@12' -v /opt/mysql/data:/var/lib/mysql"

      d.run "redmine", image: "sameersbn/redmine",
        args: "-d --link mysql:mysql -p 8081:80 -p 8444:443 -v /opt/redmine/data:/home/redmine/data"

      d.run "gitlab", image: "sameersbn/gitlab",      
        args: "-d -e 'GITLAB_PORT=8082' -e 'GITLAB_SSH_PORT=10022' -p 10022:22 -p 8082:80 -p 8445:443 -v /var/run/docker.sock:/run/docker.sock -v $(which docker):/bin/docker"

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
