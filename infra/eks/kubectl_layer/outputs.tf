output "layer_version" {
  value = module.kubectl_layer_version_cmd.stdout
}

output "layer_template_url" {
  value = module.kubectl_layer_cfn_cmd.stdout
}

output "layer_arn" {
  value = aws_cloudformation_stack.kubectl_layer.outputs["LayerVersionArn"]
}
