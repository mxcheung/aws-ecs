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
