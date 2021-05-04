variable "cluster_name" {}
variable "role_arn" {}

module "create_iam_mapping" {
  source  = "matti/resource/shell"
  command = "eksctl create iamidentitymapping --cluster ${var.cluster_name} --arn ${var.role_arn} --username cluster-admin"
}
