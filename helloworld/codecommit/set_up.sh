#!/bin/bash

REPO_NAME="hello-ecs"
REGION="us-east-1"
PROFILE="cloud_user"  # or your AWS profile
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile $PROFILE)


# Step 1: Create CodeCommit repo
echo "🔧 Creating CodeCommit repository: $REPO_NAME"
REPO_URL=$(aws codecommit create-repository \
  --repository-name "$REPO_NAME" \
  --repository-description "Hello ECS Python App" \
  --region $REGION \
  --profile $PROFILE || echo "✅ Repo already exists.")
    
# Step 2: Setup Git remote
REPO_URL="https://git-codecommit.$REGION.amazonaws.com/v1/repos/$REPO_NAME"


# Step 3: Prepare project files

mkdir -p $MY_ENV_DIR/hello-ecs/helloworld/hello-ecs/
cd $MY_ENV_DIR/hello-ecs/helloworld/hello-ecs/
cp -r $MY_ENV_DIR/aws-ecs/helloworld/hello-ecs/* .

# Step 4: Git init and push

if [ ! -d ".git" ]; then
  git init
  git config user.name "YourName"
  git config user.email "your.email@example.com"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"
  
git add .
git commit -m "Initial commit: Python ECS hello app"
git push --set-upstream origin main


echo "✅ Code pushed to CodeCommit: $REPO_URL"

