# Let's Circle Back shall we?

aws elbv2 describe-target-groups  --names wordpress-tg > wordpress-tg.json



aws ecs describe-services --cluster Wordpress-Cluster --services wordpress-service > wordpress-service.json

aws ecs describe-task-definition --task-definition wordpress-td > wordpress-td.json


aws elbv2 describe-load-balancers --names OurApplicationLoadBalancer > OurApplicationLoadBalancer.json


OUR_APP_LB=$(aws elbv2 describe-load-balancers --names OurApplicationLoadBalancer --query "LoadBalancers[0].LoadBalancerArn" --output text)

aws elbv2 describe-listeners --load-balancer-arn $OUR_APP_LB > OurApplicationLoadBalancerListeners.json


aws ec2 describe-security-groups --filters Name=group-name,Values=app-sg > app-sg.json


aws ec2 describe-security-groups --filters Name=group-name,Values=database-sg > database-sg.json
