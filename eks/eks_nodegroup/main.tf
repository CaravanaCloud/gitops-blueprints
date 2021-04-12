variable "env_name" {}
variable "min_size" {}
variable "desired_capacity" {}
variable "max_size" {}
variable "instance_type" {}
variable "image_id" {}
variable "root_size" {}
variable "root_device" {}
variable "extra_size" {}
variable "extra_device" {}


resource "aws_cloudformation_stack" "eks_nodegroup" {
  name = "${var.env_name}-EKSNODES"
  parameters = {
    EnvName = var.env_name
    MinSize = var.min_size
    DesiredCapacity = var.desired_capacity
    MaxSize = var.max_size
    EKSInstanceType = var.instance_type
    EKSImageId = var.image_id
    RootVolSize = var.root_size
    RootVolDevice = var.root_device
    ExtraVolSize = var.extra_size
    ExtraVolDevice = var.extra_device
  }
  capabilities = ["CAPABILITY_IAM"]
  template_body = file("${path.module}/main.yaml")
}
