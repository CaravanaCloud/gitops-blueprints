#!/bin/bash
#
# Deploys the storage tier
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEFAULT_ENVNAME="ENV$(whoami | awk '{ print toupper($0) }')"
export TF_VAR_env_name=${TF_VAR_env_name:-$DEFAULT_ENVNAME}
echo "Take this variable, it will help..."
echo "export TF_VAR_env_name=${TF_VAR_env_name}"

echo "Deploying storage for environment $TF_VAR_env_name ..."
sleep 3

echo "Deploying storage"
pushd "$DIR"
terraform init -upgrade
terraform apply -auto-approve
popd

echo "Storage deployed"
