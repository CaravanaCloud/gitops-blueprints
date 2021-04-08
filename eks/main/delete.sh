#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEFAULT_ENVNAME="BCX$(whoami | awk '{ print toupper($0) }')"
TF_VAR_env_name=${TF_VAR_env_name:-$DEFAULT_ENVNAME}

echo "Deleting application tier for $TF_VAR_env_name"
pushd "$DIR"
terraform destroy -auto-approve
popd

echo "Done"