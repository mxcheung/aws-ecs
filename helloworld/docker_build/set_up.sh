# Variables
REPO_NAME=hello-ecs
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_URI="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${REPO_NAME}"

REPOSITORY_URI=$(aws ecr describe-repositories \
  --repository-names "$REPO_NAME" \
  --query "repositories[0].repositoryUri" \
  --output text)

echo "🔗 Repository URI: $REPOSITORY_URI"

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI

# Build and push
docker build -t $REPO_NAME .
docker tag $REPO_NAME:latest $ECR_URI:latest
docker push $ECR_URI:latest
