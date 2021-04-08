#!/bin/bash
#
# Deploys the application tier
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DEFAULT_ENVNAME="BCX$(whoami | awk '{ print toupper($0) }')"
export TF_VAR_env_name=${TF_VAR_env_name:-$DEFAULT_ENVNAME}  

echo "Deploying environment $TF_VAR_env_name"
sleep 3

export DISTBKT=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)

set -e

echo "Packaging template and uploading to $DISTBKT"
aws cloudformation package \
    --template-file "$DIR/main.yaml" \
    --s3-bucket "$DISTBKT" \
    --s3-prefix "cfn_package" \
    --output-template-file \
    "$DIR/.main.out.yaml" 

echo "Deploy k8s cluster $TF_VAR_env_name"
pushd "$DIR"
terraform init -upgrade
terraform apply -auto-approve
popd

export BC_EKS=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::EKS'].Value" --output=text)
export AWS_REGION=$(aws configure get region)

echo "Connecting kubectl to EKS $TF_VAR_env_name"
aws eks update-kubeconfig --name "${TF_VAR_env_name}EKS"

echo "K8S is ready!"
kubectl get svc
