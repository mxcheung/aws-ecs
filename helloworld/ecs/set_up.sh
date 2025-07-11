#!/bin/bash


CLUSTER_NAME="Wordpress-Cluster"
SERVICE_NAME="wordpress-service"
TASK_DEF_NAME="helloword-td"

# SUBNET_ID="subnet-xxxxxx"  # Replace with a real subnet ID

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


    
# Register or get the new task definition
NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition helloword-td  \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

# Update the ECS service to use the new task definition
# ECS_UPDATE_OUTPUT=$(aws ecs update-service \
#  --cluster Wordpress-Cluster  \
#  --service wordpress-service \
#  --task-definition "$NEW_TASK_DEF")
  

# Step 1: Delete the existing service
aws ecs update-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --desired-count 0

aws ecs delete-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --force

# Step 2: Recreate the service WITHOUT a load balancer
ECS_SERVICE_OUTPUT=$(aws ecs create-service \
  --cluster "$CLUSTER_NAME" \
  --service-name "$SERVICE_NAME" \
  --launch-type FARGATE \
  --task-definition "$TASK_DEF_NAME" \
  --desired-count 1 \
    --network-configuration "awsvpcConfiguration={subnets=[$subnet_a,$subnet_b,$subnet_c],assignPublicIp=ENABLED}") 
