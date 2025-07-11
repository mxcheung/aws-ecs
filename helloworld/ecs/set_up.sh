#!/bin/bash

# Register or get the new task definition
NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition helloword-td  \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)

# Update the ECS service to use the new task definition
ECS_UPDATE_OUTPUT=$(aws ecs update-service \
  --cluster Wordpress-Cluster  \
  --service wordpress-service \
  --task-definition "$NEW_TASK_DEF")
  


