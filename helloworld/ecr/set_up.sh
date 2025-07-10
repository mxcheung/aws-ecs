# Variables
REPO_NAME=hello-ecs
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

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
  
