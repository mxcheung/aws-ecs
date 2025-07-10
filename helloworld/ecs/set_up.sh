#!/bin/bash

NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition my-task \
  --query 'taskDefinition.taskDefinitionArn' \
  --output text)
