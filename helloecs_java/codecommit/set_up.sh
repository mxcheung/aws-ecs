#!/usr/bin/env bash

set -euo pipefail
trap 'echo "❌ Script failed at line $LINENO. Exiting." >&2' ERR

REPO_NAME="hello-ecs"
REGION="us-east-1"
PROFILE="cloud_user"  # Your AWS profile
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text --profile "$PROFILE")

REPO_URL="https://git-codecommit.${REGION}.amazonaws.com/v1/repos/${REPO_NAME}"

# Step 1: Check if the repository exists
echo "🔍 Checking if CodeCommit repository '$REPO_NAME' exists..."
if aws codecommit get-repository --repository-name "$REPO_NAME" --region "$REGION" --profile "$PROFILE" >/dev/null 2>&1; then
  echo "✅ Repository already exists: $REPO_NAME"
else
  echo "🔧 Creating CodeCommit repository: $REPO_NAME"
  aws codecommit create-repository \
    --repository-name "$REPO_NAME" \
    --repository-description "Hello ECS Python App" \
    --region "$REGION" \
    --profile "$PROFILE"
  echo "✅ Repository created: $REPO_NAME"
fi

# Step 2: Setup project directory
echo "📁 Preparing local project directory..."
mkdir -p "$MY_ENV_DIR/hello-ecs/"
cd "$MY_ENV_DIR/hello-ecs/"
cp -r "$MY_ENV_ROOT_DIR/hello-ecs/"* .

# Step 3: Git setup and push
echo "📦 Setting up Git and pushing to remote..."

if [ ! -d ".git" ]; then
  git init
  git config user.name "YourName"
  git config user.email "your.email@example.com"
fi

git remote remove origin 2>/dev/null || true
git remote add origin "$REPO_URL"

git add .
git commit -m "Initial commit: Python ECS hello app" || echo "📝 Nothing to commit."
git push --set-upstream origin master || echo "⚠️ Git push failed (maybe no changes)."

echo "✅ Code pushed to CodeCommit: $REPO_URL"
