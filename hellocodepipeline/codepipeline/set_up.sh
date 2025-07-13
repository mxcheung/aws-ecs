#!/bin/bash
set -euo pipefail

# ──────────────── Configuration ────────────────
PROJECT_NAME="hello-ecs-build"
REPO_NAME="hello-ecs"
REGION="us-east-1"
ROLE_NAME="codepipeline-hello-ecs-role"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BRANCH="master"                                # branch you want to watch
PIPELINE_NAME="hello-ecs-pipeline"
ARTIFACT_BUCKET="codepipeline-artifacts-${AWS_ACCOUNT_ID}"
CLUSTER_NAME="Wordpress-Cluster"
SERVICE_NAME="wordpress-service"
RULE_NAME="CodeCommitPushTriggerRule"

ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${ROLE_NAME}"
CODECOMMIT_REPO_NAME="${REPO_NAME}"

echo "🚀 Creating CodePipeline: ${PIPELINE_NAME}"
echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"
echo "🔗 CodeCommit Repo: ${CODECOMMIT_REPO_NAME}"
echo "🔐 Role: ${ROLE_ARN}"
echo "📦 Artifact Bucket: ${ARTIFACT_BUCKET}"

# ──────────────── Check prerequisites ────────────────
if ! aws iam get-role --role-name "${ROLE_NAME}" >/dev/null 2>&1; then
  echo "❌ IAM role ${ROLE_NAME} does not exist. Create it before proceeding."
  exit 1
fi

# ──────────────── Create pipeline JSON ────────────────
cat > pipeline.json <<EOF
{
  "pipeline": {
    "name": "${PIPELINE_NAME}",
    "roleArn": "${ROLE_ARN}",
    "artifactStore": {
      "type": "S3",
      "location": "${ARTIFACT_BUCKET}"
    },
    "stages": [
      {
        "name": "Source",
        "actions": [
          {
            "name": "CodeCommit_Source",
            "actionTypeId": {
              "category": "Source",
              "owner": "AWS",
              "provider": "CodeCommit",
              "version": "1"
            },
            "outputArtifacts": [{ "name": "SourceOut" }],
            "configuration": {
              "RepositoryName": "${CODECOMMIT_REPO_NAME}",
              "BranchName": "${BRANCH}",
              "PollForSourceChanges": "false"
            },
            "runOrder": 1
          }
        ]
      },
      {
        "name": "Build",
        "actions": [
          {
            "name": "Docker_Build",
            "actionTypeId": {
              "category": "Build",
              "owner": "AWS",
              "provider": "CodeBuild",
              "version": "1"
            },
            "inputArtifacts": [{ "name": "SourceOut" }],
            "outputArtifacts": [{ "name": "BuildOut" }],
            "configuration": {
              "ProjectName": "${PROJECT_NAME}"
            },
            "runOrder": 1
          }
        ]
      },
      {
        "name": "Deploy",
        "actions": [
          {
            "name": "ECS_Deploy",
            "actionTypeId": {
              "category": "Deploy",
              "owner": "AWS",
              "provider": "ECS",
              "version": "1"
            },
            "inputArtifacts": [{ "name": "BuildOut" }],
            "configuration": {
              "ClusterName": "${CLUSTER_NAME}",
              "ServiceName": "${SERVICE_NAME}",
              "FileName": "imagedefinitions.json"
            },
            "runOrder": 1
          }
        ]
      }
    ],
    "version": 1
  }
}
EOF

# ──────────────── Create or update pipeline ────────────────
if aws codepipeline get-pipeline --name "${PIPELINE_NAME}" >/dev/null 2>&1; then
  echo "♻️ Pipeline exists. Updating pipeline..."
  aws codepipeline update-pipeline --cli-input-json file://pipeline.json >/dev/null 2>&1
else
  echo "✨ Creating new pipeline..."
  aws codepipeline create-pipeline --cli-input-json file://pipeline.json >/dev/null 2>&1
fi

echo "✅ Pipeline ready: ${PIPELINE_NAME}"

# ──────────────── Create EventBridge rule for CodeCommit pushes ────────────────
echo "Creating EventBridge rule ${RULE_NAME}..."

RULE_ARN=$(aws events put-rule \
  --name "${RULE_NAME}" \
  --event-pattern "{
    \"source\": [\"aws.codecommit\"],
    \"detail-type\": [\"CodeCommit Repository State Change\"],
    \"resources\": [\"arn:aws:codecommit:${REGION}:${AWS_ACCOUNT_ID}:${REPO_NAME}\"],
    \"detail\": {
      \"event\": [\"referenceCreated\", \"referenceUpdated\"],
      \"referenceType\": [\"branch\"],
      \"referenceName\": [\"${BRANCH}\"]
    }
  }" \
  --query "RuleArn" --output text)

echo "EventBridge rule created: ${RULE_ARN}"


# Add the CodePipeline as a target of this rule
echo "Adding CodePipeline ${PIPELINE_NAME} as target to rule..."
aws events put-targets \
  --rule "${RULE_NAME}" \
  --targets "Id"="1","Arn"="arn:aws:codepipeline:${REGION}:${AWS_ACCOUNT_ID}:${PIPELINE_NAME}","RoleArn"="${ROLE_ARN}"

if [ $? -eq 0 ]; then
  echo "Successfully added CodePipeline target to rule."
else
  echo "Failed to add CodePipeline target to rule."
fi


echo "Target added."

# ──────────────── Grant EventBridge permission to start pipeline ────────────────
echo "Granting EventBridge permission to start the pipeline..."

aws codepipeline put-pipeline-permission \
  --pipeline-name "${PIPELINE_NAME}" \
  --principal "events.amazonaws.com" \
  --statement-id "AllowEventBridgeStart" \
  --action "codepipeline:StartPipelineExecution"

if [ $? -eq 0 ]; then
  echo "Permission granted."
  echo "✅ EventBridge trigger for CodeCommit pushes set up successfully!"
else
  echo "Failed to grant permission."
fi

echo "✅ EventBridge trigger for CodeCommit pushes set up successfully!"
