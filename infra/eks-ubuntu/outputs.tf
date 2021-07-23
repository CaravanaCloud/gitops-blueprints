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

output "create_iam_mapping_out" {
  value = module.iam_mapping.create_iam_mapping_out
}

output "eks_ready_out" {
  value = module.eks_ready.stdout
}

output "eks_kubeconfig_out" {
  value = module.eks_update_kubeconfig.stdout
}
