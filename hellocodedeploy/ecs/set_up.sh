#!/bin/bash


CLUSTER_NAME="Wordpress-Cluster"
OLD_SERVICE_NAME="wordpress-service"
SERVICE_NAME="wordpress-service"
TASK_DEF_NAME="helloworld-td"
TASK_FAMILY="helloworld-td"
SLEEP_SECONDS=10
MAX_EVENTS=5   # how many events to print each loop

# SUBNET_ID="subnet-xxxxxx"  # Replace with a real subnet ID


echo "🔍 Getting latest task definition ARN..."
NEW_TASK_DEF=$(aws ecs describe-task-definition \
  --task-definition "$TASK_FAMILY" \
  --query "taskDefinition.taskDefinitionArn" \
  --output text)

AWS_DELETE_SERVICE=$(aws ecs delete-service \
  --cluster "$CLUSTER_NAME" \
  --service "$SERVICE_NAME" \
  --force)


# Get Subnet ID for Private Subnet AZ A
subnet_a=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ A" "Name=availability-zone,Values=us-east-1a" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Private Subnet AZ B
subnet_b=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ B" "Name=availability-zone,Values=us-east-1b" \
    --query "Subnets[0].SubnetId" --output text)

# Get Subnet ID for Private Subnet AZ C
subnet_c=$(aws ec2 describe-subnets \
    --filters "Name=tag:Name,Values=Private Subnet AZ C" "Name=availability-zone,Values=us-east-1c" \
    --query "Subnets[0].SubnetId" --output text)


APP_SG_ID_2=$(aws ec2 describe-security-groups --filters Name=group-name,Values=app-sg --query "SecurityGroups[0].GroupId" --output text)

echo $APP_SG_ID_2


TARGET_GROUP_ARN=$(aws elbv2 describe-target-groups --names wordpress-tg --query "TargetGroups[0].TargetGroupArn" --output text)

echo $TARGET_GROUP_ARN

CONTAINER_NAME="wordpress"
CONTAINER_PORT=80

ECS_CREATE_SERVICE_OUTPUT=$(aws ecs create-service \
  --cluster Wordpress-Cluster \
  --service-name hello-ecs-service \
  --task-definition "$NEW_TASK_DEF" \
  --load-balancers "targetGroupArn=$TARGET_GROUP_ARN,containerName=$CONTAINER_NAME,containerPort=$CONTAINER_PORT" \
  --launch-type FARGATE \
  --deployment-controller type=CODE_DEPLOY \
  --desired-count 1 \
  --network-configuration "awsvpcConfiguration={subnets=[$subnet_a,$subnet_b,$subnet_c],securityGroups=[$APP_SG_ID_2],assignPublicIp=ENABLED}"
)
 

#echo "⏳ Waiting for deployment to complete..."
#ECS_UPDATE_SERVICE_OUTPUT=$(aws ecs wait services-stable \
#  --cluster "$CLUSTER_NAME" \
#  --services "$SERVICE_NAME")

echo "⏳ Waiting for ECS service deployment to stabilize..."
while true; do
  # Get rollout state of the PRIMARY deployment
  ROLLOUT_STATE=$(aws ecs describe-services \
      --cluster "$CLUSTER_NAME" \
      --services "$SERVICE_NAME" \
      --query 'services[0].deployments[?status==`PRIMARY`].rolloutState' \
      --output text)

  # Fetch recent events (time stamp, id, message)
  read -r -d '' EVENTS <<<"$(aws ecs describe-services \
      --cluster "$CLUSTER_NAME" \
      --services "$SERVICE_NAME" \
      --query "services[0].events[0:${MAX_EVENTS}].[createdAt, id, message]" \
      --output text)"

  # Render events like the console
  printf "\n%-8s %-27s %-40s %s\n" "EVENTS" "TIMESTAMP" "ID" "MESSAGE"
  echo "$EVENTS" | while IFS=$'\t' read -r TS ID MSG; do
      printf "%-8s %-27s %-40s %s\n" "EVENTS" "$TS" "$ID" "$MSG"
  done

  # Decide what to do based on rollout state
  if [[ "$ROLLOUT_STATE" == "COMPLETED" ]]; then
      echo -e "\n✅ Deployment completed.\n"
      break
  elif [[ "$ROLLOUT_STATE" == "FAILED" ]]; then
      echo -e "\n❌ Deployment failed! See events above.\n"
      exit 1
  else
      echo -e "\n⌛ Rollout state: $ROLLOUT_STATE – checking again in ${SLEEP_SECONDS}s…"
      sleep "$SLEEP_SECONDS"
  fi
done

echo "✅ Service updated successfully."
