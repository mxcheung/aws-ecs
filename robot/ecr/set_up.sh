#!/bin/bash

REPOSITORY_URI=$(aws ecr create-repository --repository-name robot --image-tag-mutability MUTABLE --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 --output text --query 'repository.repositoryUri')

aws ecr get-login-password --region us-east-1 --profile cloud_user | docker login --username AWS --password-stdin $REPOSITORY_URI

docker pull amazonlinux:latest

docker tag amazonlinux:latest  $REPOSITORY_URI:latest

docker push  $REPOSITORY_URI:latest

