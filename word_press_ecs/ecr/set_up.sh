#!/bin/bash

# Extract AccessKeyId and SecretAccessKey from environment variables
aws_access_key_id=$AWS_ACCESS_KEY_ID
aws_secret_access_key=$AWS_SECRET_ACCESS_KEY

# Print the extracted values (optional)
echo "AccessKeyId: $aws_access_key_id"
echo "SecretAccessKey: $aws_secret_access_key"

aws configure set aws_access_key_id $aws_access_key_id --profile cloud_user
aws configure set aws_secret_access_key $aws_secret_access_key --profile cloud_user
aws configure set region us-east-1 --profile cloud_user
aws configure set output json --profile cloud_user
export AWS_PROFILE=cloud_user
sleep 5
AWS_CALLER_IDENTITY=$(aws sts get-caller-identity)
echo $AWS_CALLER_IDENTITY


REPOSITORY_URI=$(aws ecr create-repository --repository-name wordpress --image-tag-mutability MUTABLE --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 --output text --query 'repository.repositoryUri')

aws ecr get-login-password --region us-east-1 --profile cloud_user | docker login --username AWS --password-stdin $REPOSITORY_URI

docker pull wordpress:latest

docker tag wordpress:latest  $REPOSITORY_URI:latest

docker push  $REPOSITORY_URI:latest

