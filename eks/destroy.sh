#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BC_DISTBKT=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
BC_DISTBKT_URL="s3://${BC_DISTBKT}/"

echo "Emptying $BC_DISTBKT_URL"
aws s3 rm "$BC_DISTBKT_URL" --recursive

echo "Destroying"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Done"