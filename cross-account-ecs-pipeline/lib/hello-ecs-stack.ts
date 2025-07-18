import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as logs from 'aws-cdk-lib/aws-logs';

interface HelloEcsStackProps extends cdk.StackProps {
  vpcName: string;
  dpAccountId: string;
  dpRegion: string;
  ecrRepoName: string;
}

export class HelloEcsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: HelloEcsStackProps) {
    super(scope, id, props);

    const vpc = ec2.Vpc.fromLookup(this, 'Vpc', { vpcName: props.vpcName });

    const cluster = new ecs.Cluster(this, 'Cluster', { vpc });

    // Import ECR repo from dp account by ARN (cross-account)
    const ecrRepoArn = `arn:aws:ecr:${props.dpRegion}:${props.dpAccountId}:repository/${props.ecrRepoName}`;
    const ecrRepo = ecr.Repository.fromRepositoryArn(this, 'CrossAccountEcrRepo', ecrRepoArn);

    const taskDef = new ecs.FargateTaskDefinition(this, 'TaskDef', {
      cpu: 1024,
      memoryLimitMiB: 3072,
    });

    taskDef.addContainer('AppContainer', {
      image: ecs.ContainerImage.fromEcrRepository(ecrRepo, 'latest'),
      memoryLimitMiB: 3072,
      logging: ecs.LogDriver.awsLogs({
        streamPrefix: 'AppLogs',
        logRetention: logs.RetentionDays.ONE_WEEK,
      }),
      environment: {
        NODE_ENV: 'production',
        APP_ENV: 'dt',
      },
      portMappings: [{ containerPort: 3000 }],
    });

    new ecs.FargateService(this, 'Service', {
      cluster,
      taskDefinition: taskDef,
      desiredCount: 2,
    });
  }
}
