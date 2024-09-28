#!/bin/bash

cd /home/cloudshell-user/aws-ecs/word_press_ecs/user_credentials
. ./set_up.sh

sleep 5 # Waits 5 seconds.

aws logs create-log-group --log-group-name /ecs/wordpress-td
cd /home/cloudshell-user/aws-ecs/word_press_ecs/networks
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/rds
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/s3
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecs-cluster
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecs-task-definition
. ./set_up.sh
cd /home/cloudshell-user/aws-ecs/word_press_ecs/ecs
. ./set_up.sh
