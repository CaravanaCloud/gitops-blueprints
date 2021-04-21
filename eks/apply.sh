#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "$TF_VAR_env_name" ]
then
      echo "\$TF_VAR_env_name is empty, trying branch name..."
      export TF_VAR_env_name="B${BRANCH_NAME}"
fi

if [ -z "$TF_VAR_env_name" ]
then
      echo "\$TF_VAR_env_name still empty, trying user name..."
      export TF_VAR_env_name="U$(whoami | awk '{ print toupper($0) }')"
fi

export TF_VAR_env_name=$(sed -e 's./..g' <<< "${TF_VAR_env_name}")
export TF_VAR_env_name=$(echo $TF_VAR_env_name |awk '{print toupper($0)}')

pushd "$DIR"
echo "Deploying storage for environment $TF_VAR_env_name ..."
sleep 3

echo "Deploying EKS"
terraform init -upgrade
terraform apply -auto-approve
terraform output > .terraform.outputs.txt
popd

export EKS_NAME=$(terraform output -raw "eks_name")
echo "EKS deployed as [$EKS_NAME]"

echo "Connecting kubectl to EKS $TF_VAR_env_name"
aws eks update-kubeconfig --name "${EKS_NAME}" --region "${TF_VAR_aws_region}"

echo "Ping K8S"
kubectl get nodes
kubectl get svc

echo "K8S is ready!"
