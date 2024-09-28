#!/bin/bash

# Set environment variables
export ELB_ACCOUNT_ID=127311923021
export AWS_REGION=us-east-1

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)

# Define the bucket names (for access logs and connection logs)
export ACCESS_LOGS_BUCKET=my-loadbalancer-access-logs-${AWS_ACCOUNT_ID}
export CONNECTION_LOGS_BUCKET=my-loadbalancer-connection-logs-${AWS_ACCOUNT_ID}
export FLOW_LOGS_BUCKET=flow-logs-${AWS_ACCOUNT_ID}

# Define the Load Balancer ARN
export LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers \
    --names OurApplicationLoadBalancer \
    --query "LoadBalancers[0].LoadBalancerArn" \
    --output text)


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


# Enable Access Logs for Load Balancer
# Enable Access Logs and Connection Logs for Load Balancer

LOAD_BALANCE_MODIFY_OUTPUT=$(aws elbv2 modify-load-balancer-attributes \
    --load-balancer-arn ${LOAD_BALANCER_ARN} \
    --region ${AWS_REGION} \
    --attributes \
    Key=access_logs.s3.enabled,Value=true \
    Key=access_logs.s3.bucket,Value=${ACCESS_LOGS_BUCKET} \
    Key=connection_logs.s3.enabled,Value=true \
    Key=connection_logs.s3.bucket,Value=${CONNECTION_LOGS_BUCKET} 
)

# Enable VPC Flow Logs for connection logs
FLOW_LOGS_OUTPUT=$(aws ec2 create-flow-logs \
    --resource-type VPC \
    --resource-id ${VPC_ID} \
    --traffic-type ALL \
    --log-destination-type s3 \
    --log-destination arn:aws:s3:::${FLOW_LOGS_BUCKET} \
    --region ${AWS_REGION}
) 
