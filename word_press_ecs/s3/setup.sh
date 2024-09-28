#!/bin/bash

# Set environment variables
export ELB_ACCOUNT_ID=127311923021
export AWS_REGION=us-east-1

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Define the bucket names (for access logs and connection logs)
export ACCESS_LOGS_BUCKET=my-loadbalancer-access-logs-${AWS_ACCOUNT_ID}
export CONNECTION_LOGS_BUCKET=my-loadbalancer-connection-logs-${AWS_ACCOUNT_ID}

# Define the Load Balancer ARN
export LOAD_BALANCER_ARN=arn:aws:elasticloadbalancing:us-east-1:${AWS_ACCOUNT_ID}:loadbalancer/app/OurApplicationLoadBalancer/db8639bd5df9f98b

# Function to create S3 bucket and apply bucket policy
create_bucket_and_apply_policy() {
    local bucket_name=$1
    local load_balancer_arn=$2

    # Create the S3 bucket
    echo "Creating S3 bucket: ${bucket_name}"
    aws s3api create-bucket --bucket ${bucket_name} --region ${AWS_REGION}

    # Create the bucket policy
    cat <<EoF > bucket-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${ELB_ACCOUNT_ID}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${bucket_name}/AWSLogs/${AWS_ACCOUNT_ID}/*"
        }
    ]
}
EoF

    # Apply the bucket policy
    echo "Applying bucket policy to: ${bucket_name}"
    aws s3api put-bucket-policy --bucket ${bucket_name} --policy file://bucket-policy.json

    # Clean up
    rm bucket-policy.json
}

# Create the S3 bucket for access logs and apply its policy
create_bucket_and_apply_policy "${ACCESS_LOGS_BUCKET}" "${LOAD_BALANCER_ARN}"

# Create the S3 bucket for connection logs and apply its policy
create_bucket_and_apply_policy "${CONNECTION_LOGS_BUCKET}" "${LOAD_BALANCER_ARN}"
