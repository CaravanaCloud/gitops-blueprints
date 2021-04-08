#!/bin/bash
set -e

#Deploys an unested cluster directly on cloudformation
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Storage (Bucket, EFS)
aws cloudformation deploy --template-file "$DIR/storage/storage.yaml" \
    --stack-name "${TF_VAR_env_name}-STRG" \
    --parameter-overrides "EnvName=$TF_VAR_env_name"

export DISTBKT=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
echo "Using bucket [$DISTBKT]"

# Kubectl Lambda Layer https://github.com/aws-samples/aws-lambda-layer-kubectl

APP_ID='arn:aws:serverlessrepo:us-east-1:903779448426:applications/lambda-layer-kubectl'

LATEST_VERSION=$(aws serverlessrepo get-application --application-id ${APP_ID} --query 'Version.SemanticVersion' --output text)

TEMPLATE_URL=$(aws serverlessrepo create-cloud-formation-template \
    --application-id  ${APP_ID} \
    --semantic-version ${LATEST_VERSION} \
    --query TemplateUrl \
    --output text)

TEMPLATE_FILE=".lambda_layer_template.out"

curl -so $TEMPLATE_FILE $TEMPLATE_URL

aws cloudformation deploy \
    --template-file "$TEMPLATE_FILE" \
    --stack-name "${TF_VAR_env_name}-KLYR" \
    --capabilities CAPABILITY_AUTO_EXPAND \
    --parameter-overrides "LayerName=lambda-layer-kubectl"

aws cloudformation wait stack-create-complete --stack-name "${TF_VAR_env_name}-KLYR"

LAYER_ARN=$(aws cloudformation describe-stacks \
    --stack-name "${TF_VAR_env_name}-KLYR" \
    --query 'Stacks[0].Outputs[?OutputKey==`LayerVersionArn`].OutputValue' \
    --output text)

echo $LAYER_ARN

aws cloudformation describe-stacks --stack-name "${TF_VAR_env_name}-KLYR" --query 'Stacks[0].Outputs'

# Lambda Function on top of kubectl layer

sam package \
    --template-file "$DIR/main/kubectl_lambda/cloudformation.yaml" \
    --s3-bucket "$DISTBKT" \
    --output-template-file "$DIR/main/kubectl_lambda/.cloudformation.out.yaml"

sam deploy \
	  --template-file "$DIR/main/kubectl_lambda/.cloudformation.out.yaml" \
	  --stack-name "${TF_VAR_env_name}-RCTL" \
	  --parameter-overrides "EnvName=${TF_VAR_env_name} KubectlLayerArn=$LAYER_ARN" \
	  --capabilities CAPABILITY_IAM \
	  --region $AWS_REGION

aws cloudformation wait stack-create-complete --stack-name "${TF_VAR_env_name}-RCTL"

RUNCTLID=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::RCTLID'].Value" --output=text)

echo "Invoking $RUNCTLID"

aws lambda invoke --function-name $RUNCTLID out \
  --log-type Tail \
  --payload $(echo "{\"runctl_cmd\":\"kubectl version\"}" | base64) \
  --query 'LogResult' \
  --output text |  base64 -d

aws lambda invoke --function-name $RUNCTLID out \
  --log-type Tail \
  --payload $(echo "{\"runctl_cmd\":\"helm version\"}" | base64) \
  --query 'LogResult' \
  --output text |  base64 -d

aws lambda invoke --function-name $RUNCTLID out \
  --log-type Tail \
  --payload $(echo "{\"runctl_cmd\":\"eksctl version\"}" | base64) \
  --query 'LogResult' \
  --output text |  base64 -d

# Networking

aws cloudformation deploy \
    --template-file "$DIR/main/networking.yaml"  \
    --stack-name "${TF_VAR_env_name}-NETW" \
    --parameter-overrides "EnvName=${TF_VAR_env_name}"

aws cloudformation wait stack-create-complete --stack-name "${TF_VAR_env_name}-NETW"

# K8S Cluster (Control Plane)

aws cloudformation deploy \
    --template-file "$DIR/main/k8s.yaml" \
    --capabilities CAPABILITY_NAMED_IAM \
    --stack-name "${TF_VAR_env_name}-EKS" \
    --parameter-overrides "EnvName=${TF_VAR_env_name}"

aws cloudformation wait stack-create-complete --stack-name "${TF_VAR_env_name}-EKS"

# K8S Workers

aws cloudformation deploy \
    --template-file "$DIR/main/k8s-nodegroup.yaml" \
    --stack-name "${TF_VAR_env_name}-NODES" \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides "EnvName=${TF_VAR_env_name}" "UseSpot=${TF_VAR_use_spot}"

aws cloudformation wait stack-create-complete --stack-name "${TF_VAR_env_name}-NODES"

# Working Cluster
EKSCLUSTER="${TF_VAR_env_name}EKS"
aws eks update-kubeconfig --name $EKSCLUSTER
kubectl get nodes

# RBAC Mapping
RCTLROLEARN=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::RCTLROLEARN'].Value" --output=text)
eksctl create iamidentitymapping --cluster $EKSCLUSTER --arn $RCTLROLEARN --username runctlusr
