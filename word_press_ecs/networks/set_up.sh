#!/bin/bash

# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)

echo "Creating Target Group --> aws elbv2 create-target-group"

CREATE_TARGET_GROUP_OUTPUT=$(aws elbv2 create-target-group \
    --name wordpress-tg \
    --protocol HTTP \
    --port 80 \
    --vpc-id $VPC_ID \
    --health-check-protocol HTTP \
    --health-check-port 80 \
    --health-check-path "/wp-admin/images/wordpress-logo.svg" \
    --matcher HttpCode=200 \
    --target-type ip \
    --ip-address-type ipv4)

TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups \
    --names wordpress-tg \
    --query "TargetGroups[0].TargetGroupArn" \
    --output text)

echo $TARGET_GROUP_ARN

LOAD_BALANCER_ARN=$(aws elbv2 describe-load-balancers \
    --names OurApplicationLoadBalancer \
    --query "LoadBalancers[0].LoadBalancerArn" \
    --output text)

echo $LOAD_BALANCER_ARN

echo "Creating listener --> aws elbv2 create-listener"

LISTENER_ARN=$(aws elbv2 create-listener \
    --load-balancer-arn $LOAD_BALANCER_ARN \
    --protocol HTTP \
    --port 80 \
    --default-actions Type=forward,TargetGroupArn=$TARGET_GROUP_ARN)

echo $LISTENER_ARN
