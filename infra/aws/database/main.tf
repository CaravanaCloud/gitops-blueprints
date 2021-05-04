variable "env_name" {}

variable "aws_nuke" {
  type = string
  default = "true"
}

variable "pvt_nets" {}
variable "db_username" {}
variable "db_password" {}
variable "db_sg_id" {}

resource "aws_cloudformation_stack" "database" {
  name = "${var.env_name}-DB"
  parameters = {
    EnvName = var.env_name
    SubnetIds = var.pvt_nets
    MasterUsername = var.db_username
    MasterUserPassword = var.db_password
    VpcSecurityGroupIds = var.db_sg_id
  }
  template_body = file("${path.module}/main.yaml")
  tags = {
    aws-nuke = var.aws_nuke
  }
}
