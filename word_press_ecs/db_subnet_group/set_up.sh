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


OUTPUT=$(aws rds create-db-subnet-group \
    --db-subnet-group-name my-db-subnet-group \
    --db-subnet-group-description "Subnet group for RDS in us-east-1a, us-east-1b, us-east-1c" \
    --subnet-ids $subnet_a $subnet_b $subnet_c \
    --tags Key=Name,Value=my-db-subnet-group)
