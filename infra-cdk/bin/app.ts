#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { VscodeStack } from '../lib/vscode-stack';

const app = new cdk.App();

const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION || 'ap-northeast-2',
};

new VscodeStack(app, 'VscodeServerStack', {
  env,
  description: 'Secure VSCode Server - CloudFront, ALB, Private EC2 with Claude Code',
});

app.synth();
