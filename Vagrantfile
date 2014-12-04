require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

Vagrant.configure("2") do |config|
  config.vm.define :localvm do |test|
  end
  config.vm.define :awsvm do |awsvm|
    awsvm.vm.hostname = "basemachine-tc"
    awsvm.vm.box = "ubuntu_aws"
    awsvm.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    awsvm.vm.provision :shell, path: "docker_container_creator.sh"
    awsvm.vm.provider :aws do |aws, override|
      aws.access_key_id = CONF["access_key_id"]
      aws.secret_access_key = CONF["secret_access_key"]
      aws.keypair_name = CONF["aws_keypair_name"]
      aws.security_groups = CONF["aws_security_groups"]
      aws.ami = "ami-014f4144"
      aws.instance_type = "m3.medium"
      aws.region = "us-west-1"
      override.ssh.username = "ubuntu"
      override.ssh.private_key_path = CONF["ssh_private_key_path"]
    end
  end
end
