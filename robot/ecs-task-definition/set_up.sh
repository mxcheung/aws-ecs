#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

image_uri="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/amazonlinux:latest"


container_definitions=$(cat <<EOF
[
  {
    "name": "robot",
    "image": "$image_uri",
    "essential": true,
    "name": "hello-world-container",
    "image": "amazonlinux:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "command": ["echo", "Hello, World!"]    
  }
]
EOF
)

echo "Create Task Definition"

ECS_TASK_DEFINITION=$(aws ecs register-task-definition \
    --family robot-td \
    --network-mode awsvpc \
    --requires-compatibilities FARGATE \
    --cpu "1024" \
    --memory "3072" \
    --execution-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/OurEcsTaskExecutionRole \
    --task-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/OurEcsTaskRole \
    --runtime-platform '{
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }'  \
    --container-definitions "$container_definitions")
