#!/bin/bash

set -euo pipefail

# Get the absolute path of this script, even if invoked via a relative path or symlink
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"

trap 'echo "❌ Error in ${SCRIPT_PATH} on line $LINENO"; exit 1' ERR


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
DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:${DLQ_NAME}"
CODE_COMMIT_RULE_NAME="CodeCommitPushTriggerRule"
CODE_COMMIT_TRIGGER_RULE_ARN="arn:aws:events:${REGION}:${AWS_ACCOUNT_ID}:rule/${CODE_COMMIT_RULE_NAME}"


# RULE_NAME="CodeCommitPushTriggerRule"
# SOURCE_ARN="arn:aws:events:${REGION}:${ACCOUNT_ID}:rule/${RULE_NAME}"

echo "📬 Creating SQS DLQ: ${DLQ_NAME}"
DLQ_URL=$(aws sqs create-queue --queue-name "${DLQ_NAME}" \
          --attributes VisibilityTimeout=60 \
          --output text --query 'QueueUrl')

echo "📬 DLQ_URL: ${DLQ_URL}"
echo "🔐 Set DLQ queue attributes ${DLQ_ARN} to allow event bridge to send the failed event message to DLQ"

# ───────── Check required vars ─────────
if [[ -z "${DLQ_ARN:-}" || -z "${CODE_COMMIT_TRIGGER_RULE_ARN:-}" ]]; then
  echo "❌ DLQ_ARN or CODE_COMMIT_TRIGGER_RULE_ARN is not set"
  exit 1
fi

# ───────── Debug output ─────────
echo "🧪 DLQ_ARN=$DLQ_ARN"
echo "🧪 CODE_COMMIT_TRIGGER_RULE_ARN=$CODE_COMMIT_TRIGGER_RULE_ARN"

# ───────── Create policy using jq ─────────
POLICY_JSON=$(jq -n -c --arg dlq_arn "$DLQ_ARN" --arg source_arn "$CODE_COMMIT_TRIGGER_RULE_ARN" \
'{
  "Version": "2012-10-17",
  "Id": "EventBridgeSendMessagePolicy",
  "Statement": [
    {
      "Sid": "AllowEventBridgeSendMessage",
      "Effect": "Allow",
      "Principal": { "Service": "events.amazonaws.com" },
      "Action": "sqs:SendMessage",
      "Resource": $dlq_arn,
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": $source_arn
        }
      }
    }
  ]
}')

echo "🧪 DLQ_POLICY_JSON=$POLICY_JSON"


# ───────── Set queue policy ─────────
echo "🔐 Setting DLQ policy..."
aws sqs set-queue-attributes \
  --queue-url "$DLQ_URL" \
  --attributes Policy=$POLICY_JSON
