#!/bin/bash
#

set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEFAULT_ENVNAME="ENV$(whoami | awk '{ print toupper($0) }')"
pushd "$DIR"
export TF_VAR_env_name=${TF_VAR_env_name:-$DEFAULT_ENVNAME}

echo "Take this variable, it might help..."
echo "export TF_VAR_env_name=${TF_VAR_env_name}"

echo "Deploying storage for environment $TF_VAR_env_name ..."
sleep 3

echo "Deploying EKS"
terraform init -upgrade
terraform apply -auto-approve
#terraform state list
#terraform output
popd

echo "EKS deployed."
#export BC_EKS=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::EKS'].Value" --output=text)
#export AWS_REGION=$(aws configure get region)

echo "Connecting kubectl to EKS $TF_VAR_env_name"
aws eks update-kubeconfig --name "${TF_VAR_env_name}EKS"

echo "Ping K8S"
kubectl get nodes
kubectl get svc

echo "K8S is ready!"


