import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import { Stack, StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';

export class MyEcsStack extends Stack {
  constructor(scope: Construct, id: string, props?: StackProps) {
    super(scope, id, props);

    // VPC
    const vpc = ec2.Vpc.fromLookup(this, 'Vpc', { isDefault: true });

    // Cluster
    const cluster = new ecs.Cluster(this, 'MyCluster', { vpc });

    // Security Group
    const mySecurityGroup = new ec2.SecurityGroup(this, 'MySG', {
      vpc,
      description: 'Allow inbound traffic',
      allowAllOutbound: true,
    });

    const mySecurityGroup = new ec2.SecurityGroup(this, 'MySG', {
      vpc,
      description: 'Allow traffic for service',
      allowAllOutbound: false, // 👈 Disable default all-outbound
    });
    
    // Allow only specific outbound port
    mySecurityGroup.addEgressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(55571),
      'Allow egress to TCP port 55571'
    );

    mySecurityGroup.addEgressRule(
      ec2.Peer.ipv4('10.0.0.0/16'),  // 👈 Replace with your CIDR
      ec2.Port.tcp(55571),
      'Allow egress to port 55571 within VPC CIDR'
    );    
    
    // Allow traffic on port 80
    mySecurityGroup.addIngressRule(ec2.Peer.anyIpv4(), ec2.Port.tcp(80), 'Allow HTTP');

    
    // Task Definition
    const taskDef = new ecs.FargateTaskDefinition(this, 'TaskDef');

    taskDef.addContainer('MyContainer', {
      image: ecs.ContainerImage.fromRegistry('amazon/amazon-ecs-sample'),
      portMappings: [{ containerPort: 80 }],
    });

    // ECS Service with the custom SG
    new ecs.FargateService(this, 'MyService', {
      cluster,
      taskDefinition: taskDef,
      assignPublicIp: true,
      securityGroups: [mySecurityGroup], // 👈 ADD SECURITY GROUP HERE
      desiredCount: 1,
    });
  }
}
