#!/bin/bash


CLUSTER_NAME="Wordpress-Cluster"
OLD_SERVICE_NAME="wordpress-service"
SERVICE_NAME="wordpress-service"
TASK_DEF_NAME="helloworld-td"
TASK_FAMILY="helloworld-td"

# SUBNET_ID="subnet-xxxxxx"  # Replace with a real subnet ID


echo "🔍 Getting latest task definition ARN..."
NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition "$TASK_FAMILY" \
  --query "taskDefinition.taskDefinitionArn" \
  --output text)


echo "🚀 Updating service to use: $NEW_TASK_DEF"
ECS_UPDATE_SERVICE_OUTPUT=$(aws ecs update-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --task-definition "$NEW_TASK_DEF")

#echo "⏳ Waiting for deployment to complete..."
#ECS_UPDATE_SERVICE_OUTPUT=$(aws ecs wait services-stable \
#  --cluster "$CLUSTER_NAME" \
#  --services "$SERVICE_NAME")

echo "⏳ Waiting for ECS service deployment to stabilize..."

while true; do
  STATUS=$(aws ecs describe-services \
    --cluster "$CLUSTER_NAME" \
    --services "$SERVICE_NAME" \
    --query 'services[0].deployments[?status==`PRIMARY`].rolloutState' \
    --output text)

  if [[ "$STATUS" == "COMPLETED" ]]; then
    echo "✅ Deployment completed."
    break
  fi

  if [[ "$STATUS" == "FAILED" ]]; then
    echo "❌ Deployment failed!"
    exit 1
  fi

  echo "⌛ Current rollout state: $STATUS... waiting 10s"
  sleep 10
done  

echo "✅ Service updated successfully."
