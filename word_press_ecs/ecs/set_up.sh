#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)


# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)

APP_SG_ID_2=$(aws ec2 describe-security-groups --filters Name=group-name,Values=app-sg --query "SecurityGroups[0].GroupId" --output text)

echo $APP_SG_ID_2

TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups --names wordpress-tg --query "TargetGroups[0].TargetGroupArn" --output text)

echo $TARGET_GROUP_ARN


# Get Subnet ID for Private Subnet AZ A
subnet_a=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ A" "Name=availability-zone,Values=us-east-1a" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Private Subnet AZ B
subnet_b=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ B" "Name=availability-zone,Values=us-east-1b" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Private Subnet AZ C
subnet_c=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ C" "Name=availability-zone,Values=us-east-1c" \
    --query "Subnets[0].SubnetId" --output text)

echo "Waiting rds service  wordpress-service --> aws rds wait db-instance-available --db-instance-identifier wordpress"

WAIT_RDS_OUTPUT=$(aws rds wait db-instance-available --db-instance-identifier wordpress) 

echo "Creating ecs service  wordpress-service --> aws ecs create-service"

LOAD_BALANCER="[ 
    {
        \"targetGroupArn\": \"$TARGET_GROUP_ARN\",
        \"containerName\": \"wordpress\",
        \"containerPort\": 80
    }
]"

    
ECS_SERVICE_OUTPUT=$(aws ecs create-service \
    --cluster Wordpress-Cluster \
    --service-name wordpress-service \
    --task-definition wordpress-td:1 \
    --load-balancers $LOAD_BALANCER \
    --launch-type FARGATE \
    --platform-version LATEST \
    --desired-count 1 \
    --network-configuration "awsvpcConfiguration={subnets=[$subnet_a,$subnet_b,$subnet_c],securityGroups=[$APP_SG_ID_2],assignPublicIp=ENABLED}") 
   
