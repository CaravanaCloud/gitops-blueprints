#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BUCKET=$(terraform output -raw "bucket_name")
# shellcheck disable=SC2236
if [ ! -z "$BUCKET" ]; then
  BUCKET_URL="s3://${BUCKET}/"
  echo "Emptying $BUCKET_URL"
  aws s3 rm "$BUCKET_URL" --recursive
fi

echo "Destroying"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Done"