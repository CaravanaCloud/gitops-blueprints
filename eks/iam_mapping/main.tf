variable "env_name" {}
variable "role_arn" {}

module "create_iam_mapping" {
  source  = "matti/resource/shell"
  # command = "echo eksctl create iamidentitymapping --cluster ${var.env_name}EKS --arn ${aws_cloudformation_stack.kubectl_lambda.outputs["RunCtlRoleArn"]} --username runctlusr"
  command = "eksctl create iamidentitymapping --cluster ${var.env_name}EKS --arn ${var.role_arn} --username runctlusr"
}
