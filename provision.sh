# Update
apt-get update -y

#Install Docker

# at the amazon machine, we need to uninstall existing docker to prevent some ugly warnings
sudo apt-get -yqq remove docker docker-engine docker.io containerd runc

# installing Docker (latest)
curl -fsSL https://get.docker.com/ | sh

# granting permission to run docker (may need to REBOOT)
sudo usermod -aG docker $USER

# installing Docker Compose (1.22.0)
sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose

# need to reload the session to apply docker group to vagrant user
# reboot 
