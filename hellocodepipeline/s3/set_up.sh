#!/bin/bash

# ──────────────── Configuration ────────────────
REGION="us-east-1"

# ──────────────── Fetch Account Info ────────────────
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
ARTIFACT_BUCKET="codepipeline-artifacts-$AWS_ACCOUNT_ID"


echo "🧾 Account ID: ${AWS_ACCOUNT_ID}"
echo "🔐 Artifact Bucket: ${ARTIFACT_BUCKET}"


# === 1. Create Artifact Bucket (if not exists) ===
S3_CREATE_S3=$$(aws s3api head-bucket --bucket "$ARTIFACT_BUCKET" 2>/dev/null || {
  echo "Creating S3 bucket $ARTIFACT_BUCKET"
  aws s3 mb "s3://$ARTIFACT_BUCKET" --region "$REGION"
})
