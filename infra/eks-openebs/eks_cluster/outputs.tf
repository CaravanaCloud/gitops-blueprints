output "eks_role_arn" {
  value = aws_cloudformation_stack.eks.outputs["EKSClusterRoleArn"]
}
