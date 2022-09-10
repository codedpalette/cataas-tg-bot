#!/bin/bash
yum update -y
amazon-linux-extras install docker

yum install amazon-ecr-credential-helper -y
mkdir /home/ec2-user/.docker
echo '${docker.cred_helpers}' > /home/ec2-user/.docker/config.json

systemctl enable docker
service docker start

usermod -a -G docker ec2-user
newgrp docker

export DOCKER_CONFIG=/home/ec2-user/.docker
docker run \
    --log-driver=awslogs \
    --log-opt awslogs-group=${logs.group_name} \
    --log-opt awslogs-stream=${logs.stream_name} \
    --env BOT_TOKEN=${bot_token} \
    -p ${app.port}:${app.internal_port} \
    -d --restart always \
    ${docker.image_name}