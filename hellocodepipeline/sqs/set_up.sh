#!/bin/bash

# ──────────────── Configuration ────────────────
REGION="us-east-1"
EVENTBRIDGE_ROLE_NAME="eventbridge-hello-ecs-role"  # New role for EventBridge

# ──────────────── Fetch Account Info ────────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"



# ──────────────── Dead‑letter queue (DLQ) for EventBridge ────────────────
DLQ_NAME="eventbridge-dlq"
RULE_NAME="TriggerPipelineOnPush"
PIPELINE_NAME="hello-ecs-pipeline"
PIPELINE_ARN="arn:aws:codepipeline:${REGION}:${AWS_ACCOUNT_ID}:${PIPELINE_NAME}"
EVENTBRIDGE_ROLE_ARN="arn:aws:iam::${AWS_ACCOUNT_ID}:role/${EVENTBRIDGE_ROLE_NAME}"

echo "📬 Creating SQS DLQ: ${DLQ_NAME}"
DLQ_URL=$(aws sqs create-queue --queue-name "${DLQ_NAME}" \
          --attributes VisibilityTimeout=60 \
          --output text --query 'QueueUrl')