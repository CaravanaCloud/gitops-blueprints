variable "env_name" {}
variable "bucket_name" {}
variable "layer_arn" {}


resource "aws_cloudformation_stack" "kubectl_lambda" {
  name = "${var.env_name}-RCTL"
  parameters = {
    EnvName = var.env_name
    KubectlLayerArn = var.layer_arn
  }
  capabilities = ["CAPABILITY_AUTO_EXPAND","CAPABILITY_IAM"]
  template_body = file("${path.module}/target/main.out.yaml")
}

