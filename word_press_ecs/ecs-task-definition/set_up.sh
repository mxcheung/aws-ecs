#!/bin/bash

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

image_uri="${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/wordpress:latest"


echo "Waiting rds service  wordpress-service --> aws rds wait db-instance-available --db-instance-identifier wordpress"
WAIT_RDS_OUTPUT=$(aws rds wait db-instance-available --db-instance-identifier wordpress) 

YOUR_RDS_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier wordpress --query 'DBInstances[0].Endpoint.Address' --output text)

 echo $YOUR_RDS_ENDPOINT

 echo "Parameter Store WORDPRESS_DB_HOST -> aws ssm put-parameter"

 
 aws ssm put-parameter \
    --name "/dev/WORDPRESS_DB_HOST" \
    --description "Wordpress RDS endpoint" \
    --tier Standard \
    --type String \
    --value "$YOUR_RDS_ENDPOINT:3306" \
    --overwrite

echo "Parameter Store WORDPRESS_DB_NAME -> aws ssm put-parameter"

aws ssm put-parameter \
    --name "/dev/WORDPRESS_DB_NAME" \
    --description "Wordpress RDS Database Name" \
    --tier Standard \
    --type SecureString \
    --value "wordpress" \
    --overwrite



# Get the secret ARN
SECRET_ARN=$(aws rds describe-db-instances --db-instance-identifier wordpress --query 'DBInstances[0].MasterUserSecret.SecretArn' --output text)
SECRET_NAME=$(aws secretsmanager describe-secret --secret-id $SECRET_ARN --query 'Name' --output text)
echo "Secret ARN: $SECRET_ARN"
echo "Secret Name: $SECRET_NAME"

container_definitions=$(cat <<EOF
[
  {
    "name": "wordpress",
    "image": "$image_uri",
    "essential": true,
    "portMappings": [
      {
        "name": "wordpress-80-tcp",
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/wordpress-td",
        "awslogs-create-group": "true",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs",
        "mode": "non-blocking",
        "max-buffer-size": "25m"
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
        "valueFrom": "$SECRET_ARN:username::"
      },
      {
        "name": "WORDPRESS_DB_PASSWORD",
        "valueFrom": "$SECRET_ARN:password::"
      }
    ]
  }
]
EOF
)

echo "Create Task Definition"

ECS_TASK_DEFINITION=$(aws ecs register-task-definition \
    --family wordpress-td \
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
