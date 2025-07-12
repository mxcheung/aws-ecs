#!/bin/bash


# ──────────────── Configuration ────────────────
PROJECT_NAME="hello-ecs-build"
REPO_NAME="hello-ecs"
REGION="us-east-1"
ROLE_NAME="codebuild-hello-ecs-role"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# ──────────────── Fetch Account Info ────────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
CODECOMMIT_URL="https://git-codecommit.${REGION}.amazonaws.com/v1/repos/${REPO_NAME}"

echo "🚀 Creating CodeBuild project: ${PROJECT_NAME}"
echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"
echo "🔗 Repo URL: ${CODECOMMIT_URL}"
echo "🔐 Role: ${ROLE_ARN}"

# ──────────────── Validate Role Exists ────────────────
if ! aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "❌ IAM role ${ROLE_NAME} does not exist. Create it before proceeding."
  exit 1
fi


# ──────────────── Create CodeBuild Project ────────────────
CODEBUILD_PROJECT=$(aws codebuild create-project \
  --name "${PROJECT_NAME}" \
  --source type=CODECOMMIT,location="${CODECOMMIT_URL}" \
  --artifacts type=NO_ARTIFACTS \
  --environment type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:7.0,privilegedMode=true \
  --service-role "${ROLE_ARN}" \
  --region "${REGION}" \
  --tags key=Name,value="${PROJECT_NAME}")

echo "✅ CodeBuild project '${PROJECT_NAME}' created successfully."


# Start build and capture build ID
echo "🚀 Starting build for project: $PROJECT_NAME..."
BUILD_ID=$(aws codebuild start-build --project-name "$PROJECT_NAME" --query 'build.id' --output text)

echo "🔄 Build started: $BUILD_ID"
echo "📡 Waiting for build to complete..."

# Poll until the build shows up
until aws codebuild batch-get-builds --ids "$BUILD_ID" --query 'builds[0]' --output text >/dev/null 2>&1; do
  echo "⏳ Waiting for build to be registered..."
  sleep 3
done

# Now poll for build status
while true; do
  STATUS=$(aws codebuild batch-get-builds --ids "$BUILD_ID" --query 'builds[0].buildStatus' --output text)
  echo "🕒 Build status: $STATUS"

  if [[ "$STATUS" == "SUCCEEDED" ]]; then
    echo "✅ Build succeeded: $BUILD_ID"
    break
  elif [[ "$STATUS" =~ ^(FAILED|FAULT|TIMED_OUT|STOPPED)$ ]]; then
    echo "❌ Build failed with status: $STATUS"
    exit 1
  fi

  sleep 10
done
  
