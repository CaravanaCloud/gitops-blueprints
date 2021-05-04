variable "env_name" {
  type = string
  default = "blueprint-network"
}

variable "aws_nuke" {
  type = string
  default = "true"
}

resource "aws_cloudformation_stack" "network" {
  name = "${var.env_name}-NETW"
  parameters = {
    EnvName = var.env_name
  }
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }
}
