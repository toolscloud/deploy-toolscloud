require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

Vagrant.configure("2") do |config|
  config.vm.hostname = "basemachine-tc"
  config.vm.box = "ubuntu_aws"
  config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
  config.vm.provision :shell, path: "docker_container_creator.sh"
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
end
