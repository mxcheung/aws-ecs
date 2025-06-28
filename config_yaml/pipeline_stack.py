from aws_cdk import Stack, aws_codebuild as codebuild
from aws_cdk.pipelines import CodePipeline, CodePipelineSource, ShellStep, CodeBuildStep
from constructs import Construct
from ecs_stack import EcsServiceStack


class PipelineStack(Stack):
    def __init__(self, scope: Construct, construct_id: str, config: dict, **kwargs):
        super().__init__(scope, construct_id, **kwargs)

        source_cfg = config["source"]["codeCommit"]
        ecr_cfg = config["ecr"]
        account = config["env"]["account"]
        region = config["env"]["region"]

        repo_uri = ecr_cfg["repositoryUri"]
        tag = ecr_cfg["tag"]

        # Synth step
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

        # Add ECR Build step BEFORE ECS deploy stage
        pipeline.add_wave("BuildAndPush").add_post(
            CodeBuildStep(
                "DockerBuildAndPush",
                input=synth.input,  # reuse same CodeCommit input
                commands=[
                    "echo Logging in to Amazon ECR...",
                    f"aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {repo_uri.split('/')[0]}",
                    "echo Building Docker image...",
                    f"docker build -t {repo_uri}:{tag} .",
                    "echo Pushing Docker image...",
                    f"docker push {repo_uri}:{tag}"
                ],
                build_environment=codebuild.BuildEnvironment(
                    privileged=True  # Required for Docker in CodeBuild
                )
            )
        )

        pipeline.add_stage(EcsDeployStage(self, "Deploy", config=config))
