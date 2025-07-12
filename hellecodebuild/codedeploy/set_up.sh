#!/bin/bash
set -euo pipefail

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "🔐 Using AWS Account: $AWS_ACCOUNT_ID"

# Create CodeDeploy application
echo "📦 Creating CodeDeploy application..."
AWS_CODE_DEPLOY_APP=$(aws deploy create-application \
  --application-name hello-ecs-app \
  --compute-platform ECS)

echo "🔐 Using AWS CodeDeploy application: $AWS_CODE_DEPLOY_APP"

# Create CodeDeploy deployment group
echo "🚀 Creating CodeDeploy deployment group..."

aws deploy create-deployment-group \
  --application-name hello-ecs-app \
  --deployment-group-name hello-ecs-dg \
  --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
  --service-role-arn arn:aws:iam::$AWS_ACCOUNT_ID:role/CodeDeployECSRole \
  --deployment-style deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL \
  --blue-green-deployment-configuration '{
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
    }' \
  --ecs-services '[{"serviceName":"hello-ecs-service","clusterName":"hello-ecs-cluster"}]' \
  --load-balancer-info "{
      \"targetGroupPairInfoList\": [
        {
          \"targetGroups\": [
            { \"name\": \"ecs-blue-tg\" },
            { \"name\": \"ecs-green-tg\" }
          ],
          \"prodTrafficRoute\": {
            \"listenerArns\": [
              \"arn:aws:elasticloadbalancing:us-east-1:$AWS_ACCOUNT_ID:listener/app/your-alb/your-listener-id\"
            ]
          }
        }
      ]
    }"

echo "✅ CodeDeploy setup complete."
