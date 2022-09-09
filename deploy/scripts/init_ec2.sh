#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker

sudo systemctl enable docker
sudo service docker start

sudo usermod -a -G docker ec2-user
newgrp docker

echo ${docker_password} | docker login --username=${docker_user} --password-stdin ${docker_repository}
docker run --env BOT_TOKEN=${bot_token} -p ${application_port}:${application_internal_port} -d --restart always ${docker_image_name}