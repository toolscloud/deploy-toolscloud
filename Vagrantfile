# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'

CONF = YAML::load_file("vagrant_config.yml")

Vagrant.configure("2") do |config|
  config.vm.hostname = "toolscloud-env"
  config.vm.define "localvm"
  config.vm.network "forwarded_port", guest: 443, host: 443

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.vm.provision "shell", path: "provision.sh"

  config.vm.provider "virtualbox" do |vb, override|
    override.vm.box = "ubuntu/xenial64"
    override.vm.network "private_network", ip: "192.168.33.10"

    vb.name = "toolscloud-env"
    vb.memory = 3072
    vb.cpus = 2
  end

  config.vm.provider "aws" do |aws, override|
    override.vm.box = "ubuntu_aws"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = CONF["ssh_private_key_path"]

    aws.access_key_id = CONF["access_key_id"]
    aws.secret_access_key = CONF["secret_access_key"]
    aws.keypair_name = CONF["aws_keypair_name"]
    aws.security_groups = CONF["aws_security_groups"]
    aws.ami = "ami-b09da8d0"
    aws.instance_type = "m3.medium"
    aws.region = "us-west-1"
    aws.block_device_mapping = [{
      'DeviceName' => '/dev/sda1',
      'Ebs.VolumeSize' => 20,
      'Ebs.VolumeType' => 'gp2',
      'Ebs.DeleteOnTermination' => 'true'
    }]
  end
end
