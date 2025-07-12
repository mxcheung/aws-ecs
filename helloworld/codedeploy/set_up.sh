#!/bin/bash

# a) create application
CODEDEPLOY_CREATE_APP=$(aws deploy create-application \
  --application-name hello-ecs-app \
  --compute-platform ECS)

# b) create deployment group (blue/green example)
CODEDEPLOY_CREATE_DEPLOY_GROUP=$(aws deploy create-deployment-group \
  --application-name hello-ecs-app \
  --deployment-group-name hello-ecs-dg \
  --service-role-arn arn:aws:iam::$ACCOUNT_ID:role/CodeDeployECSRole \
  --deployment-type BLUE_GREEN \
  --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
  --ecs-services "name=hello-ecs-service,clusterName=hello-ecs-cluster" \
  --load-balancer-info "targetGroupPairInfoList=[{targetGroups=[{name=blue-tg},{name=green-tg}],prodTrafficRoute={listenerArns=[arn:aws:elasticloadbalancing:...listener/yourAlbListenerArn]}}]")
