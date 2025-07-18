#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { HelloEcsStack } from '../lib/hello-ecs-stack';

const app = new cdk.App();

new HelloEcsStack(app, 'HelloEcsStack', {
  env: {
    account: 'DT_ACCOUNT_ID',   // replace with your dt account number
    region: 'DT_REGION',        // e.g. 'ap-southeast-2'
  },
  vpcName: 'your-vpc-name',
  dpAccountId: 'DP_ACCOUNT_ID', // pipeline account number
  dpRegion: 'DP_REGION',         // e.g. 'ap-southeast-2'
  ecrRepoName: 'hello-world',
});
