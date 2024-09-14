#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

image_uri="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/wordpress:latest"

container_definitions=$(cat <<EOF
[
  {
    "name": "wordpress",
    "image": "$image_uri",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/wordpress",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    },
    "secrets": [
      {
        "name": "WORDPRESS_DB_HOST",
        "valueFrom": "arn:aws:ssm:us-east-1:$AWS_ACCOUNT_ID:parameter/dev/WORDPRESS_DB_HOST"
      },
      {
        "name": "WORDPRESS_DB_NAME",
        "valueFrom": "arn:aws:ssm:us-east-1:$AWS_ACCOUNT_ID:parameter/dev/WORDPRESS_DB_NAME"
      },
      {
        "name": "WORDPRESS_DB_USER",
        "valueFrom": "arn:aws:secretsmanager:us-east-1:$AWS_ACCOUNT_ID:secret:rds!db-1380b131-f0b2-4ef3-833f-4ab7a78f29fd-BAsjMA:username::"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "valueFrom": "arn:aws:secretsmanager:us-east-1:$AWS_ACCOUNT_ID:secret:rds!db-1380b131-f0b2-4ef3-833f-4ab7a78f29fd-BAsjMA:password::"
      }
    ]
  }
]
EOF
)

ECS_TASK_DEFINITION=$(aws ecs register-task-definition \
    --family wordpress-td \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu "256" \
    --memory "512" \
    --execution-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/OurEcsTaskExecutionRole \
    --task-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/OurEcsTaskRole \
    --container-definitions "$container_definitions")


# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)


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
    
APP_SG_ID=$(aws ec2 create-security-group \
    --group-name app-sg \
    --description "Security group for application" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)


# Get the Security Group ID for ALBAllowHttp
ALB_ALLOW_HTTP_SG_ID=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values=ALBAllowHttp \
    --query 'SecurityGroups[0].GroupId' \
    --output text)


# Add an inbound rule to allow HTTP traffic from ALBAllowHttp
OUTPUT=$(aws ec2 authorize-security-group-ingress \
    --group-id $APP_SECURITY_GROUP_ID \
    --protocol tcp \
    --port 80 \
    --source-group $ALB_ALLOW_HTTP_SG_ID)

    
ECS_CREATE_CLUSTER_OUTPUT=$(aws ecs create-cluster --cluster-name Wordpress-Cluster)
    
ECS_SERVICE_OUTPUT=$(aws ecs create-service \
    --cluster Wordpress-Cluster \
    --service-name wordpress-service \
    --task-definition wordpress-td:1 \
    --launch-type FARGATE \
    --platform-version LATEST \
    --desired-count 1 \
    --network-configuration "awsvpcConfiguration={subnets=[$subnet_a,$subnet_b,$subnet_c],securityGroups=[$APP_SG_ID],assignPublicIp=DISABLED}") 
   
