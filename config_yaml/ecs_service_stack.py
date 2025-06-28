from aws_cdk import Stack
from aws_cdk.aws_ec2 import InstanceType
from aws_cdk.aws_ecs import Ec2Service, Ec2TaskDefinition, ContainerImage, Cluster
from constructs import Construct


class EcsServiceStack(Stack):
    def __init__(self, scope: Construct, id: str, config: dict, cluster: Cluster, **kwargs):
        super().__init__(scope, id, **kwargs)

        ecs_cfg = config["ecs"]
        ecr_cfg = config["ecr"]

        cluster.add_capacity(
            "DefaultASG",
            instance_type=InstanceType(ecs_cfg["instanceType"])
        )

        task_def = Ec2TaskDefinition(self, "TaskDef")
        task_def.add_container(
            "AppContainer",
            image=ContainerImage.from_registry(f"{ecr_cfg['repositoryUri']}:{ecr_cfg['tag']}"),
            memory_limit_mib=ecs_cfg["memory"]
        )

        Ec2Service(
            self,
            "Service",
            cluster=cluster,
            task_definition=task_def,
            service_name=ecs_cfg["serviceName"]
        )
