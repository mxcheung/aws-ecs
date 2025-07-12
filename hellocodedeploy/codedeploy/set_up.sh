#!/bin/bash
set -euo pipefail

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"
APPLICATION_NAME="hello-ecs-app"
DEPLOYMENT_GROUP_NAME="hello-ecs-dg"
SERVICE_ROLE_ARN="arn:aws:iam::$AWS_ACCOUNT_ID:role/CodeDeployECSRole"
ECS_CLUSTER_NAME="Wordpress-Cluster"
ECS_SERVICE_NAME="hello-ecs-service"
#ALB_LISTENER_ARN="arn:aws:elasticloadbalancing:$REGION:$AWS_ACCOUNT_ID:loadbalancer/app/your-alb/your-listener-id"
BLUE_TG_NAME="ecs-blue-tg"
GREEN_TG_NAME="ecs-green-tg"

TARGET_GROUP_NAME="wordpress-tg"
TASK_DEFINITION="helloworld-td:2"
CONTAINER_NAME="wordpress"
CONTAINER_PORT="80"

ALB_NAME="OurApplicationLoadBalancer"
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --query "LoadBalancers[?LoadBalancerName=='$ALB_NAME'].LoadBalancerArn" \
  --output text)

ALB_LISTENER_ARN=$(aws elbv2 describe-listeners \
  --load-balancer-arn  $ALB_ARN \
  --query "Listeners[*].ListenerArn" \
  --output text)


echo "🔐 Using AWS Account: $AWS_ACCOUNT_ID"

echo "🔐 Using ALB_LISTENER_ARN: $ALB_LISTENER_ARN"


# Create CodeDeploy application
echo "📦 Creating CodeDeploy application..."
AWS_CODE_DEPLOY_APP=$(aws deploy create-application \
  --application-name hello-ecs-app \
  --compute-platform ECS)

echo "🔐 Using AWS CodeDeploy application: $AWS_CODE_DEPLOY_APP"

# Create CodeDeploy deployment group
echo "🚀 Creating ECS deployment group: $DEPLOYMENT_GROUP_NAME"


cat > lb-info.json <<EOF
{
  "targetGroupInfoList": [
    { "name": "${TARGET_GROUP_NAME}" }
  ]
}
EOF


# Create the deployment group without blue/green
AWS_CODE_DEPLOY_GROUP=$(aws deploy create-deployment-group \
  --application-name "$APPLICATION_NAME" \
  --deployment-group-name "$DEPLOYMENT_GROUP_NAME" \
  --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
  --service-role-arn "$SERVICE_ROLE_ARN" \
  --ecs-services "[{\"serviceName\":\"$ECS_SERVICE_NAME\",\"clusterName\":\"$ECS_CLUSTER_NAME\"}]" \
  --load-balancer-info      file://lb-info.json
)

echo "🔐 AWS_CODE_DEPLOY_GROUP: $AWS_CODE_DEPLOY_GROUP"


# Create the AppSpec content as plain YAML
APPSPEC_YAML=$(cat <<EOF
version: 1
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: $TASK_DEFINITION
        LoadBalancerInfo:
          ContainerName: $CONTAINER_NAME
          ContainerPort: $CONTAINER_PORT
EOF
)

# Convert YAML content to JSON-safe string
ENCODED_CONTENT=$(echo "$APPSPEC_YAML" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

# Run the deployment command
AWS_CREATE_DEPLOYMENT=$(aws deploy create-deployment \
  --application-name "$APPLICATION_NAME" \
  --deployment-group-name "$DEPLOYMENT_GROUP_NAME" \
  --revision "{
    \"revisionType\": \"AppSpecContent\",
    \"appSpecContent\": {
      \"content\": $ENCODED_CONTENT
    }
  }")

echo "🔐 AWS_CREATE_DEPLOYMENT: $AWS_CREATE_DEPLOYMENT"


echo "✅ CodeDeploy setup complete."
