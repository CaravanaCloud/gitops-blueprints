variable "env_name" {}
variable "aws_nuke" {}

resource "aws_cloudformation_stack" "eks" {
  name = "${var.env_name}-EKSCLUSTER"
  parameters = {
    EnvName = var.env_name
  }
  capabilities = ["CAPABILITY_IAM"]
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
