# Let's Circle Back shall we?

aws elbv2 describe-target-groups  --names wordpress-tg > wordpress-tg.json



aws ecs describe-services  --cluster Wordpress-Cluster   --services Wordpress-Service >  wordpress-Service.json
