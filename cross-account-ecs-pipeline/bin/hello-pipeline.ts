#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { HelloPipelineStack } from '../lib/hello-pipeline-stack';

const app = new cdk.App();

new HelloPipelineStack(app, 'HelloPipelineStack', {
  env: {
    account: 'DP_ACCOUNT_ID',  // replace with your dp account number
    region: 'DP_REGION',       // e.g. 'ap-southeast-2'
  },
  dpRegion: 'DP_REGION',
  ecrRepoName: 'hello-world',
  codeCommitRepoName: 'hellocodepipeline',
});
