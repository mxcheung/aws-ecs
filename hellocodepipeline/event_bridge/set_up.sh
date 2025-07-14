
#!/bin/bash


# ──────────────── Configuration ────────────────
PROJECT_NAME="hello-ecs-build"
REPO_NAME="hello-ecs"
REGION="us-east-1"
ROLE_NAME="codebuild-hello-ecs-role"
CODE_PIPELINE_ROLE_NAME="codepipeline-hello-ecs-role"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
BRANCH=master                                # branch you want to watch
RULE_NAME="trigger-codepipeline-on-push"
DLQ_NAME="eventbridge-dlq"
DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:${DLQ_NAME}"

# ──────────────── Fetch Account Info ────────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
CODE_PIPELINE_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${CODE_PIPELINE_ROLE_NAME}"



echo "🚀 Creating CodeBuild project: ${PROJECT_NAME}"
echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"
echo "🔐 Code pipeline Role: ${CODE_PIPELINE_ROLE_ARN}"



# ──────────────── Create CodeBuild commit triggger ────────────────

# Create EventBridge rule for CodeCommit push to specific branch
aws events put-rule \
  --name "$RULE_NAME" \
  --dead-letter-config Arn="$DLQ_ARN" \
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





# Put EventBridge target (CodePipeline project)
aws events put-targets \
  --rule "trigger-codepipeline-on-push" \
  --targets "$(cat <<EOF
[
  {
    "Id": "TriggerCodePipeline",
    "Arn": "arn:aws:codepipeline:${REGION}:${AWS_ACCOUNT_ID}:project/${PROJECT_NAME}",
    "RoleArn": "${CODE_PIPELINE_ROLE_ARN}",
    "DeadLetterConfig": {
      "Arn": "arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:eventbridge-dlq"
    }    
  }
]
EOF
)"

