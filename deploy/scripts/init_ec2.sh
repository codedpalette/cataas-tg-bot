#!/bin/bash
sudo yum update
sudo yum install docker
sudo service docker start
sudo systemctl enable docker
sudo usermod -a -G docker $USER

echo ${docker_password} | docker login --username=${docker_user} --password-stdin ${docker_repository}
docker run -p ${application_port}:${application_internal_port} -d --restart always ${docker_image_name}