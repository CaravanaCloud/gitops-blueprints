#!/bin/bash
set -e
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd "$DIR"

if [ -z "$TF_VAR_env_name" ]
then
      export TF_VAR_env_name="${BRANCH_NAME}"
fi

if [ -z "$TF_VAR_env_name" ]
then
      export TF_VAR_env_name="u$(whoami | awk '{ print tolower($0) }')"
fi

export TF_VAR_env_name=$(sed -e 's./..g' <<< "${TF_VAR_env_name}")
export TF_VAR_env_name=$(echo $TF_VAR_env_name |awk '{print toupper($0)}')

echo "Deploying environment [$TF_VAR_env_name]"

echo "Setting AWS Region to ${TF_VAR_aws_region}"
aws configure set default.region "${TF_VAR_aws_region}"
export AWS_REGION=${TF_VAR_aws_region}

echo "Deploying storage"
aws cloudformation deploy \
  --template-file "./storage/main.yaml" \
  --stack-name "${TF_VAR_env_name}-STOR"  \
  --parameter-overrides "EnvName=${TF_VAR_env_name}" \
  --tags "aws-nuke=${TF_VAR_aws_nuke}"

export BUCKET_NAME=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
echo "Using bucket [$BUCKET_NAME]"
sleep 3

echo "Deploying EKS"
sleep 3
#terraform init -upgrade
#TODO: Setup S3 backend authentication
terraform init -upgrade \
    -backend-config="bucket=$BUCKET_NAME" \
    -backend-config="key=terraform/${TF_VAR_env_name}/terraform_state" \
    -backend-config="region=${TF_VAR_aws_region}"
terraform apply -auto-approve
rm -f .terraform.outputs.txt
terraform output > .terraform.outputs.txt


export EKS_NAME=$(terraform output -raw "eks_name")
echo "EKS deployed as [$EKS_NAME]"

echo "Connecting kubectl to EKS $TF_VAR_env_name"
echo aws eks update-kubeconfig --name "${EKS_NAME}"
aws eks update-kubeconfig --name "${EKS_NAME}"

echo "Ping K8S"
kubectl get nodes
kubectl get svc

# echo "Re-backup terraform state to S3"
# echo "aws s3 sync \"${DIR}/.terraform*\" \"s3://terraform/${TF_VAR_env_name}/\""
# aws s3 sync "${DIR}/.terraform*" "s3://terraform/${TF_VAR_env_name}/"

popd
echo "K8S is ready!"
