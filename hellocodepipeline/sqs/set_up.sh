# ... [previous lines remain unchanged] ...

# ✅ Dynamically build policy with correct ARNs
POLICY_JSON=$(jq -c --arg dlq_arn "$DLQ_ARN" --arg source_arn "$CODE_COMMIT_TRIGGER_RULE_ARN" '
{
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
}
')

# 🔐 Set DLQ policy
echo "🔐 Setting SQS DLQ policy to allow EventBridge to send messages..."
aws sqs set-queue-attributes \
  --queue-url "$DLQ_URL" \
  --attributes "Policy=$POLICY_JSON"
