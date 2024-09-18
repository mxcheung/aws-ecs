#!/bin/bash

response=$(aws iam create-access-key --output json)

# Extract AccessKeyId and SecretAccessKey from the response
aws_access_key_id=$(echo $response | jq -r '.AccessKey.AccessKeyId')
aws_secret_access_key=$(echo $response | jq -r '.AccessKey.SecretAccessKey')

# Print the keys to verify
echo "Access Key ID: $aws_access_key_id"
echo "Secret Access Key: $aws_secret_access_key"


aws configure set aws_access_key_id $aws_access_key_id --profile cloud_user
aws configure set aws_secret_access_key $aws_secret_access_key --profile cloud_user
aws configure set region us-east-1 --profile cloud_user
aws configure set output json --profile cloud_user
export AWS_PROFILE=cloud_user
AWS_CALLER_IDENTITY=$(aws sts get-caller-identity)
echo $AWS_CALLER_IDENTITY

