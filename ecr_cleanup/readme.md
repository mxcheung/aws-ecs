import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as iam from 'aws-cdk-lib/aws-iam';

const repo = new ecr.Repository(this, 'Repo', {
  repositoryName: 'my-app',
});

// Reference an existing IAM role
const developerRole = iam.Role.fromRoleArn(
  this,
  'DeveloperRole',
  'arn:aws:iam::<ACCOUNT_ID>:role/DeveloperRole',
  { mutable: false } // prevents CDK from modifying it
);

repo.addToResourcePolicy(
  new iam.PolicyStatement({
    principals: [new iam.ArnPrincipal(developerRole.roleArn)],
    actions: [
      "ecr:BatchDeleteImage",
      "ecr:DescribeImages",
      "ecr:ListImages"
    ],
    resources: [repo.repositoryArn],
  })
);