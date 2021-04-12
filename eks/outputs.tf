output "bucket_name" {
  value = module.storage.bucket_name
}

output "eks_name" {
  value = module.network.eks_name
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "pub_nets" {
  value = module.network.pub_nets
}

output "pub_net1" {
  value = module.network.pub_net1
}

output "pub_net2" {
  value = module.network.pub_net2
}

output "pvt_nets" {
  value = module.network.pvt_nets
}

output "pvt_net1" {
  value = module.network.pvt_net1
}

output "pvt_net2" {
  value = module.network.pvt_net2
}

output "eks_cluster_sg_id" {
  value = module.network.eks_cluster_sg_id
}

output "eks_node_sg_id" {
  value = module.network.eks_node_sg_id
}

/* Work In Progress

output "kubectl_layer_version" {
  value = module.kubectl_layer.layer_version
}

output "kubectl_layer_template_url" {
  value = module.kubectl_layer.layer_template_url
}

output "kubectl_layer_arn" {
  value = module.kubectl_layer.layer_arn
}

output "kubectl_fn" {
  value = module.kubectl_lambda.kubectl_fn
}

output "kubectl_role_arn" {
  value = module.kubectl_lambda.kubectl_role_arn
}

output "kubectl_mapping" {
  value = module.iam_mapping.iam_mapping_output
}

output "kubectl_lambda_fn" {
  value = module.kubectl_lambda.kubectl_fn
}

output "sam_output" {
  value = module.sam_package.stdout
}

output "kubectl_version" {
  value = module.invoke_kubectl_version.result
}

output "helm_version" {
  value = module.invoke_helm_version.result
}

output "eksctl_version" {
  value = module.invoke_eksctl_version.result
}
*/
