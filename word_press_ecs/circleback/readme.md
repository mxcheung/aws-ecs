# Let's Circle Back

aws elbv2 describe-target-groups \
    --names wordpress-tg \
    --query "TargetGroups[0].TargetGroupArn" \
    --output text


aws ecs describe-services \
    --cluster Wordpress-Cluster \
    --services Wordpress-Service
