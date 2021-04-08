output "bucket_name" {
  value = module.storage.bucket_name
}

output "kubectl_layer_version" {
  value = module.kubectl_lambda.layer_version
}

output "kubectl_layer_template_url" {
  value = module.kubectl_lambda.layer_template_url
}
