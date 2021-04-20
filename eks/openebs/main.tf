# https://docs.openebs.io/docs/next/installation.html
variable "cluster_name" {}

module "create_admin_context" {
  source  = "matti/resource/shell"
  command = "kubectl config set-context admin-ctx --cluster=${var.cluster_name} --user=cluster-admin"
}

module "use_admin_context" {
  source  = "matti/resource/shell"
  command = "kubectl config use-context admin-ctx"
}

module "mainsh" {
  source  = "matti/resource/shell"
  command = "./openebs/main.sh"
}

output "create_admin_context_out" {
  value = module.create_admin_context.stdout
}

output "use_admin_context_out" {
  value = module.use_admin_context.stdout
}

output "mainsh_out" {
  value = module.mainsh.stdout
}



