'''
aws ecr describe-images \
  --repository-name my-repo \
  --query 'sort_by(imageDetails, &imagePushedAt)[-1].imageTags[0]' \
  --output text \
  --region ap-southeast-2
'''