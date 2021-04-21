#!/bin/bash
set -e
BUCKET_NAME=$(terraform  output -raw bucket_name)
[[ -z "$pdfurl" ]] && { echo "Error: BUCKET_NAME not found"; exit 1; }
LOCAL_GLOB="./*terraform*"
BRANCH_NAME=${BRANCH_NAME:-"local"}
S3_URL="s3://${BUCKET_NAME}/${BRANCH_NAME}/terraform/"
echo aws s3 sync \"$LOCAL_GLOB\" \"$S3_URL\"
aws s3 sync $LOCAL_GLOB "$S3_URL"
echo "checking..."
aws s3 ls "$S3_URL"
echo "terraform state saved"
