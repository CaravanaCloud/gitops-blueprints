variable "env_name" {}
variable "aws_nuke" {}

resource "aws_cloudformation_stack" "iam_admin" {
  name = "${var.env_name}-IAMA"
  parameters = {
    EnvName = var.env_name
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }
}
