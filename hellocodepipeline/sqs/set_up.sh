#!/usr/bin/env bash
#
# Creates an SQS dead‑letter queue (DLQ) and attaches an EventBridge‑only send
# policy.  Any attribute whose value is itself JSON (Policy, RedrivePolicy, …)
# is automatically escaped; scalars stay unescaped.

set -euo pipefail

# ─────────────── Helpers & cleanup ───────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
trap 'echo "❌ Error in ${BASH_SOURCE[0]} on line $LINENO"; exit 1' ERR
ATTR_FILE="$(mktemp)"                    # temp file for set‑queue‑attributes
cleanup() { rm -f "$ATTR_FILE"; }
trap cleanup EXIT

# ─────────────── Configuration (override via env) ───────────────
REGION="${REGION:-us-east-1}"
DLQ_NAME="${DLQ_NAME:-eventbridge-dlq}"
PIPELINE_NAME="${PIPELINE_NAME:-hello-ecs-pipeline}"
EVENTBRIDGE_ROLE_NAME="${EVENTBRIDGE_ROLE_NAME:-eventbridge-hello-ecs-role}"
VISIBILITY_TIMEOUT="${VISIBILITY_TIMEOUT:-60}"

# ─────────────── AWS context ───────────────
AWS_ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
echo "🧾 AWS account: $AWS_ACCOUNT_ID"

DLQ_ARN="arn:aws:sqs:${REGION}:${AWS_ACCOUNT_ID}:${DLQ_NAME}"
CODE_COMMIT_RULE_NAME="CodeCommitPushTriggerRule"
CODE_COMMIT_TRIGGER_RULE_ARN="arn:aws:events:${REGION}:${AWS_ACCOUNT_ID}:rule/${CODE_COMMIT_RULE_NAME}"

# ─────────────── Create DLQ ───────────────
echo "📬 Creating SQS DLQ: $DLQ_NAME"
DLQ_URL="$(aws sqs create-queue \
  --queue-name "$DLQ_NAME" \
  --attributes "VisibilityTimeout=$VISIBILITY_TIMEOUT" \
  --query QueueUrl --output text)"
echo "🧾 DLQ URL: $DLQ_URL"

# ─────────────── Build nested Policy object ───────────────
RAW_POLICY="$(jq -n --arg dlq "$DLQ_ARN" --arg src "$CODE_COMMIT_TRIGGER_RULE_ARN" '
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
}')"

# ─────────────── Escape only JSON‑typed attributes ───────────────
ESCAPED_POLICY="$(jq -n --arg policy "$RAW_POLICY" '$policy' | jq @json)"

# If you need other nested‑JSON attributes (e.g. RedrivePolicy) build them
# the same way and add them below.

# ─────────────── Assemble attribute file ───────────────
jq -n \
  --arg vis "$VISIBILITY_TIMEOUT" \
  --arg policy "$ESCAPED_POLICY" '
{
  VisibilityTimeout: $vis,
  Policy:            $policy      # already escaped
}' > "$ATTR_FILE"

echo "📝 Attributes file created: $ATTR_FILE"
cat "$ATTR_FILE"

# ─────────────── Apply attributes ───────────────
echo "🔐 Applying DLQ attributes…"
aws sqs set-queue-attributes \
  --queue-url "$DLQ_URL" \
  --attributes "file://$ATTR_FILE"

echo "✅ DLQ set‑up complete."
