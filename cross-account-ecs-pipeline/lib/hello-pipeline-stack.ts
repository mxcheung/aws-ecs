import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as cpactions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';

interface HelloPipelineStackProps extends cdk.StackProps {
  dpRegion: string;
  ecrRepoName: string;
  codeCommitRepoName: string;
}

export class HelloPipelineStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: HelloPipelineStackProps) {
    super(scope, id, props);

    const repo = codecommit.Repository.fromRepositoryName(this, 'CodeCommitRepo', props.codeCommitRepoName);

    const sourceOutput = new codepipeline.Artifact();
    const buildOutput = new codepipeline.Artifact();

    // CodeBuild project
    const buildProject = new codebuild.PipelineProject(this, 'BuildProject', {
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
        privileged: true,
      },
      environmentVariables: {
        ECR_REPO: { value: props.ecrRepoName },
        AWS_DEFAULT_REGION: { value: props.dpRegion },
      },
      buildSpec: codebuild.BuildSpec.fromObject({
        version: '0.2',
        phases: {
          pre_build: {
            commands: [
              'echo Logging in to Amazon ECR...',
              'aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com',
            ],
          },
          build: {
            commands: [
              'docker build -t $ECR_REPO:latest .',
              'docker tag $ECR_REPO:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO:latest',
              'docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com/$ECR_REPO:latest',
            ],
          },
        },
        artifacts: {
          files: ['imagedefinitions.json'],
          'discard-paths': 'yes',
        },
      }),
    });

    // Pipeline definition
    new codepipeline.Pipeline(this, 'Pipeline', {
      pipelineName: 'HelloDockerPipeline',
      stages: [
        {
          stageName: 'Source',
          actions: [
            new cpactions.CodeCommitSourceAction({
              actionName: 'CodeCommit_Source',
              repository: repo,
              branch: 'main',
              output: sourceOutput,
            }),
          ],
        },
        {
          stageName: 'Build',
          actions: [
            new cpactions.CodeBuildAction({
              actionName: 'Docker_Build',
              project: buildProject,
              input: sourceOutput,
              outputs: [buildOutput],
            }),
          ],
        },
      ],
    });
  }
}
