#!/bin/bash

set -e  # Exit on error

# Configuration
AWS_PROFILE="cloud_user"
AWS_REGION="us-east-1"
REPO_NAME="wordpress"

# Use profile and region
export AWS_PROFILE=$AWS_PROFILE

# Get caller identity
echo "🔍 Getting AWS identity..."
aws sts get-caller-identity --region "$AWS_REGION"

# Create or fetch ECR repository URI
echo "📦 Ensuring ECR repository '$REPO_NAME' exists..."
REPOSITORY_URI=$(aws ecr create-repository \
  --region "$AWS_REGION" \
  --repository-name "$REPO_NAME" \
  --image-tag-mutability MUTABLE \
  --image-scanning-configuration scanOnPush=true \
  --encryption-configuration encryptionType=AES256 \
  --output text \
  --query 'repository.repositoryUri' 2>/dev/null || \
  aws ecr describe-repositories \
    --region "$AWS_REGION" \
    --repository-names "$REPO_NAME" \
    --output text \
    --query 'repositories[0].repositoryUri')

echo "✅ Repository URI: $REPOSITORY_URI"

# Extract registry domain (before first slash)
REGISTRY_URI=$(echo "$REPOSITORY_URI" | cut -d'/' -f1)

# Login to ECR
echo "🔐 Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$REGISTRY_URI"

# Pull WordPress image from Docker Hub
echo "⬇️ Pulling WordPress image..."
docker pull wordpress:latest

# Tag image for ECR
echo "🏷️ Tagging image for ECR..."
docker tag wordpress:latest "$REPOSITORY_URI:latest"

# Push image to ECR
echo "🚀 Pushing image to ECR..."
docker push "$REPOSITORY_URI:latest"

echo "🎉 Done! Image pushed to $REPOSITORY_URI:latest"
