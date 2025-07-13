#!/bin/bash
set -euo pipefail

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="us-east-1"
REPO_NAME="hello-ecs"
ARTIFACT_BUCKET="codepipeline-artifacts-$AWS_ACCOUNT_ID"
BUILD_PROJECT_NAME="hello-ecs-build"
CODE_BUILD_ROLE_NAME="codebuild-hello-ecs-role"
CODE_PIPELINE_ROLE_NAME="codepipeline-hello-ecs-role"


# ──────────────── CodeBuild Role ────────────────
echo "🚀 Creating IAM Role: codebuild-hello-ecs-role"

aws iam create-role --role-name codebuild-hello-ecs-role \
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

# Attach required managed policies
CODEBUILD_POLICIES=(
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
)

for POLICY_ARN in "${CODEBUILD_POLICIES[@]}"; do
  echo "🔐 Attaching policy to codebuild-hello-ecs-role: $POLICY_ARN"
  aws iam attach-role-policy --role-name codebuild-hello-ecs-role --policy-arn "$POLICY_ARN"
done


aws iam put-role-policy \
  --role-name "${CODE_BUILD_ROLE_NAME}" \
  --policy-name CodeBuildPipelineS3Access \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"s3:GetObject\",
          \"s3:PutObject\"          
        ],
        \"Resource\": \"arn:aws:s3:::${ARTIFACT_BUCKET}/*\"
      }
    ]
  }"

# ──────────────── CodePipeline Role ────────────────
echo "🚀 Creating IAM Role: codepipeline-hello-ecs-role"

aws iam create-role --role-name codepipeline-hello-ecs-role \
  --assume-role-policy-document file://<(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "codepipeline.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
)

# Inline policy to allow CodePipeline to access CodeCommit
echo "🔐 Adding inline policy to codepipeline-hello-ecs-role for CodeCommit access"

aws iam put-role-policy \
  --role-name codepipeline-hello-ecs-role \
  --policy-name CodePipelineCodeCommitAccess \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"codecommit:GetBranch\",
          \"codecommit:GetCommit\",
          \"codecommit:UploadArchive\",
          \"codecommit:GetUploadArchiveStatus\",
          \"codecommit:CancelUploadArchive\"
        ],
        \"Resource\": \"arn:aws:codecommit:${REGION}:${AWS_ACCOUNT_ID}:${REPO_NAME}\"
      }
    ]
  }"

aws iam put-role-policy \
  --role-name codepipeline-hello-ecs-role \
  --policy-name CodePipelineS3Access \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"s3:GetObject\",
          \"s3:PutObject\",
          \"s3:ListBucket\"
        ],
        \"Resource\": [
          \"arn:aws:s3:::${ARTIFACT_BUCKET}\",
          \"arn:aws:s3:::${ARTIFACT_BUCKET}/*\"
        ]
      }
    ]
  }"

aws iam put-role-policy \
  --role-name "${CODE_PIPELINE_ROLE_NAME}" \
  --policy-name CodePipelineCodeBuildAccess \
  --policy-document "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
      {
        \"Effect\": \"Allow\",
        \"Action\": [
          \"codebuild:StartBuild\",
          \"codebuild:BatchGetBuilds\"
        ],
        \"Resource\": \"arn:aws:codebuild:${REGION}:${AWS_ACCOUNT_ID}:project/${BUILD_PROJECT_NAME}\"
      }
    ]
  }"

echo "✅ IAM roles successfully created and configured."
