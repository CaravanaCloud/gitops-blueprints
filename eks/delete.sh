#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEFAULT_ENVNAME="BCX$(whoami | awk '{ print toupper($0) }')"
BC_ENVNAME=${BC_ENVNAME:-$DEFAULT_ENVNAME}

BC_DISTBKT=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${BC_ENVNAME}::DISTBKT'].Value" --output=text)
BC_DISTBKT_URL="s3://${BC_DISTBKT}/"

echo "Emptying $BC_DISTBKT_URL"
aws s3 rm "$BC_DISTBKT_URL" --recursive

echo "Destroying"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Done"