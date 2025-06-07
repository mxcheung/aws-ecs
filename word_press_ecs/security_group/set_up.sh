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

APP_SG_ID_OUTPUT=$(aws ec2 create-security-group \
    --group-name app-sg \
    --description "Security group for application" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)

APP_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=app-sg --query "SecurityGroups[0].GroupId" --output text)


echo $APP_SG_ID


echo "Add  app-sg inbound rule allow HTTP traffic from ALBAllowHttp --> aws ec2 authorize-security-group-ingress"

# Add an inbound rule to allow HTTP traffic from ALBAllowHttp
INGRESS_OUTPUT=$(aws ec2 authorize-security-group-ingress \
    --group-id $APP_SG_ID \
    --protocol tcp \
    --port 80 \
    --source-group $ALB_ALLOW_HTTP_SG_ID)


echo "create-security-group database-sg"

DB_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name database-sg \
    --description "Security group for RDS instance" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)

echo "aws ec2 describe-security-groups -> database-sg"

DATABASE_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=database-sg --query "SecurityGroups[0].GroupId" --output text)

echo $DATABASE_SG_ID

echo "Allow MySQL access from VPC ->aws ec2 authorize-security-group-ingress"

DB_SECURITY_GROUP_ID_INGRESS=$(aws ec2 authorize-security-group-ingress \
   --group-id $DATABASE_SG_ID \
   --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{CidrIp=10.0.0.0/16,Description='Allow MySQL access from VPC'}]")

