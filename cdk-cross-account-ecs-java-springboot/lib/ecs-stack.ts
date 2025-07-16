import * as cdk from 'aws-cdk-lib';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import { Construct } from 'constructs';

export class EcsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = new ec2.Vpc(this, 'Vpc', { maxAzs: 2 });

    const cluster = new ecs.Cluster(this, 'Cluster', { vpc });

    const taskDef = new ecs.FargateTaskDefinition(this, 'TaskDef', {
      cpu: 512,
      memoryLimitMiB: 1024,
    });

    taskDef.addContainer('JavaAppContainer', {
      image: ecs.ContainerImage.fromRegistry(
        '111111111111.dkr.ecr.ap-southeast-2.amazonaws.com/java-app-repo:latest'
      ),
      portMappings: [{ containerPort: 8080 }],
      logging: ecs.LogDrivers.awsLogs({ streamPrefix: 'JavaApp' }),
    });

    new ecs.FargateService(this, 'FargateService', {
      cluster,
      taskDefinition: taskDef,
      desiredCount: 1,
      assignPublicIp: true,
    });
  }
}
