#!/bin/bash


# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)


# Get the Security Group ID for ALBAllowHttp
ALB_ALLOW_HTTP_SG_ID=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=ALBAllowHttp \
    --query 'SecurityGroups[0].GroupId' \
    --output text)

echo $ALB_ALLOW_HTTP_SG_ID

echo "Creating security Group  app-sg --> aws elbv2 create-security-group"

APP_SG_ID=$(aws ec2 create-security-group \
    --group-name app-sg \
    --description "Security group for application" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)

echo $APP_SG_ID


echo "Add  app-sg inbound rule allow HTTP traffic from ALBAllowHttp --> aws ec2 authorize-security-group-ingress"

# Add an inbound rule to allow HTTP traffic from ALBAllowHttp
INGRESS_OUTPUT=$(aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 80 \
    --source-group $ALB_ALLOW_HTTP_SG_ID)



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

