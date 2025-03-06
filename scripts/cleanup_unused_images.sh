#!/bin/bash
set -e

echo "Smoke test failed. Deleting Docker images in ECR..."

# Get the previous image tags for frontend and backend (excluding 'latest')
PRE_FRONTEND_IMAGE_TAG=$(aws ecr list-images --repository-name appfrontend \
  --query 'imageIds[?imageTag!=`latest`].[imageTag]' --output text | sort -r | sed -n '2p')
PRE_BACKEND_IMAGE_TAG=$(aws ecr list-images --repository-name appbackend \
  --query 'imageIds[?imageTag!=`latest`].[imageTag]' --output text | sort -r | sed -n '2p')

# Delete current images (timestamp and latest)
aws ecr batch-delete-image --repository-name appfrontend --image-ids imageTag=${{ env.TIMESTAMP }}
aws ecr batch-delete-image --repository-name appfrontend --image-ids imageTag=latest
aws ecr batch-delete-image --repository-name appbackend --image-ids imageTag=${{ env.TIMESTAMP }}
aws ecr batch-delete-image --repository-name appbackend --image-ids imageTag=latest

# Check if the previous image tags exist
if [ -z "$PRE_FRONTEND_IMAGE_TAG" ]; then
  echo "No previous frontend images found."
  exit 1
fi

if [ -z "$PRE_BACKEND_IMAGE_TAG" ]; then
  echo "No previous backend images found."
  exit 1
fi

echo "Previous frontend image found: $PRE_FRONTEND_IMAGE_TAG"
echo "Previous backend image found: $PRE_BACKEND_IMAGE_TAG"

# Save the image manifest to a file for security
FRONTEND_MANIFEST=$(aws ecr batch-get-image --repository-name appfrontend --image-ids imageTag="$PRE_FRONTEND_IMAGE_TAG" --output text --query 'images[].imageManifest')
BACKEND_MANIFEST=$(aws ecr batch-get-image --repository-name appbackend --image-ids imageTag="$PRE_BACKEND_IMAGE_TAG" --output text --query 'images[].imageManifest')

# Retag previous images to restore
aws ecr put-image --repository-name appfrontend --image-tag ${{ env.IMAGE_TAG }} --image-manifest "$FRONTEND_MANIFEST"
aws ecr put-image --repository-name appbackend --image-tag ${{ env.IMAGE_TAG }} --image-manifest "$BACKEND_MANIFEST"
