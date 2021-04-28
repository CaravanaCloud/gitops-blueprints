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

module "get_current_context" {
  source  = "matti/resource/shell"
  command = "kubectl config current-context"
}

module "set_context" {
  source  = "matti/resource/shell"
  command = "kubectl config set-context ${module.get_current_context.stdout} --namespace=openebs"
}

module "create_oebs_ns" {
  source  = "matti/resource/shell"
  command = "kubectl create ns openebs"
}

module "helm_add_repo" {
  source  = "matti/resource/shell"
  command = "helm repo add openebs https://openebs.github.io/charts"
}

module "helm_repo_update" {
  source  = "matti/resource/shell"
  command = "helm repo update"
}

module "helm_install_oebs" {
  source  = "matti/resource/shell"
  command = "helm install openebs openebs/openebs"
}

module "helm_ls" {
  source  = "matti/resource/shell"
  command = "helm ls"
}

module "oebs_pods"{
  source  = "matti/resource/shell"
  command = "kubectl get pods -n openebs"
}

module "oebs_blockdevices"{
  source  = "matti/resource/shell"
  command = "kubectl get blockdevice -n openebs"
}

module "oebs_blockdevices_list"{
  source  = "matti/resource/shell"
  command = "kubectl get blockdevice -n openebs -o=jsonpath='{range.items[*]}{\"    - \"}{.metadata.name}{\"\n\"}{end}'"
}

resource "local_file" "cstor-pool1-config" {
  content     = templatefile("${path.module}/cstor-pool1-config.tpl", { blockDeviceList: module.oebs_blockdevices_list.stdout })
  filename = "${path.module}/cstor-pool1-config.out.yaml"
}

module "oebs_blockdevices_claimfile"{
  source  = "matti/resource/shell"
  command = "cat cstor-pool1-config.out.yaml"
}

output "oebs_out" {
  value = <<EOT
  # kubectl config set-context admin-ctx --cluster=${var.cluster_name} --user=cluster-admin
  ${module.create_admin_context.stdout}

  # kubectl config use-context admin-ctx
  ${module.use_admin_context.stdout}

  # kubectl config current-context
  ${module.get_current_context.stdout}

  # kubectl config set-context ${module.get_current_context.stdout} --namespace=openebs
  ${module.set_context.stdout}

  # kubectl create ns openebs
  ${module.create_oebs_ns.stdout}

  # helm repo add/update
  ${module.helm_add_repo.stdout}
  ${module.helm_repo_update.stdout}

  # helm install openebs
  ## out
  ${module.helm_install_oebs.stdout}
  ## exit status
  ${module.helm_install_oebs.exitstatus}
  ## err
  ${module.helm_install_oebs.stderr}

  # helm ls
  ${module.helm_ls.stdout}
  ${module.helm_ls.exitstatus}
  ${module.helm_ls.stderr}

  # kubectl get pods -n openebs
  ${module.oebs_pods.stdout}

  # kubectl get blockdevice -n openebs
  ${module.oebs_blockdevices.stdout}

  # oebs_blockdevices_list
  ${module.oebs_blockdevices_list.stdout}

  # oebs_blockdevices_claimfile
  ${module.oebs_blockdevices_claimfile.stdout}

  EOT
}





