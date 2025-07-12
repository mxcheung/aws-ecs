#!/bin/bash
set -euo pipefail

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
APPLICATION_NAME="hello-ecs-app"
DEPLOYMENT_GROUP_NAME="hello-ecs-dg"
SERVICE_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/CodeDeployECSRole"
ECS_CLUSTER_NAME="Wordpress-Cluster"
ECS_SERVICE_NAME="wordpress-service"
ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:$REGION:$AWS_ACCOUNT_ID:listener/app/your-alb/your-listener-id"
BLUE_TG_NAME="ecs-blue-tg"
GREEN_TG_NAME="ecs-green-tg"

echo "🔐 Using AWS Account: $AWS_ACCOUNT_ID"

# Create CodeDeploy application
echo "📦 Creating CodeDeploy application..."
AWS_CODE_DEPLOY_APP=$(aws deploy create-application \
  --application-name hello-ecs-app \
  --compute-platform ECS)

echo "🔐 Using AWS CodeDeploy application: $AWS_CODE_DEPLOY_APP"

# Create CodeDeploy deployment group
echo "🚀 Creating ECS deployment group: $DEPLOYMENT_GROUP_NAME"



aws deploy create-deployment-group \
  --application-name "$APPLICATION_NAME" \
  --deployment-group-name "$DEPLOYMENT_GROUP_NAME" \
  --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
  --service-role-arn "$SERVICE_ROLE_ARN" \
  --deployment-style deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL \
  --blue-green-deployment-configuration "$(cat <<EOF
{
  "terminateBlueInstancesOnDeploymentSuccess": {
    "action": "TERMINATE",
    "terminationWaitTimeInMinutes": 5
  },
  "deploymentReadyOption": {
    "actionOnTimeout": "CONTINUE_DEPLOYMENT",
    "waitTimeInMinutes": 0
  },
  "greenFleetProvisioningOption": {
    "action": "DISCOVER_EXISTING"
  }
}
EOF
)" \
  --ecs-services "[{\"serviceName\":\"$ECS_SERVICE_NAME\",\"clusterName\":\"$ECS_CLUSTER_NAME\"}]" \
  --load-balancer-info "$(cat <<EOF
{
  "targetGroupPairInfoList": [
    {
      "targetGroups": [
        { "name": "$BLUE_TG_NAME" },
        { "name": "$GREEN_TG_NAME" }
      ],
      "prodTrafficRoute": {
        "listenerArns": [
          "$ALB_LISTENER_ARN"
        ]
      }
    }
  ]
}
EOF
)"

echo "✅ CodeDeploy setup complete."
