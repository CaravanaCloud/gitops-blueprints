variable "env_name" {}

resource "aws_cloudformation_stack" "eks" {
  name = "${var.env_name}-EKSCLUSTER"
  parameters = {
    EnvName = var.env_name
  }
  capabilities = ["CAPABILITY_IAM"]
  template_body = file("${path.module}/main.yaml")
  # disable_rollback = true

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
