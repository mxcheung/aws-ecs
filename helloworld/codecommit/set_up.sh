#!/bin/bash


aws codecommit create-repository --repository-name hello-ecs

cp -r $MY_ENV_DIR/aws-ecs/helloworld/hello-ecs/* .


git add .
git commit -m "Initial commit: Python ECS hello app"
git push --set-upstream origin main

