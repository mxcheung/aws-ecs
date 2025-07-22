
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
