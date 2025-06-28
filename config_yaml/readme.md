```
CDK Pipeline Stack
├── Synth + CodeBuild (Docker Build & Push to ECR)
└── ECS Stack (Separate, deployed via pipeline stage)
```

```
my-cdk-project/
├── config/
│   └── dev.yaml
├── app.py
├── pipeline_stack.py         # Pipeline logic
├── ecs_stack.py              # ECS infra (cluster + service)
├── requirements.txt
└── cdk.json
```
