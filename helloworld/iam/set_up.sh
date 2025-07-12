#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ROLE_NAME="CodeDeployECSRole"
TRUST_POLICY_FILE="codedeploy-trust-policy.json"


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

echo "🚀 Create role codedeploy: $AWS_ACCOUNT_ID"

echo "🚀 Creating trust policy JSON file..."
cat > $TRUST_POLICY_FILE <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

echo "🔍 Checking if role $ROLE_NAME exists..."
if aws iam get-role --role-name "$ROLE_NAME" > /dev/null 2>&1; then
  echo "⚠️ Role $ROLE_NAME already exists. Skipping creation."
else
  echo "🛠 Creating IAM role $ROLE_NAME..."
  aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document file://$TRUST_POLICY_FILE
  echo "✅ Role $ROLE_NAME created."
fi

echo "📎 Attaching AWSCodeDeployRoleForECS managed policy..."
aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS

echo "✅ Managed policy attached to $ROLE_NAME."

echo "IAM Role ARN:"
echo "arn:aws:iam::$AWS_ACCOUNT_ID:role/$ROLE_NAME"

echo "🎉 Done."
