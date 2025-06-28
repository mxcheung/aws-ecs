from aws_cdk import Stack
from aws_cdk.pipelines import CodePipeline, CodePipelineSource, ShellStep
from constructs import Construct
from ecs_stack import EcsServiceStack

class PipelineStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, config: dict, **kwargs):
        super().__init__(scope, construct_id, **kwargs)

        source = config["source"]

        pipeline = CodePipeline(
            self,
            "Pipeline",
            pipeline_name="MyAppPipeline",
            synth=ShellStep(
                "Synth",
                input=CodePipelineSource.code_commit(
                    repository_name=source["repositoryName"],
                    branch=source["branch"]
                ),
                commands=[
                    "pip install -r requirements.txt",
                    "cdk synth"
                ]
            )
        )

        deploy_stage = EcsDeployStage(self, "Deploy", config=config)
        pipeline.add_stage(deploy_stage)


class EcsDeployStage(Stack):
    def __init__(self, scope: Construct, construct_id: str, config: dict):
        super().__init__(scope, construct_id)
        EcsServiceStack(self, "EcsServiceStack", config=config)
