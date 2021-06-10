#!/bin/bash

sudo yum update -y
sudo yum upgrade -y
mkdir /home/ec2-user/jenkins
chown -R ec2-user:ec2-user /home/ec2-user/jenkins
sudo yum install jenkins java-1.8.0-openjdk-devel -y

#install docker
sudo yum update -y
sudo amazon-linux-extras install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user
newgrp docker
docker info
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

#install docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
 docker-compose --version
 
# install terraform
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
terraform -help


#install aws
mkdir /home/ec2-user/aws_pack
cd /home/ec2-user/aws_pack
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo /home/ec2-user/aws_pack/aws/install
/home/ec2-user/aws_pack/aws/install -i /usr/local/aws-cli -b /usr/local/bin
aws --version
