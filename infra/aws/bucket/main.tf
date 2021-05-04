provider "aws" {}

variable "branch_name" {}

variable "aws_nuke" {
  type = string
  default = "true"
}

locals {
  env_name = split("/", var.branch_name)[1]
  stack_suffix="bucket"
}

resource "aws_cloudformation_stack" "main" {
  name = "${local.env_name}-${local.stack_suffix}"
  parameters = {
    EnvName = local.env_name
  }
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }
}
