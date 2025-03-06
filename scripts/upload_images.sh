#!/bin/bash
set -e

FRONTEND_IMAGE_ID=$(docker images --filter=reference="spapath-frontend" --format "{{.ID}}")
BACKEND_IMAGE_ID=$(docker images --filter=reference="spapath-backend" --format "{{.ID}}")

echo "Found Docker Image ID (frontend): $FRONTEND_IMAGE_ID"
echo "Found Docker Image ID (backend): $BACKEND_IMAGE_ID"

TIMESTAMP=$(date "+%Y%m%d.%H%M%S")
echo "Generated TIMESTAMP: $TIMESTAMP"

ECR_REPO_FRONTEND="738250824273.dkr.ecr.us-east-1.amazonaws.com/appfrontend"
ECR_REPO_BACKEND="738250824273.dkr.ecr.us-east-1.amazonaws.com/appbackend"

docker tag $FRONTEND_IMAGE_ID $ECR_REPO_FRONTEND:$TIMESTAMP
docker tag $FRONTEND_IMAGE_ID $ECR_REPO_FRONTEND:latest
docker push --all-tags $ECR_REPO_FRONTEND

docker tag $BACKEND_IMAGE_ID $ECR_REPO_BACKEND:$TIMESTAMP
docker tag $BACKEND_IMAGE_ID $ECR_REPO_BACKEND:latest
docker push --all-tags $ECR_REPO_BACKEND

echo "TIMESTAMP=$TIMESTAMP" >> $GITHUB_ENV
