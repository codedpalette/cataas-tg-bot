#!/bin/bash
docker build -t ${registry_url}/${repo_name} .

aws ecr get-login-password --profile ${profile} | docker login --username AWS --password-stdin ${registry_url}

docker push ${registry_url}/${repo_name}