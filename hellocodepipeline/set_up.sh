#!/bin/bash

set -euo pipefail

trap 'echo "❌ Script failed at line $LINENO. Exiting."' ERR

echo $MY_ENV_ROOT_DIR
echo $AWS_ACCESS_KEY_ID

cd $MY_ENV_ROOT_DIR/user_credentials
. ./set_up.sh  2>&1 | tee script.log

cd $MY_ENV_ROOT_DIR/iam
. ./set_up.sh   2>&1 | tee script.log

cd $MY_ENV_ROOT_DIR/codecommit
. ./set_up.sh  2>&1 | tee script.log

cd $MY_ENV_ROOT_DIR/ecr
. ./set_up.sh 2>&1 | tee script.log


cd $MY_ENV_ROOT_DIR/s3
. ./set_up.sh 2>&1 | tee script.log

cd $MY_ENV_ROOT_DIR/sqs
. ./set_up.sh 2>&1 | tee script.log

cd $MY_ENV_ROOT_DIR/codebuild
. ./set_up.sh 2>&1 | tee script.log


cd $MY_ENV_ROOT_DIR/codepipeline
. ./set_up.sh 2>&1 | tee script.log


cd $MY_ENV_ROOT_DIR/event_bridge
. ./set_up.sh 2>&1 | tee script.log

