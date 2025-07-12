#!/usr/bin/env bash
set -euo pipefail

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
read -r -d '' CONTAINER_DEFINITIONS <<EOF
[
  {
    "name": "wordpress",
    "image": "${IMAGE_URI}",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/wordpress-td",
        "awslogs-create-group": "true",
        "awslogs-region": "${REGION}",
        "awslogs-stream-prefix": "ecs",
        "mode": "non-blocking",
        "max-buffer-size": "25m"
      }
    },
    "healthCheck": {
      "command": [ "CMD-SHELL", "curl -f http://localhost:80/ || exit 1" ],
      "interval": 30,
      "timeout": 5,
      "retries": 3
    }
  }
]
EOF

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
  --container-definitions "${CONTAINER_DEFINITIONS}")

echo "✅ Task definition ${FAMILY_NAME} registered."
