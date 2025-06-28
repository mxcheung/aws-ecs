import yaml
import os
from aws_cdk import App, Environment
from pipeline_stack import PipelineStack

env_name = os.environ.get("ENV", "dev")

with open(f"config/{env_name}.yaml") as f:
    config = yaml.safe_load(f)

app = App()

PipelineStack(
    app,
    "PipelineStack",
    config=config,
    env=Environment(
        account=config["env"]["account"],
        region=config["env"]["region"]
    )
)

app.synth()
