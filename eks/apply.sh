#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$DIR"

if [ -z "$BRANCH_NAME" ]
then
      echo "\$BRANCH_NAME is empty, default to user name..."
      export BRANCH_NAME="u$(whoami | awk '{ print tolower($0) }')"
fi

if [ -z "$TF_VAR_env_name" ]
then
      echo "\$TF_VAR_env_name is empty, default to branch name..."
      export TF_VAR_env_name="${BRANCH_NAME}"
fi

export TF_VAR_env_name=$(sed -e 's./..g' <<< "${TF_VAR_env_name}")
export TF_VAR_env_name=$(echo $TF_VAR_env_name |awk '{print toupper($0)}')
echo "Deploying environment [$TF_VAR_env_name]"

echo "Setting AWS Region to ${TF_VAR_aws_region}"
aws config set default.region ${TF_VAR_aws_region}
export AWS_REGION=${TF_VAR_aws_region}

echo "Deploying storage"
aws cloudformation deploy \
  --template-file "./storage/main.yaml" \
  --stack-name "${TF_VAR_env_name}-STOR"  \
  --parameter-overrides "EnvName=${TF_VAR_env_name}"
export BUCKET_NAME=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
sleep 3

echo "Deploying EKS"
sleep 3
terraform init -upgrade
#TODO: Setup S3 backend authentication
#terraform init -upgrade \
#    -backend-config="bucket=$BUCKET_NAME" \
#    -backend-config="key=branch_${BRANCH_NAME}/terraform_state" \
#    -backend-config="region=${TF_VAR_aws_region}"
terraform apply -auto-approve
terraform output > .terraform.outputs.txt
popd

export EKS_NAME=$(terraform output -raw "eks_name")
echo "EKS deployed as [$EKS_NAME]"

echo "Connecting kubectl to EKS $TF_VAR_env_name"
aws eks update-kubeconfig --name "${EKS_NAME}"

echo "Ping K8S"
kubectl get nodes
kubectl get svc

echo "K8S is ready!"
