variable "cluster_name" {}

module "create_admin_context" {
  source  = "matti/resource/shell"
  command = "kubectl config set-context admin-ctx --cluster=${var.cluster_name} --user=cluster-admin"
}

output "debug_out" {
  value = module.create_admin_context.stdout
}
