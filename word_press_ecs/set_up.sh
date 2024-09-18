#!/bin/bash

cd /home/ec2-user/environment/aws-ecs/word_press_ecs/user_credentials
. ./set_up.sh
aws logs create-log-group --log-group-name /ecs/wordpress-td
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/networks
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/rds
. ./set_up.sh  
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs-cluster
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs-task-definition
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs
. ./set_up.sh
