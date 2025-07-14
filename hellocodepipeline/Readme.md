# Introduction
✅ Use CodeBuild + aws ecs update-service
You can:

Build and push the Docker image

Register a new task definition revision

Update the ECS service with aws ecs update-service
→ all directly from CodeBuild, no CodeDeploy required.

This project aims to
 - Build container image via codecommit
 - Storage container image via new ecr repo. 
 - Create new task definition with new image
 - Update ECS service with new task definition.

# Code build prerequisites
 - Add buildspec.yml
 - Add taskdef.json
 - Add codebuild-hello-ecs-role      # Required to build docker image
 - Add codepipeline-hello-ecs-role
 - Add hello-ecs-build
 - Delete docker_build               # Manual build docker image
 - Delete ecs-task-definition        # Manual define task definition
 - Delete ecs                        # Manual update ecs service
 - Delete start                      # Manual start build

# Codepipeline prerequisites
- Add S3                             # Required for code build artifacts
- Add Codepipeline
- Add codepipeline-hello-ecs-role    # Required to run codepipeline


# Event Bridge prerequisites
- Add SQS                                     # Required for eventbridge-dlq
- Add Codepipeline
- Add EventBridge_Invoke_CodePipeline_Role    # Required to trigger codepipeline
- Add eventbridge-dlq                         # Dead‑letter queue (DLQ) for EventBridge


# Summary 
Piece	What it does
CodeCommit   	holds your application + Dockerfile
CodeBuild	    builds the image, pushes to ECR, creates imagedefinitions.json
CodePipeline	Source → Build → Deploy
ECS (rolling‑update)	service replaces tasks in‑place; no CodeDeploy, no blue/green

# Expect results

```
http://ourapplicationloadbalancer-293886622.us-east-1.elb.amazonaws.com/
Hello Code Build with ECS Rolling Update from Flask on ECS!
https://us-east-1.console.aws.amazon.com/codesuite/codebuild/400874991066/projects/hello-ecs-build


[Container] 2025/07/13 05:34:54.773369 Running command echo Build completed successfully. Image $IMAGE_URI
Build completed successfully. Image 400874991066.dkr.ecr.us-east-1.amazonaws.com/hello-ecs:latest
[Container] 2025/07/13 05:34:56.980581 Report auto-discover file discovery took 0.005648 seconds
[Container] 2025/07/13 05:34:56.980623 Phase complete: UPLOAD_ARTIFACTS State: SUCCEEDED
[Container] 2025/07/13 05:34:56.980630 Phase context status code:  Message: 

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
export MY_ENV_DIR="$HOME/environment"
export MY_ENV_ROOT_DIR="$HOME/environment/aws-ecs/hellocodepipeline"
cd $MY_ENV_DIR/aws-ecs/word_press_ecs/
. ./set_up.sh

cd $MY_ENV_ROOT_DIR
. ./set_up.sh

```

# Hellocodebuild in cloud 9
```
screen -S myscript
export AWS_ACCESS_KEY_ID=xxxxxxxxxxxxxxxxxxx
export AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
export MY_ENV_DIR="$HOME/environment"
export MY_ENV_ROOT_DIR="$HOME/environment/aws-ecs/hellocodepipeline/"
cd $MY_ENV_ROOT_DIR
. ./set_up.sh  2>&1 | tee script.log


. ./set_up.sh
```
# Cloud watch log

```
2025-07-10T13:23:09.192Z    Hello, world from CodeCommit and ECS!
```

# Security
```
 Creating IAM Role: codebuild-hello-ecs-role
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/CloudWatchLogsFullAccess
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/AWSCodeCommitReadOnly
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/AmazonECS_FullAccess
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
🔐 Attaching policy to codebuild-hello-ecs-role: arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess
🚀 Creating IAM Role: codepipeline-hello-ecs-role

🔐 Adding inline policy to codepipeline-hello-ecs-role for CodeCommit access

🔐 Attaching policy to eventbridge-hello-ecs-role: arn:aws:codepipeline:us-east-1:036912808834:hello-ecs-pipeline to allow StartPipelineExecution

✅ IAM roles successfully created and configured.

```
# Event Bridge Trigger
```
Creating EventBridge rule CodeCommitPushTriggerRule...
EventBridge rule created: arn:aws:events:us-east-1:036912808834:rule/CodeCommitPushTriggerRule

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

# Summary
✅ Summary
Action	Tool
Build & push Docker image	Docker + ECR
Register task definition	aws ecs register-task-definition
Update ECS service	aws ecs update-service
No CodeDeploy needed	✅