import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as cpactions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as codecommit from 'aws-cdk-lib/aws-codecommit';
import * as logs from 'aws-cdk-lib/aws-logs';

export class HelloPipelineStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // VPC for ECS cluster
  //  const vpc = new ec2.Vpc(this, 'HelloVpc', { maxAzs: 2 });

    const vpc = ec2.Vpc.fromLookup(this, 'Your Custom VPC', {
      isDefault: true, // or use `vpcName` or `vpcId` if not default
    });
    // ECR repository
//    const repo = new ecr.Repository(this, 'AppRepo', {
//      repositoryName: 'hello-world',
//      removalPolicy: cdk.RemovalPolicy.RETAIN,
 //   });

    // Import the ECR repository by name (assumes the repo already exists)
    const repo = ecr.Repository.fromRepositoryName(this, 'ExistingEcrRepo', 'hello-ecs');


    // ECS cluster and task definition
    //const cluster = new ecs.Cluster(this, 'Cluster', { vpc });

    const clusterName = 'Wordpress-Cluster';
    const cluster = ecs.Cluster.fromClusterAttributes(this, 'ExistingCluster', {
      clusterName,
      vpc,
      securityGroups: [], // optional: if needed
    });
    
    
    // Log group for container logs
    const logGroup = new logs.LogGroup(this, 'AppLogGroup', {
      logGroupName: '/ecs/hello-pipeline-app',
      removalPolicy: cdk.RemovalPolicy.DESTROY, // optional: auto-delete with stack
    });

    const dbSecret = secretsmanager.Secret.fromSecretNameV2(this, 'DbSecret', 'MyDatabaseSecret');
    const apiSecret = secretsmanager.Secret.fromSecretNameV2(this, 'ApiSecret', 'MyApiSecret');
    
    const taskDef = new ecs.FargateTaskDefinition(this, 'TaskDef', {
      memoryLimitMiB: 3072,
      cpu: 1024, // You can adjust this if needed (1024 = 1 vCPU)
    });

    taskDef.addContainer('AppContainer', {
      image: ecs.ContainerImage.fromEcrRepository(repo, 'latest'),
      memoryLimitMiB: 1024,
      logging: ecs.LogDriver.awsLogs({
        streamPrefix: 'hello-world',
        logGroup: logGroup,
      }),
      environment: {
        NODE_ENV: 'production',
        API_URL: 'https://api.example.com',
        LOG_LEVEL: 'info',
        // add more variables as needed
      },
      secrets: {
        DB_USERNAME: ecs.Secret.fromSecretsManager(dbSecret, 'username'),
        DB_PASSWORD: ecs.Secret.fromSecretsManager(dbSecret, 'password'),
        API_KEY: ecs.Secret.fromSecretsManager(apiSecret, 'apiKey'),
      },
    });

    const service = new ecs.FargateService(this, 'Service', {
      cluster,
      taskDefinition: taskDef,
      desiredCount: 1,
    });

    // CodeCommit repository
    const codeRepo = new codecommit.Repository(this, 'CodeRepo', {
      repositoryName: 'hellocodepipeline',
    });

    // CodeBuild project
    const buildProject = new codebuild.PipelineProject(this, 'BuildProject', {
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_6_0,
        privileged: true,
        environmentVariables: {
          REPO_URI: { value: repo.repositoryUri },
        },
      },
      buildSpec: codebuild.BuildSpec.fromObject({
        version: '0.2',
        phases: {
          pre_build: {
            commands: [
              'echo Logging in to Amazon ECR...',
              'aws ecr get-login-password | docker login --username AWS --password-stdin $REPO_URI',
              'export IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7 || echo latest)',
            ],
          },
          build: {
            commands: [
              'docker build -t $REPO_URI:$IMAGE_TAG .',
              'docker push $REPO_URI:$IMAGE_TAG',
            ],
          },
          post_build: {
            commands: [
              'printf '[{"name":"AppContainer","imageUri":"%s"}]' $REPO_URI:$IMAGE_TAG > imagedefinitions.json',
            ],
          },
        },
        artifacts: {
          files: ['imagedefinitions.json'],
        },
      }),
    });
    repo.grantPullPush(buildProject.role!);

    // Pipeline artifacts
    const sourceOutput = new codepipeline.Artifact();
    const buildOutput = new codepipeline.Artifact();

    // CodePipeline definition
    const pipeline = new codepipeline.Pipeline(this, 'HelloPipeline', {
      pipelineName: 'HelloWorldPipeline',
    });

    pipeline.addStage({
      stageName: 'Source',
      actions: [
        new cpactions.CodeCommitSourceAction({
          actionName: 'CodeCommit_Source',
          repository: codeRepo,
          branch: 'main',
          output: sourceOutput,
        }),
      ],
    });

    pipeline.addStage({
      stageName: 'Build',
      actions: [
        new cpactions.CodeBuildAction({
          actionName: 'Docker_Build',
          project: buildProject,
          input: sourceOutput,
          outputs: [buildOutput],
        }),
      ],
    });

    pipeline.addStage({
      stageName: 'Deploy',
      actions: [
        new cpactions.EcsDeployAction({
          actionName: 'ECS_Deploy',
          service,
          input: buildOutput,
        }),
      ],
    });
  }
}
