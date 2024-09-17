#!/bin/bash


   
# Get Subnet ID for Database Subnet AZ A
subnet_a=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Database Subnet AZ A" "Name=availability-zone,Values=us-east-1a" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Database Subnet AZ B
subnet_b=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Database Subnet AZ B" "Name=availability-zone,Values=us-east-1b" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Database Subnet AZ C
subnet_c=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Database Subnet AZ C" "Name=availability-zone,Values=us-east-1c" \
    --query "Subnets[0].SubnetId" --output text)

echo "Create database subnet group -> aws rds create-db-subnet-group"

DB_SUBNET_GROUP_ID_OUTPUT=$(aws rds create-db-subnet-group \
    --db-subnet-group-name database-subnet-group \
    --db-subnet-group-description "Subnet group for RDS in us-east-1a, us-east-1b, us-east-1c" \
    --subnet-ids $subnet_a $subnet_b $subnet_c \
    --tags Key=Name,Value=database-subnet-group)

    
# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)
echo "Create Security Group -> create-security-group database-sg"


RDS_KMS_KEY_ID=$(aws kms describe-key \
    --key-id alias/aws/rds \
    --query 'KeyMetadata.Arn' \
    --output text

echo "aws kms describe-key --> key-id alias/aws/rds"
echo $RDS_KMS_KEY_ID

DB_SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name database-sg \
    --description "Security group for RDS instance" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)

echo "aws ec2 describe-security-groups -> database-sg"

echo $DATABASE_SG_ID

echo "Allow MySQL access from VPC ->aws ec2 authorize-security-group-ingressg"


DB_SECURITY_GROUP_ID_INGRESS=$(aws ec2 authorize-security-group-ingress \
   --group-id $DB_SECURITY_GROUP_ID \
   --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{CidrIp=10.0.0.0/16,Description='Allow MySQL access from VPC'}]")



DATABASE_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=database-sg --query "SecurityGroups[0].GroupId" --output text)

echo "Create the RDS Instance -> aws rds create-db-instance"

# Create the RDS Instance
CREATE_RDS_OUTPUT=$(aws rds create-db-instance \
    --db-instance-identifier wordpress \
    --db-instance-class db.t4g.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --allocated-storage 20 \
    --storage-type gp3 \
    --allocated-storage 20 \
    --max-allocated-storage 1000 \
    --db-subnet-group-name database-subnet-group \
    --storage-encrypted \
    --vpc-security-group-ids $DATABASE_SG_ID \
    --master-username admin \
    --manage-master-user-password)
    
