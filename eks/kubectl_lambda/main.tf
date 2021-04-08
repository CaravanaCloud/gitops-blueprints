variable "kubectl_layer_app_id" {
  type = string
  default = "arn:aws:serverlessrepo:us-east-1:903779448426:applications/lambda-layer-kubectl"
}

module "kubectl_layer_version_cmd" {
  source  = "matti/resource/shell"
  command = "aws serverlessrepo get-application --application-id ${var.kubectl_layer_app_id} --query 'Version.SemanticVersion' --output text"
}

module "kubectl_layer_cfn_cmd" {
  source  = "matti/resource/shell"
  command = "aws serverlessrepo create-cloud-formation-template --application-id  ${var.kubectl_layer_app_id} --semantic-version ${module.kubectl_layer_version_cmd.stdout} --query TemplateUrl --output text"
}

output "layer_version" {
  value = module.kubectl_layer_version_cmd.stdout
}

output "layer_template_url" {
  value = module.kubectl_layer_cfn_cmd.stdout
}

