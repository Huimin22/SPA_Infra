#!/bin/bash

# Ensure INSTANCE_ID is passed from the environment
if [ -z "$INSTANCE_ID" ]; then
  echo "INSTANCE_ID is not set."
  exit 1
fi

# Terminate the EC2 instance
echo "Terminating EC2 instance with ID: $INSTANCE_ID"
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
