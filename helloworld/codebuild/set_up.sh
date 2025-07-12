#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

echo "🚀 Create codebuild project: $AWS_ACCOUNT_ID"

CODEBUILD_PROJECT=$(aws codebuild create-project \
  --name hello-ecs-build \
  --source type=CODECOMMIT,location=https://git-codecommit.us-east-1.amazonaws.com/v1/repos/hello-ecs \
  --artifacts type=NO_ARTIFACTS \
  --environment type=LINUX_CONTAINER,computeType=BUILD_GENERAL1_SMALL,image=aws/codebuild/standard:7.0,privilegedMode=true \
  --service-role arn:aws:iam::<your-account-id>:role/codebuild-hello-ecs-role \
  --region us-east-1)
