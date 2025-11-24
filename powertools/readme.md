'''
aws ecr describe-images \
  --repository-name my-repo \
  --query 'sort_by(imageDetails, &imagePushedAt)[-1].imageTags[0]' \
  --output text \
  --region ap-southeast-2
'''



LAYER_NAME="aws-lambda-powertools-python-layer-v3-python313-x86-64"
REGION="ap-southeast-2"

aws lambda list-layer-versions \
  --layer-name "$LAYER_NAME" \
  --region "$REGION" \
  --query 'max_by(LayerVersions, &Version).LayerVersionArn' \
  --output text