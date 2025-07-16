import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import { CodePipeline, CodePipelineSource, ShellStep } from 'aws-cdk-lib/pipelines';
import { EcsStack } from './ecs-stack';

export class PipelineStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const repoName = 'demo-java-ecs-app'; // existing CodeCommit repo

    const repo = codecommit.Repository.fromRepositoryName(this, 'CodeCommitRepo', repoName);

    // Import existing ECR repo
    const existingRepo = ecr.Repository.fromRepositoryName(this, 'ExistingEcrRepo', 'java-app-repo');

    const pipeline = new CodePipeline(this, 'Pipeline', {
      pipelineName: 'JavaEcsCrossAccountPipeline',
      synth: new ShellStep('Synth', {
        input: CodePipelineSource.codeCommit(repo, 'main'),
        commands: [
          'npm ci',
          'npm run build',
          'npx cdk synth',
        ],
        primaryOutputDirectory: 'cdk.out',
      }),
    });

    pipeline.addStage(new EcsDeployStage(this, 'DeployToAccountB', {
      env: { account: '222222222222', region: 'ap-southeast-2' },
    }));

    // Optional: output ECR URI
    new cdk.CfnOutput(this, 'EcrRepoUri', {
      value: existingRepo.repositoryUri,
    });
  }
}

class EcsDeployStage extends cdk.Stage {
  constructor(scope: Construct, id: string, props?: cdk.StageProps) {
    super(scope, id, props);
    new EcsStack(this, 'EcsStack', props);
  }
}
