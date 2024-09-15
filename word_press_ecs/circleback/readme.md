# Let's Circle Back shall we?

aws elbv2 describe-target-groups \
    --names wordpress-tg

```
 "TargetGroups": [
        {
            "TargetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:533917667520:targetgroup/wordpress-tg/d684ee0fc9a93a6e",
            "TargetGroupName": "wordpress-tg",
            "Protocol": "HTTP",
            "Port": 80,
            "VpcId": "vpc-07eb47ee98885764a",
            "HealthCheckProtocol": "HTTP",
            "HealthCheckPort": "traffic-port",
            "HealthCheckEnabled": true,
            "HealthCheckIntervalSeconds": 30,
            "HealthCheckTimeoutSeconds": 5,
            "HealthyThresholdCount": 5,
            "UnhealthyThresholdCount": 2,
            "HealthCheckPath": "/wp-admin/images/wordpress-logo.svg",
            "Matcher": {
                "HttpCode": "200"
            },
            "LoadBalancerArns": [
                "arn:aws:elasticloadbalancing:us-east-1:533917667520:loadbalancer/app/OurApplicationLoadBalancer/597e0e7e802a7d3f"
            ],
            "TargetType": "ip",
            "ProtocolVersion": "HTTP1",
            "IpAddressType": "ipv4"
        }
   ]   
```    


aws ecs describe-services \
    --cluster Wordpress-Cluster \
    --services Wordpress-Service

```
{
    "services": [
        {
            "serviceArn": "arn:aws:ecs:us-east-1:533917667520:service/Wordpress-Cluster/wordpress-service",
            "serviceName": "wordpress-service",
            "clusterArn": "arn:aws:ecs:us-east-1:533917667520:cluster/Wordpress-Cluster",
            "loadBalancers": [
                {
                    "targetGroupArn": "arn:aws:elasticloadbalancing:us-east-1:533917667520:targetgroup/wordpress-tg/d684ee0fc9a93a6e",
                    "containerName": "wordpress",
                    "containerPort": 80
                }
            ],
            "serviceRegistries": [],
            "status": "ACTIVE",
            "desiredCount": 1,
            "runningCount": 1,
            "pendingCount": 0,
            "capacityProviderStrategy": [
                {
                    "capacityProvider": "FARGATE",
                    "weight": 1,
                    "base": 0
                }
            ],
            "platformVersion": "LATEST",
            "platformFamily": "Linux",
            "taskDefinition": "arn:aws:ecs:us-east-1:533917667520:task-definition/wordpress-td:1",
            "deploymentConfiguration": {
                "deploymentCircuitBreaker": {
                    "enable": true,
                    "rollback": true
                },
                "maximumPercent": 200,
                "minimumHealthyPercent": 100,
                "alarms": {
                    "alarmNames": [],
                    "enable": false,
                    "rollback": false
                }
            },
            "deployments": [
                {
                    "id": "ecs-svc/6380115080087566031",
                    "status": "PRIMARY",
                    "taskDefinition": "arn:aws:ecs:us-east-1:533917667520:task-definition/wordpress-td:1",
                    "desiredCount": 1,
                    "pendingCount": 0,
                    "runningCount": 1,
                    "failedTasks": 0,
                    "createdAt": "2024-09-15T04:32:46.117000+00:00",
                    "updatedAt": "2024-09-15T04:33:54.424000+00:00",
                    "capacityProviderStrategy": [
                        {
                            "capacityProvider": "FARGATE",
                            "weight": 1,
                            "base": 0
                        }
                    ],
                    "platformVersion": "1.4.0",
                    "platformFamily": "Linux",
                    "networkConfiguration": {
                        "awsvpcConfiguration": {
                            "subnets": [
                                "subnet-01573dfec4987752c",
                                "subnet-0a86c4768f1e62c87",
                                "subnet-04782ce190f21fc1c"
                            ],
                            "securityGroups": [
                                "sg-0d1d15c128f562d79"
                            ],
                            "assignPublicIp": "ENABLED"
                        }
                    },
                    "rolloutState": "COMPLETED",
                    "rolloutStateReason": "ECS deployment ecs-svc/6380115080087566031 completed."
                }
            ],
            "roleArn": "arn:aws:iam::533917667520:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS",
            "events": [
                {
                    "id": "24293a2e-2d20-4915-89f6-d78346fd5a04",
                    "createdAt": "2024-09-15T04:33:54.430000+00:00",
                    "message": "(service wordpress-service) has reached a steady state."
                },
                {
                    "id": "dafe4408-5da2-4d22-964f-ce23152e11bb",
                    "createdAt": "2024-09-15T04:33:54.429000+00:00",
                    "message": "(service wordpress-service) (deployment ecs-svc/6380115080087566031) deployment completed."
                },
                {
                    "id": "ad202cac-fc54-41ee-baf5-814377116544",
                    "createdAt": "2024-09-15T04:33:44.791000+00:00",
                    "message": "(service wordpress-service) registered 1 targets in (target-group arn:aws:elasticloadbalancing:us-east-1:533917667520:targetgroup/wordpress-tg/d684ee0fc9a93a6e)"
                },
                {
                    "id": "dd704905-4a19-4bc8-9271-72cdd0fe3134",
                    "createdAt": "2024-09-15T04:33:05.935000+00:00",
                    "message": "(service wordpress-service) has started 1 tasks: (task 3be15f5d8ffc4a9da992fc12bfad0765)."
                }
            ],
            "createdAt": "2024-09-15T04:32:46.117000+00:00",
            "placementConstraints": [],
            "placementStrategy": [],
            "networkConfiguration": {
                "awsvpcConfiguration": {
                    "subnets": [
                        "subnet-01573dfec4987752c",
                        "subnet-0a86c4768f1e62c87",
                        "subnet-04782ce190f21fc1c"
                    ],
                    "securityGroups": [
                        "sg-0d1d15c128f562d79"
                    ],
                    "assignPublicIp": "ENABLED"
                }
            },
            "healthCheckGracePeriodSeconds": 30,
            "schedulingStrategy": "REPLICA",
            "deploymentController": {
                "type": "ECS"
            },
            "createdBy": "arn:aws:iam::533917667520:user/cloud_user",
            "enableECSManagedTags": true,
            "propagateTags": "NONE",
            "enableExecuteCommand": false
        }
    ],
    "failures": []
}
```
