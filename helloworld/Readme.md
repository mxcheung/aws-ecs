# Introduction
This project aims to
 - Build container image via codecommit
 - Storage container image via new ecr repo. 
 - Create new task definition with new image
 - Update ECS service with new task definition.

# Completed Result

```
http://ourapplicationloadbalancer-1246702962.us-east-1.elb.amazonaws.com/
Hello World from Flask on ECS!
```


# Bootstrap
Use existing project ECS aws-ecs Wordpress to bootstrap a fully working ECS deployment.

# Quick start 
Use existing project for scaffold in ECS - Word press

This project focus building python helloword app and deloy to ECS

```
response=$(aws iam create-access-key --output json)

# Write the response to a JSON file
echo "$response" > access-key-response.json

# Extract AccessKeyId and SecretAccessKey from the response file
access_key_id=$(jq -r '.AccessKey.AccessKeyId' access-key-response.json)
secret_access_key=$(jq -r '.AccessKey.SecretAccessKey' access-key-response.json)

# Print the extracted values (optional)
echo "AccessKeyId: $access_key_id"
echo "SecretAccessKey: $secret_access_key"

```

# Create ECS cluster in cloud 9
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
git clone https://github.com/mxcheung/aws-ecs.git
git clone https://github.com/mxcheung/aws_mysql_bulkload.git
export MY_ENV_DIR="$HOME/environment"
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/
. ./set_up.sh
# cd $MY_ENV_DIR/aws_mysql_bulkload/
# source envvars.sh
# echo "$DB_HOST"
# . ./set_up.sh
cd $MY_ENV_DIR/aws-ecs/helloworld/
. ./set_up.sh

```

# Helloworld in cloud 9
```
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
export MY_ENV_DIR="$HOME/environment"
cd $MY_ENV_DIR/aws-ecs/helloworld/
. ./set_up.sh
```
# Cloud watch log

```
2025-07-10T13:23:09.192Z    Hello, world from CodeCommit and ECS!
```


# ECS Deployment
```
🔍 Getting latest task definition ARN...
🚀 Updating service to use: arn:aws:ecs:us-east-1:850576533876:task-definition/helloworld-td:10
⏳ Waiting for ECS service deployment to stabilize...

EVENTS   TIMESTAMP                   ID                                       MESSAGE
EVENTS   2025-07-12T04:25:42.978000+00:00 f9a9f036-e702-41fd-b909-6e83c940c92e     (service wordpress-service, taskSet ecs-svc/4034032221499882557) has begun draining connections on 1 tasks.
EVENTS   2025-07-12T04:25:42.974000+00:00 c2757223-51e9-49e9-8278-9fa8ed63c0a2     (service wordpress-service) deregistered 1 targets in (target-group arn:aws:elasticloadbalancing:us-east-1:850576533876:targetgroup/wordpress-tg/a12a24f1cb3ecdb0)
EVENTS   2025-07-12T04:25:32.630000+00:00 544b06c0-c979-4f67-97d4-58292f57c288     (service wordpress-service) has stopped 1 running tasks: (task 218dcf0765ba4c97a2eeb1f06a0e913b).
EVENTS   2025-07-12T04:24:42.635000+00:00 0d13563b-8dfe-4125-8076-5ef1e1e25e94     (service wordpress-service) registered 1 targets in (target-group arn:aws:elasticloadbalancing:us-east-1:850576533876:targetgroup/wordpress-tg/a12a24f1cb3ecdb0)
EVENTS   2025-07-12T04:24:22.779000+00:00 a0a9b534-b087-4bd8-b54f-52266a8f93e0     (service wordpress-service) has started 1 tasks: (task 2c47373308424022880765916ed57a9d).

 Rollout state: IN_PROGRESS – checking again in 10s…

EVENTS   TIMESTAMP                   ID                                       MESSAGE
EVENTS   2025-07-12T04:26:44.270000+00:00 0e5c8d0d-6fa3-402b-a475-586eff5f3b1e     (service wordpress-service) has started 1 tasks: (task 916b9b68e6b441d9a1049958af5c0833).
EVENTS   2025-07-12T04:25:42.978000+00:00 f9a9f036-e702-41fd-b909-6e83c940c92e     (service wordpress-service, taskSet ecs-svc/4034032221499882557) has begun draining connections on 1 tasks.
EVENTS   2025-07-12T04:25:42.974000+00:00 c2757223-51e9-49e9-8278-9fa8ed63c0a2     (service wordpress-service) deregistered 1 targets in (target-group arn:aws:elasticloadbalancing:us-east-1:850576533876:targetgroup/wordpress-tg/a12a24f1cb3ecdb0)
EVENTS   2025-07-12T04:25:32.630000+00:00 544b06c0-c979-4f67-97d4-58292f57c288     (service wordpress-service) has stopped 1 running tasks: (task 218dcf0765ba4c97a2eeb1f06a0e913b).
EVENTS   2025-07-12T04:24:42.635000+00:00 0d13563b-8dfe-4125-8076-5ef1e1e25e94     (service wordpress-service) registered 1 targets in (target-group arn:aws:elasticloadbalancing:us-east-1:850576533876:targetgroup/wordpress-tg/a12a24f1cb3ecdb0)

```
