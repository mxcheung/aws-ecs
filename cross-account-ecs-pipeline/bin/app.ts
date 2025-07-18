#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { HelloEcsStack } from '../lib/hello-ecs-stack';
import { HelloPipelineStack } from '../lib/hello-pipeline-stack';

const app = new cdk.App();

new HelloEcsStack(app, 'HelloEcsStack', {
  env: { account: 'DT_ACCOUNT_ID', region: 'DT_REGION' },
  vpcName: 'your-vpc-name',
  dpAccountId: 'DP_ACCOUNT_ID',
  dpRegion: 'DP_REGION',
  ecrRepoName: 'hello-world',
});

new HelloPipelineStack(app, 'HelloPipelineStack', {
  env: { account: 'DP_ACCOUNT_ID', region: 'DP_REGION' },
  dpRegion: 'DP_REGION',
  ecrRepoName: 'hello-world',
  codeCommitRepoName: 'hellocodepipeline',
});
