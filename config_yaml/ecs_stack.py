from aws_cdk import Stack
from aws_cdk.aws_ec2 import Vpc, InstanceType
from aws_cdk.aws_ecs import Cluster, Ec2Service, Ec2TaskDefinition, ContainerImage
from constructs import Construct

class EcsServiceStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, config: dict, **kwargs):
        super().__init__(scope, construct_id, **kwargs)

        vpc_cfg = config["vpc"]
        ecs_cfg = config["ecs"]

        vpc = Vpc(self, "Vpc", max_azs=vpc_cfg["maxAzs"])

        cluster = Cluster(
            self,
            "Cluster",
            vpc=vpc,
            cluster_name=ecs_cfg["clusterName"]
        )

        cluster.add_capacity(
            "DefaultAutoScalingGroup",
            instance_type=InstanceType(ecs_cfg["instanceType"])
        )

        task_def = Ec2TaskDefinition(self, "TaskDef")
        task_def.add_container(
            "AppContainer",
            image=ContainerImage.from_registry(ecs_cfg["dockerImage"]),
            memory_limit_mib=256
        )

        Ec2Service(
            self,
            "EcsService",
            cluster=cluster,
            task_definition=task_def,
            service_name=ecs_cfg["serviceName"]
        )
