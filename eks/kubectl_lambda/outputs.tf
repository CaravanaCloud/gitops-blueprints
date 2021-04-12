output "sam_output" {
  value = module.sam_package.stdout
}

output "kubectl_fn" {
  value = aws_cloudformation_stack.kubectl_lambda.outputs["RunCtlFuncId"]
}


