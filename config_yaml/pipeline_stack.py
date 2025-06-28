from aws_cdk import Stack, Stage
from aws_cdk.pipelines import CodePipeline, CodePipelineSource, ShellStep, CodeBuildStep
from aws_cdk import aws_codebuild as codebuild
from constructs import Construct
from ecs_cluster_stack import EcsClusterStack
from ecs_service_stack import EcsServiceStack


class PipelineStack(Stack):
    def __init__(self, scope: Construct, id: str, config: dict, **kwargs):
        super().__init__(scope, id, **kwargs)

        repo = config["source"]["codeCommit"]
        ecr = config["ecr"]
        pipeline_cfg = config["pipeline"]
        env_cfg = config["env"]

        # CDK synth step
        synth = ShellStep("Synth",
            input=CodePipelineSource.code_commit(
                repository_name=repo["repositoryName"],
                branch=repo["branch"]
            ),
            commands=[
                "pip install -r requirements.txt",
                "cdk synth"
            ]
        )

        pipeline = CodePipeline(self, "Pipeline",
            pipeline_name=pipeline_cfg["name"],
            synth=synth
        )

        # Build + Push Docker image to ECR
        pipeline.add_wave("BuildAndPush").add_post(
            CodeBuildStep(
                "DockerBuild",
                input=synth.input,
                commands=[
                    f"aws ecr get-login-password --region {env_cfg['region']} | docker login --username AWS --password-stdin {ecr['repositoryUri'].split('/')[0]}",
                    f"docker build -t {ecr['repositoryUri']}:{ecr['tag']} {ecr['dockerContext']}",
                    f"docker push {ecr['repositoryUri']}:{ecr['tag']}"
                ],
                build_environment=codebuild.BuildEnvironment(
                    privileged=True
                )
            )
        )

        pipeline.add_stage(EcsDeployStage(self, "EcsDeployStage", config=config))


class EcsDeployStage(Stage):
    def __init__(self, scope: Construct, id: str, config: dict, **kwargs):
        super().__init__(scope, id, **kwargs)

        cluster_stack = EcsClusterStack(self, "ClusterStack", config=config)
        EcsServiceStack(self, "ServiceStack", config=config, cluster=cluster_stack.cluster)
