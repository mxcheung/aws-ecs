#!/bin/bash

# Set variables
PROFILE_NAME="cloud_user"
AWS_REGION="us-east-1"

# Ensure AWS credentials are set in the environment
if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "❌ AWS_ACCESS_KEY_ID and/or AWS_SECRET_ACCESS_KEY are not set in the environment."
  exit 1
fi

# Create ~/.aws directory if it doesn't exist
mkdir -p ~/.aws

# Write to ~/.aws/credentials
cat <<EOL > ~/.aws/credentials
[$PROFILE_NAME]
aws_access_key_id = $AWS_ACCESS_KEY_ID
aws_secret_access_key = $AWS_SECRET_ACCESS_KEY
EOL

# Append session token if present
if [[ -n "$AWS_SESSION_TOKEN" ]]; then
  echo "aws_session_token = $AWS_SESSION_TOKEN" >> ~/.aws/credentials
fi

# Write to ~/.aws/config
cat <<EOL > ~/.aws/config
[profile $PROFILE_NAME]
region = $AWS_REGION
output = json
EOL

# Update ~/.bashrc to export AWS_PROFILE
if ! grep -q "export AWS_PROFILE=" ~/.bashrc; then
  echo "export AWS_PROFILE=$PROFILE_NAME" >> ~/.bashrc
else
  sed -i "s|export AWS_PROFILE=.*|export AWS_PROFILE=$PROFILE_NAME|" ~/.bashrc
fi

# Export now for current session
export AWS_PROFILE=$PROFILE_NAME

# Confirm
echo "✅ AWS profile '$PROFILE_NAME' configured using current environment variables."
aws sts get-caller-identity
