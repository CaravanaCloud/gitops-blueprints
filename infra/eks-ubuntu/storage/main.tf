variable "env_name" {}
variable "aws_nuke" {}

resource "aws_cloudformation_stack" "storage" {
  name = "${var.env_name}-STRG"
  parameters = {
    EnvName = var.env_name
  }
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }
}

