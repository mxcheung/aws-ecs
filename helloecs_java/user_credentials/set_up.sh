#!/usr/bin/env bash

# response=$(aws iam create-access-key --output json)

# Write the response to a JSON file
# echo "$response" > access-key-response.json

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
