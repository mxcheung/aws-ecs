# Quick start

```
git clone https://github.com/mxcheung/aws-ecs.git
export aws_access_key_id=AKIAVOxxx
export aws_secret_access_key=qC8VQTxxxxxxxxxxxxx
cd /home/ec2-user/environment/aws-ecs/
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/user_credentials
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/security_group
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/rds
nohup bash ./set_up.sh  > /home/ec2-user/environment/aws-ecs/word_press_ecs/rds/set_up.log 2>&1 &
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs
. ./set_up.sh
```
