
```
aws s3api create-bucket --bucket my-loadbalancer-access-logs --region us-east-1

aws s3api put-bucket-policy --bucket my-loadbalancer-access-logs --policy file://bucket-policy.json


aws elbv2 modify-load-balancer-attributes \
    --load-balancer-arn arn:aws:elasticloadbalancing:us-east-1:200158604781:loadbalancer/app/OurApplicationLoadBalancer/b0110a930caba434 \
    --attributes Key=access_logs.s3.enabled,Value=true Key=access_logs.s3.bucket,Value=my-loadbalancer-access-logs Key=access_logs.s3.prefix,Value=loadbalancer-logs

```
