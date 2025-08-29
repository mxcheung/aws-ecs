# CDK Cross-Account ECS Java Pipeline Demo

## Overview

- Pipeline in **Account A**  
  - Uses AWS CodeCommit as source (repo: `demo-java-ecs-app`)  
  - Pushes Docker image to **existing ECR repo** (`java-app-repo`) in Account A  
  - Deploys ECS Fargate service in **Account B** pulling image from Account A ECR

- Single deploy target (no multi-stage)

---

## Setup Instructions

### 1. Prerequisites

- AWS CLI and CDK installed and configured with profiles for both accounts
- CDK bootstrap both accounts:

```bash
cdk bootstrap aws://111111111111/ap-southeast-2
cdk bootstrap aws://222222222222/ap-southeast-2 --trust 111111111111
```

- Ensure the existing ECR repo `java-app-repo` in Account A allows Account B to pull images (resource policy)

### 2. Deploy the pipeline stack in Account A

```bash
cdk deploy PipelineStack --profile account-a-profile
```

### 3. Push your Java app source to CodeCommit repo `demo-java-ecs-app`

### 4. The pipeline will:

- Build Java app with Maven
- Build Docker image and push to ECR in Account A
- Deploy ECS Fargate service in Account B using that image

---

### 5. Health Check:

```
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

Disable via application.yml
management.health.jms.enabled=false

```
management:
  health:
    jms:
      enabled: false

```
```
management.endpoints.web.exposure.include=health,info
```

```
CMD-SHELL, curl -f http://localhost:8080/actuator/health || exit 1
```

## Notes

- Replace all account IDs and repo names in CDK code with your own
- The ECS task exposes port 8080; ensure security groups allow traffic as needed
