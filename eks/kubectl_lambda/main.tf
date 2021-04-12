variable "env_name" {}
variable "bucket_name" {}
variable "layer_arn" {}

module "sam_package" {
  source  = "matti/resource/shell"
  command = "sam package --template-file ${path.module}/cloudformation.yaml --s3-bucket ${var.bucket_name} --output-template-file ${path.module}/target/cloudformation.out.yaml "
}

resource "aws_cloudformation_stack" "kubectl_lambda" {
  name = "${var.env_name}-RCTL"
  parameters = {
    EnvName = var.env_name
    KubectlLayerArn = var.layer_arn
  }
  capabilities = ["CAPABILITY_AUTO_EXPAND","CAPABILITY_IAM"]
  template_body = file("${path.module}/target/cloudformation.out.yaml")
}

