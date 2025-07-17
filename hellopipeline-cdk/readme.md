

```
export MY_ENV_DIR="$HOME/environment"
export MY_ENV_ROOT_DIR="$HOME/environment/aws-ecs
cd $MY_ENV_ROOT_DIR
mkdir HelloPipeline
cd $MY_ENV_ROOT_DIR/HelloPipeline
npm install -g aws-cdk@latest
cdk init app --language typescript
npm install @aws-cdk/aws-ecs @aws-cdk/aws-codebuild @aws-cdk/aws-codepipeline @aws-cdk/aws-codepipeline-actions @aws-cdk/aws-ecr @aws-cdk/aws-iam @aws-cdk/aws-s3

```
