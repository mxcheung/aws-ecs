#!/bin/bash
# set -euo pipefail

### ────────────────── Config ──────────────────
REGION="us-east-1"
REPO_NAME="hello-ecs"
FAMILY_NAME="helloworld-td"
CPU="1024"
MEMORY="3072"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
IMAGE_URI="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPO_NAME}:latest"

# Optional: validate the image is actually in ECR
# aws ecr describe-images --repository-name "${REPO_NAME}" --image-ids imageTag=latest --region "${REGION}" >/dev/null

### ────────────────── JSON blobs ──────────────────
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
    "healthCheck": {
      "command": [
        "CMD-SHELL",
        "curl -f http://localhost:80/ || exit 1"
      ],
      "interval": 30,
      "timeout": 5,
      "retries": 3
    }
  }
]
EOF
)


read -r -d '' RUNTIME_PLATFORM <<EOF
{
  "cpuArchitecture": "X86_64",
  "operatingSystemFamily": "LINUX"
}
EOF

### ────────────────── Register TD ──────────────────
ECS_TASK_DEFINITION=$(aws ecs register-task-definition \
  --region "${REGION}" \
  --family "${FAMILY_NAME}" \
  --network-mode "awsvpc" \
  --requires-compatibilities "FARGATE" \
  --cpu "${CPU}" \
  --memory "${MEMORY}" \
  --execution-role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/OurEcsTaskExecutionRole" \
  --task-role-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:role/OurEcsTaskRole" \
  --runtime-platform "${RUNTIME_PLATFORM}" \
  --container-definitions "${container_definitions}")

echo "✅ Task definition ${FAMILY_NAME} registered."
