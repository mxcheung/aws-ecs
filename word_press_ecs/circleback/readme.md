# Let's Circle Back shall we?

aws elbv2 describe-target-groups  --names wordpress-tg > wordpress-tg.json



aws ecs describe-services --cluster Wordpress-Cluster --services wordpress-service > wordpress-service.json

aws ecs describe-task-definition --task-definition wordpress-td > wordpress-td.json


aws elbv2 describe-load-balancers --names OurApplicationLoadBalancer > OurApplicationLoadBalancer.json
