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


DB_SUBNET_GROUP_ID_OUTPUT=$(aws rds create-db-subnet-group \
    --db-subnet-group-name my-db-subnet-group \
    --db-subnet-group-description "Subnet group for RDS in us-east-1a, us-east-1b, us-east-1c" \
    --subnet-ids $subnet_a $subnet_b $subnet_c \
    --tags Key=Name,Value=my-db-subnet-group)

DATABASE_SG_ID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=app-sg --query "SecurityGroups[0].GroupId" --output text)

# Create the RDS Instance
CREATE_RDS_OUTPUT=$(aws rds create-db-instance \
    --db-instance-identifier wordpress \
    --db-instance-class db.t4g.micro \
    --engine mysql \
    --engine-version 8.0.32 \
    --allocated-storage 20 \
    --storage-type gp3 \
    --db-subnet-group-name my-db-subnet-group \
    --vpc-security-group-ids $DATABASE_SG_ID \
    --master-username admin \
    --manage-master-user-password)
    
WAIT_RDS_OUTPUT=$(aws rds wait db-instance-available --db-instance-identifier wordpress) 

YOUR_RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier wordpress --query 'DBInstances[0].Endpoint.Address' --output text)


 echo $YOUR_RDS_ENDPOINT
 
 aws ssm put-parameter \
    --name "/dev/WORDPRESS_DB_HOST" \
    --description "Wordpress RDS endpoint" \
    --tier Standard \
    --type String \
    --value "$YOUR_RDS_ENDPOINT:3306" \
    --overwrite


aws ssm put-parameter \
    --name "/dev/WORDPRESS_DB_NAME" \
    --description "Wordpress RDS Database Name" \
    --tier Standard \
    --type SecureString \
    --value "wordpress" \
    --overwrite

