#!/bin/bash

echo $MY_ENV_ROOT_DIR
echo $AWS_ACCESS_KEY_ID

cd $MY_ENV_ROOT_DIR/user_credentials
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/iam
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/codecommit
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/ecr
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/s3
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/codebuild
. ./set_up.sh

cd $MY_ENV_ROOT_DIR/codepipeline
. ./set_up.sh
