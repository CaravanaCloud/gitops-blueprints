#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$DIR"
echo "Destroy script on [$DIR]"

BRANCH_NAME=$(git branch --show-current)
BRANCH_NAME=${BRANCH_NAME:-"$(whoami | awk '{ print tolower($0) }')"}
echo "# BRANCH_NAME=$BRANCH_NAME"

TF_VAR_env_name=${BRANCH_NAME/\//-}
TF_VAR_env_name="${TF_VAR_env_name}"
export TF_VAR_env_name
echo "# TF_VAR_env_name=$TF_VAR_env_name"

aws configure set default.region "${TF_VAR_aws_region}"
export AWS_REGION=${TF_VAR_aws_region}
echo "# AWS_REGION=$AWS_REGION"

S3_KEY="terraform/${TF_VAR_env_name}/state"
echo "# Terraform init with backend s3://$TF_VAR_tf_bucket/$S3_KEY"
sleep 3

terraform init -upgrade -force-copy \
    -backend-config="bucket=$TF_VAR_tf_bucket" \
    -backend-config="key=$S3_KEY" \
    -backend-config="region=$TF_VAR_aws_region"

echo "# Terraform destroy"
terraform destroy -auto-approve
popd

echo "# Done destroy"