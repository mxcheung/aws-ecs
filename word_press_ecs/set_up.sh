#!/bin/bash

echo $MY_ENV_DIR
echo $AWS_ACCESS_KEY_ID


#cd $MY_ENV_DIR/aws-ecs/word_press_ecs/user_credentials
#. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/aws-profile
. ./set_up.sh
aws logs create-log-group --log-group-name /ecs/wordpress-td
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/security_group
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/networks
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/rds
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/s3
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/ecs-cluster
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/word_press_ecs/aws-profile
. ./set_up.sh

cd $MY_ENV_DIR/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/ecs-task-definition
. ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/ecs
. ./set_up.sh
