{
  "family": "helloworld-td",
  "networkMode": "awsvpc",
  "cpu": "1024",
  "memory": "3072",
  "executionRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/OurEcsTaskExecutionRole",
  "taskRoleArn": "arn:aws:iam::${ACCOUNT_ID}:role/OurEcsTaskRole",
  "runtimePlatform": { "cpuArchitecture": "X86_64", "operatingSystemFamily": "LINUX" },
  "containerDefinitions": [
    {
      "name": "wordpress",
      "image": "${IMAGE_URI}",
      "portMappings": [{ "containerPort": 80, "hostPort": 80, "protocol": "tcp" }],
      "essential": true
    }
  ]
}
