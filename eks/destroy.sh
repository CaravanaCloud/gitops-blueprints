#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DISTBKT=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
# shellcheck disable=SC2236
if [ ! -z "$DISTBKT" ]; then
  DISTBKT_URL="s3://${DISTBKT}/"
  echo "Emptying $DISTBKT_URL"
  aws s3 rm "$DISTBKT_URL" --recursive
fi

echo "Destroying"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Done"