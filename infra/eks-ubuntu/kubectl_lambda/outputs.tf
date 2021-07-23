output "kubectl_fn" {
  value = aws_cloudformation_stack.kubectl_lambda.outputs["RunCtlFuncId"]
}

output "kubectl_role_arn" {
  value = aws_cloudformation_stack.kubectl_lambda.outputs["RunCtlRoleArn"]
}


