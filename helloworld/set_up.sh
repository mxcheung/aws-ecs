#!/bin/bash

echo $MY_ENV_DIR
echo $AWS_ACCESS_KEY_ID

codecommit/set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/codecommit
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/ecr
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/helloworld/docker_build
. ./set_up.sh
