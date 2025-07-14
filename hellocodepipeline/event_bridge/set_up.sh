
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



# ====== SET SQS ACCESS POLICY ======
echo "Setting SQS access policy to allow EventBridge to send messages..."

DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:eventbridge-dlq"
DLQ_URL="https://sqs.${REGION}.amazonaws.com/${AWS_ACCOUNT_ID}/eventbridge-dlq"

cat > sqs-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEventBridgeSendMessage",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "$DLQ_ARN"
    }
  ]
}
EOF

aws sqs set-queue-attributes \
  --queue-url "$DLQ_URL" \
  --attributes "Policy=$(cat sqs-policy.json)"

aws sqs receive-message \
  --queue-url https://sqs.us-east-1.amazonaws.com/693651255415/eventbridge-dlq \
  --max-number-of-messages 1 \
  --visibility-timeout 0 \
  --wait-time-seconds 5


echo "✅ CodeBuild project '${PROJECT_NAME}' event bridge trigger created successfully."

aws sqs create-queue --queue-name eventbridge-dlq
 "QueueUrl": "https://sqs.us-east-1.amazonaws.com/400874991066/eventbridge-dlq"


 aws sqs get-queue-attributes \
  --queue-url https://sqs.<region>.amazonaws.com/<account-id>/eventbridge-dlq \
  --attribute-names QueueArn
