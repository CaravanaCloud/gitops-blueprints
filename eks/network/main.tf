variable "env_name" {}

resource "aws_cloudformation_stack" "network" {
  name = "${var.env_name}-NETW"
  parameters = {
    EnvName = var.env_name
  }
  template_body = file("${path.module}/main.yaml")
}
