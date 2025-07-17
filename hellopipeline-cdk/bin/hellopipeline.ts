#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { HelloPipelineStack } from '../lib/hellopipeline-stack';

const app = new cdk.App();
new HelloPipelineStack(app, 'HelloPipelineStack');
