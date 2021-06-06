#!/bin/bash

## user_data scripts automatically execute as root user,
## so, no need to use sudo
#sudo apt update -y
#sudo apt upgrade -y
#
##Install Prerequisite Packages
#sudo apt-get install curl apt-transport-https ca-certificates software-properties-common
#
##Add the Docker Repositories
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#
#sudo apt update -y
#
## install docker community edition
#apt-cache policy docker-ce
#sudo apt-get install -y docker-ce
#
#systemctl start docker
#systemctl enable docker
#
##install ansible
#echo -e " " | sudo apt-add-repository ppa:ansible/ansible
#
#sudo apt install ansible -y
#
mkdir -p /sunny/
#
cd /sunny/ || return
#
git clone https://Shashankreddysunkara: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@github.com/Shashankreddysunkara/Invideo_task_aws.git
#
## pull nginx image
##docker pull nginx:latest
cd /sunny/Invideo_task_aws/ || return

ansible-playbook prod-web.yml --tags=ansible-role-docker --vault-pass-file=vault_pass_file

ansible-playbook prod-web.yml --tags=create-role

## pull nginx-php image
#docker pull webdevops/php-nginx:ubuntu-18.04
#
## run container with port mapping - host:container
#docker run -d -p 80:80 --name nginx-php webdevops/php-nginx:ubuntu-18.04
#docker exec -it nginx-php bash -c "echo "<h1>Deployed via Terraform wih ELB</h1>" | sudo tee /var/www/html/index.html"