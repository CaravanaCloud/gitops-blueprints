variable "env_name" {}

resource "aws_cloudformation_stack" "iam_admin" {
  name = "${var.env_name}-IAMA"
  parameters = {
    EnvName = var.env_name
  }
  capabilities = ["CAPABILITY_NAMED_IAM"]
  template_body = file("${path.module}/main.yaml")
}
