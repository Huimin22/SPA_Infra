#!/bin/bash
set -e

AMI_ID="ami-053a45fff0a704a47"
INSTANCE_TYPE="t2.micro"
KEY_NAME="devop"
SECURITY_GROUP_ID="sg-0e6ad2479f4f8ae2d"
SUBNET_ID="subnet-0be6f1d701ddf7f3c"

echo "Launching temporary EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type $INSTANCE_TYPE \
  --key-name $KEY_NAME \
  --security-group-ids $SECURITY_GROUP_ID \
  --subnet-id $SUBNET_ID \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "INSTANCE_ID=$INSTANCE_ID"
echo "INSTANCE_ID=$INSTANCE_ID" >> $GITHUB_ENV

echo "Waiting for instance to be in 'running' state..."
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

echo "Sleeping for 15 seconds to ensure stability..."
sleep 15
echo "EC2 instance $INSTANCE_ID is ready."
