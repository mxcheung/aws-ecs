#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

echo "🚀 Create role codebuild-hello-ecs-role: $AWS_ACCOUNT_ID"
CODEBUILD_ROLE=$(aws iam create-role \
  --role-name codebuild-hello-ecs-role \
  --assume-role-policy-document file://<(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "codebuild.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)
)


echo "🚀 attach-role-policy AmazonEC2ContainerRegistryPowerUser codebuild-hello-ecs-role: $AWS_ACCOUNT_ID"

CODEBUILD_ROLE_1=$(aws iam attach-role-policy --role-name codebuild-hello-ecs-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser)

echo "🚀 attach-role-policy CloudWatchLogsFullAccess codebuild-hello-ecs-role: $AWS_ACCOUNT_ID"

CODEBUILD_ROLE_2=$(aws iam attach-role-policy --role-name codebuild-hello-ecs-role \
  --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess)

echo "🚀 attach-role-policy AWSCodeCommitReadOnly codebuild-hello-ecs-role: $AWS_ACCOUNT_ID"

CODEBUILD_ROLE_3=$(aws iam attach-role-policy --role-name codebuild-hello-ecs-role \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeCommitReadOnly)
