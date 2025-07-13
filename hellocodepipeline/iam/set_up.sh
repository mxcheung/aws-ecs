#!/bin/bash
set -euo pipefail

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
REGION="us-east-1"
REPO_NAME="hello-ecs"
ARTIFACT_BUCKET="codepipeline-artifacts-${AWS_ACCOUNT_ID}"
BUILD_PROJECT_NAME="hello-ecs-build"
CODE_BUILD_ROLE_NAME="codebuild-hello-ecs-role"
CODE_PIPELINE_ROLE_NAME="codepipeline-hello-ecs-role"

# ──────────────── CodeBuild Role ────────────────
echo "🚀 Creating IAM Role: ${CODE_BUILD_ROLE_NAME}"

if ! aws iam get-role --role-name "${CODE_BUILD_ROLE_NAME}" >/dev/null 2>&1; then
  aws iam create-role --role-name "${CODE_BUILD_ROLE_NAME}" \
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
else
  echo "ℹ️ Role ${CODE_BUILD_ROLE_NAME} already exists"
fi

# Attach required managed policies to CodeBuild role
CODEBUILD_POLICIES=(
  "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
  "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
  "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess"
)

for POLICY_ARN in "${CODEBUILD_POLICIES[@]}"; do
  echo "🔐 Attaching policy to ${CODE_BUILD_ROLE_NAME}: ${POLICY_ARN}"
  aws iam attach-role-policy --role-name "${CODE_BUILD_ROLE_NAME}" --policy-arn "${POLICY_ARN}" >/dev/null 2>&1 || true
done

# Inline S3 access policy for CodeBuild role
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
  }" >/dev/null 2>&1

# ──────────────── CodePipeline Role ────────────────
echo "🚀 Creating IAM Role: ${CODE_PIPELINE_ROLE_NAME}"

if ! aws iam get-role --role-name "${CODE_PIPELINE_ROLE_NAME}" >/dev/null 2>&1; then
  aws iam create-role --role-name "${CODE_PIPELINE_ROLE_NAME}" \
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
) >/dev/null 2>&1
else
  echo "ℹ️ Role ${CODE_PIPELINE_ROLE_NAME} already exists"
fi

# Inline policy for CodeCommit access
echo "🔐 Adding inline policy to ${CODE_PIPELINE_ROLE_NAME} for CodeCommit access"
aws iam put-role-policy \
  --role-name "${CODE_PIPELINE_ROLE_NAME}" \
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
  }" >/dev/null 2>&1

# Inline policy for S3 access in pipeline role
aws iam put-role-policy \
  --role-name "${CODE_PIPELINE_ROLE_NAME}" \
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
  }" >/dev/null 2>&1

# Inline policy for CodeBuild access from pipeline role
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
  }" >/dev/null 2>&1

# Inline policy for ECS deployment permissions in pipeline role
aws iam put-role-policy \
  --role-name "${CODE_PIPELINE_ROLE_NAME}" \
  --policy-name AllowECSDeployment \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "ecs:RegisterTaskDefinition",
          "ecs:UpdateService",
          "ecs:Describe*",
          "iam:PassRole"
        ],
        "Resource": "*"
      }
    ]
  }' >/dev/null 2>&1

echo "✅ IAM roles successfully created and configured."
