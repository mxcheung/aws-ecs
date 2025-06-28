from aws_cdk import Stack, CfnOutput
from aws_cdk.aws_ec2 import Vpc
from aws_cdk.aws_ecs import Cluster
from constructs import Construct

class EcsClusterStack(Stack):
    def __init__(self, scope: Construct, id: str, config: dict, **kwargs):
        super().__init__(scope, id, **kwargs)

        vpc_cfg = config["vpc"]
        ecs_cfg = config["ecs"]

        self.vpc = Vpc(self, "Vpc", max_azs=vpc_cfg["maxAzs"])

        self.cluster = Cluster(
            self,
            "Cluster",
            vpc=self.vpc,
            cluster_name=ecs_cfg["clusterName"]
        )

        # Output ARN to pass to other stacks (if needed)
        CfnOutput(self, "ClusterName", value=self.cluster.cluster_name)
