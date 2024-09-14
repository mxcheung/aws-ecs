# create db subnet group


# create cloud 9 via cloudshell
```
export aws_access_key_id=AKIAVXXXXXXXXX
export aws_secret_access_key=NM1iou3PMdxxxxxxxxxxxxxxxxxxxxx
cd /home/ec2-user/environment/word_press_ecs/db_subnet_group/
. ./create_db_subnet_group.sh
```


```
# Assign the VPC ID to a variable
VPC_ID=$(aws ec2 describe-vpcs --query "Vpcs[?Tags[?Key=='Name' && Value=='Your Custom VPC']].{VpcId:VpcId}" --output text)



SECURITY_GROUP_ID=$(aws ec2 create-security-group \
    --group-name database-sg \
    --description "Security group for RDS instance" \
    --vpc-id "$VPC_ID" \
    --query "GroupId" \
    --output text)

aws ec2 authorize-security-group-ingress \
   --group-id $SECURITY_GROUP_ID \
   --ip-permissions IpProtocol=tcp,FromPort=3306,ToPort=3306,IpRanges="[{CidrIp=10.0.0.0/16,Description='Allow MySQL access from VPC'}]"


```
