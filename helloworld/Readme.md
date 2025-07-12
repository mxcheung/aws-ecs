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
cd $MY_ENV_DIR/aws_mysql_bulkload/
source envvars.sh
echo "$DB_HOST"
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
 Task definition helloworld-td registered.
cloud_user:~/environment/aws-ecs/helloworld/ecs-task-definition (main) $ 
cloud_user:~/environment/aws-ecs/helloworld/ecs-task-definition (main) $ cd $MY_ENV_DIR/aws-ecs/helloworld/ecs
cloud_user:~/environment/aws-ecs/helloworld/ecs (main) $ . ./set_up.sh
🔍 Getting latest task definition ARN...
🚀 Updating service to use: arn:aws:ecs:us-east-1:850576533876:task-definition/helloworld-td:8
⏳ Waiting for ECS service deployment to stabilize...
⌛ Current rollout state: IN_PROGRESS... waiting 10s
⌛ Current rollout state: IN_PROGRESS... waiting 10s
```
