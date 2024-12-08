#!/bin/bash

cd /home/cloudshell-user/aws-ecs/robot/user_credentials
. ./set_up.sh
aws logs create-log-group --log-group-name /ecs/robot-td
cd /home/cloudshell-user/aws-ecs/robot/ecs-cluster
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecs-task-definition
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecs
. ./set_up.sh
