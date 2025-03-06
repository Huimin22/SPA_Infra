#!/bin/bash
set -e

QA_EC2_PUBLIC_DNS=$1
PEM_FILE="devop.pem"

echo "Deploying latest version to QA EC2: $QA_EC2_PUBLIC_DNS"

ssh -i $PEM_FILE -o StrictHostKeyChecking=no ec2-user@$QA_EC2_PUBLIC_DNS << 'EOF'
  sudo yum install -y docker
  sudo service docker start
  sudo chkconfig docker on
  sudo usermod -aG docker ec2-user
  sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
  newgrp docker
  docker --version
  docker-compose version

  export AWS_ACCESS_KEY_ID=${{ secrets.AWS_ACCESS_KEY_ID }}
  export AWS_SECRET_ACCESS_KEY=${{ secrets.AWS_SECRET_ACCESS_KEY }}
  export AWS_SESSION_TOKEN=${{ secrets.AWS_SESSION_TOKEN }}
  export AWS_REGION=${{ env.AWS_REGION }}

  export DB_HOST="localdb.cvp0oraj48yg.us-east-1.rds.amazonaws.com"
  export DB_USER="admin"
  export DB_PASSWORD=${{ secrets.DB_PASSWORD }}
  export DB_NAME="food_db"

  aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin ${{ secrets.AWS_ACCOUNT_ID }}.dkr.ecr.$AWS_REGION.amazonaws.com
  docker-compose -f docker-compose-qa.yml pull
  docker-compose down
  docker-compose -f docker-compose-qa.yml up -d
  docker image prune -f
EOF
