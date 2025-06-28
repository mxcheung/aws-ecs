from aws_cdk import Stack, Stage
from aws_cdk.pipelines import CodePipeline, CodePipelineSource, ShellStep, CodeBuildStep
from aws_cdk import aws_codebuild as codebuild
from constructs import Construct
from ecs_cluster_stack import EcsClusterStack
from ecs_service_stack import EcsServiceStack


class PipelineStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, config: dict, **kwargs):
        super().__init__(scope, construct_id, **kwargs)

        source_cfg = config["source"]["codeCommit"]
        ecr_cfg = config["ecr"]
        account = config["env"]["account"]
        region = config["env"]["region"]

        repo_uri = ecr_cfg["repositoryUri"]
        tag = ecr_cfg["tag"]

        synth = ShellStep("Synth",
            input=CodePipelineSource.code_commit(
                repository_name=source_cfg["repositoryName"],
                branch=source_cfg["branch"]
            ),
            commands=[
                "pip install -r requirements.txt",
                "cdk synth"
            ]
        )

        pipeline = CodePipeline(self, "Pipeline", synth=synth)

        # Build + Push Docker image
        pipeline.add_wave("BuildAndPush").add_post(
            CodeBuildStep(
                "DockerBuildAndPush",
                input=synth.input,
                commands=[
                    f"aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {repo_uri.split('/')[0]}",
                    f"docker build -t {repo_uri}:{tag} .",
                    f"docker push {repo_uri}:{tag}"
                ],
                build_environment=codebuild.BuildEnvironment(
                    privileged=True
                )
            )
        )

        # ECS deployment stage
        pipeline.add_stage(EcsDeployStage(self, "Deploy", config=config))


class EcsDeployStage(Stage):
    def __init__(self, scope: Construct, id: str, config: dict, **kwargs):
        super().__init__(scope, id, **kwargs)

        # First: create VPC + cluster
        cluster_stack = EcsClusterStack(self, "ClusterStack", config=config)

        # Then: create service using cluster from above
        EcsServiceStack(self, "ServiceStack", config=config, cluster=cluster_stack.cluster)
