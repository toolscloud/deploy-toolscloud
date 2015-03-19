#Vagrant Docker

This project runs Docker containers in a VM using Vagrant. To run a local VM:

```{bash}
vagrant up 
```

To run an AWS instance:

```{bash}
vagrant up --provider=aws 
```

In order to be able to run the AWS instance you must create a **vagrant_config.yml** file with the following parameters:

access_key_id: "" # AWS Access Key ID
secret_access_key: "" # AWS Secret Access Key
ssh_private_key_path: "" # Location of your AWS Key pair file
aws_keypair_name: ""
aws_security_groups: [""]

as described in **vagrant_config_template.yml**
