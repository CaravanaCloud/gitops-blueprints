#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BRANCH_NAME=${BRANCH_NAME:-"$(git branch --show-current)"}
BRANCH_NAME=${BRANCH_NAME:-"$(whoami | awk '{ print tolower($0) }')"}
TF_VAR_env_name=${TF_VAR_env_name:-"${BRANCH_NAME/\//-}"}
TF_VAR_env_name="${TF_VAR_env_name}${TF_VAR_env_suffix}"
export TF_VAR_env_name


export BUCKET=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)

# shellcheck disable=SC2236
if [ ! -z "$BUCKET" ]; then
  BUCKET_URL="s3://${BUCKET}/"
  echo "Emptying $BUCKET_URL"
  aws s3 rm "$BUCKET_URL" --recursive
fi

S3_KEY="terraform/${TF_VAR_env_name}/state"
echo "# Terraform init with backend s3://$TF_VAR_tf_bucket/$S3_KEY [$TF_VAR_aws_region]"
terraform init -upgrade \
    -backend-config="bucket=$TF_VAR_tf_bucket" \
    -backend-config="key=$S3_KEY" \
    -backend-config="region=$TF_VAR_aws_region"

echo "# Terraform destroy"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "# Done destroy"