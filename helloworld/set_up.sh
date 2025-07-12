#!/bin/bash

echo $MY_ENV_DIR
echo $AWS_ACCESS_KEY_ID

cd $MY_ENV_DIR/aws-ecs/helloworld/user_credentials
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/iam
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/codecommit
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/ecr
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/codebuild
. ./set_up.sh


cd $MY_ENV_DIR/aws-ecs/helloworld/docker_build
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/ecs-task-definition
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/ecs
. ./set_up.sh
