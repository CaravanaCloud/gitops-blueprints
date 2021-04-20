#!/bin/bash
#

set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$TF_VAR_env_name" ]
then
      echo "\$TF_VAR_env_name is empty, trying branch name..."
      export TF_VAR_env_name=$(sed -e 's./..g' <<< "${BRANCH_NAME}")
fi

if [ -z "$TF_VAR_env_name" ]
then
      echo "\$TF_VAR_env_name still empty, trying user name..."
      export TF_VAR_env_name="U$(whoami | awk '{ print toupper($0) }')"
fi

pushd "$DIR"
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


