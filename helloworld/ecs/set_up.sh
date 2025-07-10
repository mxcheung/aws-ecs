#!/bin/bash

# Register or get the new task definition
NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition helloword-td  \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

# Update the ECS service to use the new task definition
aws ecs update-service \
  --cluster my-cluster \
  --service my-service \
  --task-definition "$NEW_TASK_DEF"
