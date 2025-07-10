# Variables
REPO_NAME=hello-ecs
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

# Create ECR repo if not exists
aws ecr create-repository --repository-name $REPO_NAME --region $AWS_REGION || true

