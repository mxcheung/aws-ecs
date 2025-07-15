#!/usr/bin/env bash

set -euo pipefail

# ─────────────── Error Handling ───────────────
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/$(basename "${BASH_SOURCE[0]}")"
trap 'echo "❌ Error in ${SCRIPT_PATH} on line $LINENO"; exit 1' ERR

# ─────────────── Configuration ───────────────
REGION="us-east-1"
DLQ_NAME="eventbridge-dlq"
VISIBILITY_TIMEOUT="60"
CODE_COMMIT_RULE_NAME="CodeCommitPushTriggerRule"

# ─────────────── Fetch AWS Info ───────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:${DLQ_NAME}"
CODE_COMMIT_TRIGGER_RULE_ARN="arn:aws:events:${REGION}:${AWS_ACCOUNT_ID}:rule/${CODE_COMMIT_RULE_NAME}"

echo "🧾 AWS Account ID: $AWS_ACCOUNT_ID"
echo "📬 Creating SQS DLQ: $DLQ_NAME"

# ─────────────── Create the DLQ ───────────────
DLQ_URL=$(aws sqs create-queue \
  --queue-name "$DLQ_NAME" \
  --attributes "VisibilityTimeout=$VISIBILITY_TIMEOUT" \
  --query QueueUrl --output text)

echo "📬 DLQ URL: $DLQ_URL"

# ─────────────── Create Policy JSON ───────────────
RAW_POLICY=$(jq -n --arg dlq "$DLQ_ARN" --arg src "$CODE_COMMIT_TRIGGER_RULE_ARN" '
{
  Version: "2012-10-17",
  Id:      "EventBridgeSendMessagePolicy",
  Statement: [{
    Sid:       "AllowEventBridgeSendMessage",
    Effect:    "Allow",
    Principal: { Service: "events.amazonaws.com" },
    Action:    "sqs:SendMessage",
    Resource:  $dlq,
    Condition: { ArnEquals: { "aws:SourceArn": $src } }
  }]
}')

# ─────────────── Escape Policy for SQS Attributes ───────────────
ESCAPED_POLICY=$(jq -n --arg policy "$RAW_POLICY" '$policy' | jq @json)

# ─────────────── Write Attribute File ───────────────
echo "📝 Writing set-queue-attributes.json..."
cat > set-queue-attributes.json <<EOF
{
  "VisibilityTimeout": "$VISIBILITY_TIMEOUT",
  "Policy": $ESCAPED_POLICY
}
EOF

echo "📄 Generated set-queue-attributes.json:"
cat set-queue-attributes.json

# ─────────────── Apply Attributes to Queue ───────────────
echo "🔐 Setting DLQ attributes..."
aws sqs set-queue-attributes \
  --queue-url "$DLQ_URL" \
  --attributes file://set-queue-attributes.json

echo "✅ DLQ setup complete."
