# Deploy Toolscloud

Project to run Docker containers in a VM using Vagrant.

This project helps you to create Toolscloud environment in multiple ways.

## Table of Contents
* [ Installation ](#Installation)
  * [ Locally ](#Locally)
  * [ AWS ](#AWS)
* [ Using Toolscloud ](#Run-Toolscloud)
* [ Cleanup ](#Cleanup)

## Installation

If you already have [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) installed on your machine, you can go directly to [Using Toolscloud](#Using-Toolscloud) instead of running from a VM.

### Prerequisites

There are some prerequisites do execute the full automation of this project.

- [Vagrant](https://www.vagrantup.com/)
- [VirtualBox](https://www.virtualbox.org/)

### Locally

Execute the following commands to create the full environment.

1. Creates the initial virtual machine.
    ```bash
    vagrant up
    ```
    * Updates the OS (_Ubuntu 16.04 LTS_)
    * Install and configure Docker and Docker Compose.
    * This process may take a while to finish due to your internet connection.

2. To complete the installation process, restart the machine. The single reason is to reload the session and apply docker group to vagrant user.
    ```bash
    vagrant reload
    ```
    If you don't restart the machine, you may get and error after trying any `docker` command.
    ```
    Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.39/info: dial unix /var/run/docker.sock: connect: permission denied
    ```

3. Accessing your VM
   ```
   vagrant ssh
   ```

Some other useful commands from Vagrant:
* `vagrant status` -> check the status from your virtual machine.
* `vagrant global-status` -> check the status from *ALL* your virtual machine.
* `vagrant halt` -> turn of the machine.

### AWS

All the process is very similar comparing to the local VM. But this time you will be handling an AWS instance.

1. Differently from local VM, to provision an AWS machine it will be necessary to install a Vagrant Plugin, [vagrant-aws](https://github.com/mitchellh/vagrant-aws).
   ```bash
   vagrant plugin install vagrant-aws
   ```
   **Note for OSX Troubleshooting:** If you have just migrated to OSX 10.14.x, maybe you will face some problems regarding Vagrant Plugin installations. You can read more on this [XCode release notes](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes#3035624) and you this [GitHub Issue](https://github.com/sparklemotion/nokogiri/issues/1801). To solve this issue, you will need to execute the following command before trying to install the plugin.
   ```bash
   xcode-select --install 
   ```
   This command will popup a window asking to install XCode and to accept a software license. When it's finished, try to install the plugin again.

2. Time to execute the AWS instance.
   ```bash
   vagrant up --provider=aws 
   ```

   In order to be able to run the AWS instance you must create a `vagrant_config.yml` file, as described in `vagrant_config_template.yml`, with the following parameters:
   
   ```yaml
   access_key_id: "" # AWS Access Key ID
   secret_access_key: "" # AWS Secret Access Key
   ssh_private_key_path: "" # Location of your AWS Key pair file
   aws_keypair_name: "" # Your Key Pairs on EC2 that match your private key
   aws_security_groups: [""] # The 'default' group probably don't have SSH permission
   ```

   An example:
   ```yaml
   access_key_id: "ABCDEF1234567ABCD123"
   secret_access_key: "sometHingbigwithnumbers423ANdlotsOfWOrds"
   ssh_private_key_path: "~/.ssh/id_rsa_username"
   aws_keypair_name: "id_rsa_username"
   aws_security_groups: [ "default", "toolscloud-service" ]
   ```

   **Important Notes about AWS configuration:**

   1. Did you set the right zone? This default configuration is using `us-west-1`.
   
   2. Does the Amazon Machine Image (AMI) exist in the selected zone? This config uses `ami-b09da8d0` located at `us-west-1`.
   
   3. Does you Key Pair is registered on the correct zone? Make sure the `aws_keypair_name` is available on the used zone, `us-west-1`.

   4. Last but not least, make sure that selected `aws_security_groups` has permission to do SSH (like the example with `toolscloud-service`).

3. If you are on a MacOSX, Vagrant will copy your DockerHub configuration to Amazon. But maybe it won't work if your Docker configuration *Securely store Docker logins in macOS keychain* is checked. If it's the case, the password is actually stored in MacOSX keystore. Docker won't give you any warning, and `docker login` will simply return. If this happens, to fix:

   a. **Inside your amazon VM**, Remove the Docker configuration file.
   ```bash
   rm ~/.docker/config.json
   ```
   b. Execute the following command to recreate the auth file.
   ```bash
   docker login
   ```

4. Different from the local VM, if you change files in your computer, they will not sync with the remote VM. To refresh files, run:
   ```bash
   vagrant rsync
   ```

## Using Toolscloud

Everything you need to provision the whole stack from Toolscloud is ready to use on `docker-compose.yml` file.

### Notes

* If you are running from Vagrant, don't forget to access the right folder before trying any of the following commands. All project's files were synced at the provisioning into `/vagrant` folder. You only need to execute `cd /vagrant` after accessing the machine via _ssh_.

* There is a `.evn` file on the project root folder that defines some variables to Docker Compose provisioning.
  * `COMPOSE_PROJECT_NAME=toolscloud` will provide the prefix `toolscloud` to all containers, volumes, and networks. 
  * `TOOLSCLOUD_BASE_FOLDER=/tc-data` will configure all toolscloud volume to `/tc-data`. If you are using Compose locally, you may need to change it. For example, in OSX, to `/home/[my-username]/tc-data`. The value `~/tc-data` doesn't work in this case.

### Docker Compose

To execute all the tools, execute:

```
docker-compose up -d
```

On the first time, it will take a while to download all the images from DockerHub. Then, this process will take only a few seconds.

IMPORTANT: Some of the tools, like Nexus, may take up to a minute to start. You can watch the logs executing `docker-compose logs -f`. The flag `-f` is to keep showing the logs. If you want to cancel, press `CTRL + C`.

#### Tips

You can start or stop containers any time you want and check containers information.

* Check all the services (containers)
  ```
  docker-compose ps
  ```
* Stopping _Jenkins_ service
  ```
  docker-compose stop jenkins
  ```
* Starting _Nexus_ service
  ```
  docker-compose start nexus
  ```
* Stop all the services
  ```
  docker-compose stop
  ```

#### Partial Execution

The whole environment is composed of 10 containers. This may be too heavy to a local machine. No worries! You can execute only the tools that you want for the moment. But keep in mind that three of those are always required: _LDAP_, _PLA_ and _Manager_. This is because all the requests are handled by the _Manager_ container and all the access handled by _LDAP_ (_PLA_ is only the way to check the LDAP's data, but it is super lightweight).

Info you want only _Jenkins_, execute:

```
docker-compose up -d ldap pla manager jenkins
```

## Cleanup

In case that you are using vagrant, you just need one command to get rid of the machine. The following command will remove permanently the whole machine (you will be asked to confirm the process, but you can force it using the flag `-f`).

```
vagrant destroy
```

To do the cleanup only with Docker Compose, maybe you will need two steps depending on what you want.

1. Remove all containers, networks, and volumes.
   ```
   docker-compose down
   ```
   If you want to remove the named volumes, type an extra flag `-v` on the command above.

2. On the current model, Toolscloud stores all the data into a folder handled by the variable `TOOLSCLOUD_BASE_FOLDER` (default: `/tc-data`). So if you want to start from scratch in the next Compose provisioning, you will need to remove this folder. **IMPORTANT: you will remove permanently all your data from Toolscloud tools. Make sure that you have backups if it's needed.**
   ```
   rm -rf /tc-data
   ```
   Note: if you set a different value to `TOOLSCLOUD_BASE_FOLDER`, make sure to type the same value above.
