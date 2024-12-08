#!/bin/bash

# Extract AccessKeyId and SecretAccessKey from the response file
aws_access_key_id=$(jq -r '.AccessKey.AccessKeyId' access-key-response.json)
aws_secret_access_key=$(jq -r '.AccessKey.SecretAccessKey' access-key-response.json)

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

