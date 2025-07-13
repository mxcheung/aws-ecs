#!/bin/bash


# ──────────────── Configuration ────────────────
PROJECT_NAME="hello-ecs-build"
REPO_NAME="hello-ecs"
REGION="us-east-1"
ROLE_NAME="codebuild-hello-ecs-role"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BRANCH=master                                # branch you want to watch
RULE_NAME="trigger-codebuild-on-push"

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


# ──────────────── Create CodeBuild commit triggger ────────────────

# Create EventBridge rule for CodeCommit push to specific branch
aws events put-rule \
  --name "$RULE_NAME" \
  --event-pattern "$(cat <<EOF
{
  "source": ["aws.codecommit"],
  "detail-type": ["CodeCommit Repository State Change"],
  "resources": ["arn:aws:codecommit:${REGION}:${AWS_ACCOUNT_ID}:${REPO_NAME}"],
  "detail": {
    "event": ["referenceUpdated"],
    "referenceType": ["branch"],
    "referenceName": ["${BRANCH}"]
  }
}
EOF
)" \
  --region "$REGION"


# Put EventBridge target (CodeBuild project)
aws events put-targets \
  --rule "trigger-codebuild-on-push" \
  --targets "$(cat <<EOF
[
  {
    "Id": "TriggerCodeBuild",
    "Arn": "arn:aws:codebuild:${REGION}:${ACCOUNT_ID}:project/${PROJECT_NAME}",
    "RoleArn": "${ROLE_ARN}"
  }
]
EOF
)"

echo "✅ CodeBuild project '${PROJECT_NAME}' event bridge trigger created successfully."
