export BUCKET_NAME=$(aws cloudformation list-exports --query "Exports[?Name=='BC::${TF_VAR_env_name}::DISTBKT'].Value" --output=text)
aws s3 cp ./*terraform* s3://${BUCKET_NAME}/${BRANCH_NAME}/terraform/
echo "terraform saved"
