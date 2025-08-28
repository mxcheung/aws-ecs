import * as cdk from 'aws-cdk-lib';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';

export class EcsServiceScalingStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = ec2.Vpc.fromLookup(this, 'Vpc', {
      isDefault: true,
    });

    const cluster = ecs.Cluster.fromClusterAttributes(this, 'ExistingCluster', {
      clusterName: 'my-existing-cluster',
      vpc,
      securityGroups: [],
    });

    const service = ecs.FargateService.fromFargateServiceAttributes(this, 'ExistingService', {
      serviceName: 'my-existing-service',
      cluster,
    });

    // Example: scale service to 0 (stopped)
    new cdk.CfnOutput(this, 'StopService', {
      value: `aws ecs update-service --cluster ${cluster.clusterName} --service ${service.serviceName} --desired-count 0`,
    });
  }
}
