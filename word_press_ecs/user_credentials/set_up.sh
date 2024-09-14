aws configure set aws_access_key_id $aws_access_key_id --profile cloud_user
aws configure set aws_secret_access_key $aws_secret_access_key --profile cloud_user
aws configure set region us-east-1 --profile cloud_user
aws configure set output json --profile cloud_user
export AWS_PROFILE=cloud_user
aws sts get-caller-identity
