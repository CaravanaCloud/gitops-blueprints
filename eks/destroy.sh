#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$TF_VAR_env_name" ]
then
      TF_VAR_env_name="${BRANCH_NAME}"
fi

if [ -z "$TF_VAR_env_name" ]
then
      TF_VAR_env_name="u$(whoami | awk '{ print tolower($0) }')"
fi

TF_VAR_env_name=$(sed -e 's./..g' <<< "${TF_VAR_env_name}")
TF_VAR_env_name=$(echo $TF_VAR_env_name |awk '{print toupper($0)}')

export BUCKET=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)

# shellcheck disable=SC2236
if [ ! -z "$BUCKET" ]; then
  BUCKET_URL="s3://${BUCKET}/"
  echo "Emptying $BUCKET_URL"
  aws s3 rm "$BUCKET_URL" --recursive
fi

echo "Destroying environment"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Destroying bucket"
# echo aws s3 rb "s3://$BUCKET"

echo "Done destroy"