
#!/bin/bash


# ──────────────── Configuration ────────────────
PROJECT_NAME="hello-ecs-build"
REPO_NAME="hello-ecs"
REGION="us-east-1"
ROLE_NAME="codebuild-hello-ecs-role"
CODE_PIPELINE_ROLE_NAME="codepipeline-hello-ecs-role"
EVENTBRIDGE_ROLE_NAME="eventbridge-hello-ecs-role"  # New role for EventBridge
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BRANCH=master                                # branch you want to watch
RULE_NAME="trigger-codepipeline-on-push"
DLQ_NAME="eventbridge-dlq"
DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:${DLQ_NAME}"
PIPELINE_NAME="hello-ecs-pipeline"

# ──────────────── Fetch Account Info ────────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
CODE_PIPELINE_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CODE_PIPELINE_ROLE_NAME}"
EVENTBRIDGE_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EVENTBRIDGE_ROLE_NAME}"
CODE_PIPELINE_ARN="arn:aws:codepipeline:${REGION}:${AWS_ACCOUNT_ID}:${PIPELINE_NAME}"

echo "🚀 Creating CodeBuild project: ${PROJECT_NAME}"
echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"
echo "🔐 Code pipeline Role: ${CODE_PIPELINE_ROLE_ARN}"


# ──────────────── Create EventBridge rule for CodeCommit pushes ────────────────
# Create EventBridge rule for CodeCommit push to specific branch

echo "Creating EventBridge rule ${RULE_NAME}..."

RULE_ARN=$(aws events put-rule \
  --name "${RULE_NAME}" \
  --role-arn "${EVENTBRIDGE_ROLE_ARN}"  
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



# Put EventBridge target (CodePipeline project)
aws events put-targets \
  --rule "${RULE_NAME}" \
  --targets "[
    {
      \"Id\": \"TriggerCodePipeline\",
      \"Arn\": \"${CODE_PIPELINE_ARN}\"
      \"RoleArn\": \"${ROLEEVENTBRIDGE_ROLE_ARN_ARN}\",
      \"DeadLetterConfig\": {
        \"Arn\": \"${DLQ_ARN}\"
      }
    }
  ]"
  
if [ $? -eq 0 ]; then
  echo "Successfully added CodePipeline target to rule."
else
  echo "Failed to add CodePipeline target to rule."
fi


echo "Target added."




echo "✅ EventBridge trigger for CodeCommit pushes set up successfully!"
