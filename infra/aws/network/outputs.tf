output "eks_name" {
  value = aws_cloudformation_stack.network.outputs["EKSName"]
}

output "vpc_id" {
  value = aws_cloudformation_stack.network.outputs["VPC"]
}

output "pub_nets" {
  value = aws_cloudformation_stack.network.outputs["PublicSubnets"]
}

output "pub_net1" {
  value = aws_cloudformation_stack.network.outputs["PublicSubnet1"]
}

output "pub_net2" {
  value = aws_cloudformation_stack.network.outputs["PublicSubnet2"]
}

output "pvt_nets" {
  value = aws_cloudformation_stack.network.outputs["PrivateSubnets"]
}

output "pvt_net1" {
  value = aws_cloudformation_stack.network.outputs["PrivateSubnet1"]
}

output "pvt_net2" {
  value = aws_cloudformation_stack.network.outputs["PrivateSubnet2"]
}

output "eks_cluster_sg_id" {
  value = aws_cloudformation_stack.network.outputs["EKSClusterSGId"]
}

output "eks_node_sg_id" {
  value = aws_cloudformation_stack.network.outputs["EKSNodeSGId"]
}

output "db_sg_id" {
  value = aws_cloudformation_stack.network.outputs["DBSGId"]
}


