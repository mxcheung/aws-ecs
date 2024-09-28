
#!/bin/bash

# Set environment variables
export AWS_ACCOUNT_ID=717541894311
export AWS_REGION=us-east-1
export BUCKET_NAME=my-loadbalancer-access-logs-${AWS_ACCOUNT_ID}
export LOAD_BALANCER_ARN=arn:aws:elasticloadbalancing:us-east-1:${AWS_ACCOUNT_ID}:loadbalancer/app/OurApplicationLoadBalancer/db8639bd5df9f98b

# Create the S3 bucket
aws s3api create-bucket --bucket ${BUCKET_NAME} --region ${AWS_REGION}

# Create the bucket policy
cat <<EoF > bucket-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "logdelivery.elasticloadbalancing.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${BUCKET_NAME}/*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "${AWS_ACCOUNT_ID}"
                },
                "ArnLike": {
                    "aws:SourceArn": "${LOAD_BALANCER_ARN}"
                }
            }
        }
    ]
}
EoF

# Apply the bucket policy
aws s3api put-bucket-policy --bucket ${BUCKET_NAME} --policy file://bucket-policy.json

