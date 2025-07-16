#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { PipelineStack } from '../lib/pipeline-stack';
import { EcsStack } from '../lib/ecs-stack';

const app = new cdk.App();

const ACCOUNT_A = '111111111111'; // pipeline + ecr + codecommit
const ACCOUNT_B = '222222222222'; // ECS target
const REGION = 'ap-southeast-2';

new PipelineStack(app, 'PipelineStack', {
  env: { account: ACCOUNT_A, region: REGION },
});

new EcsStack(app, 'EcsStack', {
  env: { account: ACCOUNT_B, region: REGION },
});
