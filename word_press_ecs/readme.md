# Quick start

```
git clone https://github.com/mxcheung/aws-ecs.git
export aws_access_key_id=AKIAZXXXXXXXXX
export aws_secret_access_key=rjQ68lnGFhjezzzzzzzzzzzzzzzzzzz
cd /home/ec2-user/environment/aws-ecs/
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/user_credentials
. ./set_up.sh
aws logs create-log-group --log-group-name /ecs/wordpress-td
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/networks
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/rds
nohup bash ./set_up.sh  > /home/ec2-user/environment/aws-ecs/word_press_ecs/rds/set_up.log 2>&1 &
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs-cluster
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecr
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs-task-definition
. ./set_up.sh
cd /home/ec2-user/environment/aws-ecs/word_press_ecs/ecs
. ./set_up.sh

```

# Test RDS Connection Cloud 9
```
cloud_user:~/environment/aws-ecs/word_press_ecs/rds (main) $ sudo yum -y install telnet

cloud_user:~/environment/aws-ecs/word_press_ecs/rds (main) $ telnet wordpress.cw86n944zjs4.us-east-1.rds.amazonaws.com 3306
Trying 10.0.20.160...
Connected to wordpress.cw86n944zjs4.us-east-1.rds.amazonaws.com.
Escape character is '^]'.
J
```

```
cloud_user:~/environment/aws-ecs/word_press_ecs/rds (main) $ mysql --user=admin --password  -h wordpress.xxxxxx.us-east-1.rds.amazonaws.com
Enter password: 
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MySQL connection id is 35
Server version: 8.0.35 Source distribution

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MySQL [(none)]>
```

# Reference
https://github.com/pluralsight-cloud/aws-certified-solutions-architect-associate/tree/main/bootcamp-hands-on-labs/04-week-4/4.3%20-%20Hosting%20a%20Wordpress%20Application%20on%20ECS%20Fargate%20with%20RDS%20DB%20and%20Parameter%20Store
