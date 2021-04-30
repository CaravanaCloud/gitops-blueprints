# https://docs.openebs.io/docs/next/postgres.html
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

module "wait_install" {
  source  = "matti/resource/shell"
  command = "sleep 15"
}

module "oebs_pods"{
  source  = "matti/resource/shell"
  command = "kubectl get pods -n openebs"
  depends_on = [module.wait_install]
}

module "oebs_blockdevices"{
  source  = "matti/resource/shell"
  command = "kubectl get blockdevice -n openebs"
  depends_on = [module.wait_install]
}

module "oebs_blockdevices_list"{
  source  = "matti/resource/shell"
  command = "kubectl get blockdevice -n openebs -o jsonpath='{range.items[*]}{\"    - \"}{.metadata.name}{\"\n\"}{end}'"
  depends_on = [module.wait_install]
}

resource "local_file" "cstor-pool1-config" {
  content     = templatefile("${path.module}/cstor-pool1-config.tpl", { blockDeviceList: module.oebs_blockdevices_list.stdout })
  filename = "${path.module}/cstor-pool1-config.out.yaml"
  depends_on = [module.oebs_blockdevices_list]
}

module "oebs_blockdevices_claimfile"{
  source  = "matti/resource/shell"
  command = "cat cstor-pool1-config.out.yaml"
}

module "oebs_blockdevices_claim_csp"{
  source  = "matti/resource/shell"
  command = "kubectl apply -f cstor-pool1-config.out.yaml"
}

module "wait_claim" {
  source  = "matti/resource/shell"
  command = "sleep 15"
}

module "oebs_verify_spc"{
  source  = "matti/resource/shell"
  command = "kubectl get spc"
}

module "oebs_verify_csp"{
  source  = "matti/resource/shell"
  command = "kubectl get csp"
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
  ## exit status
  ${module.oebs_pods.exitstatus}
  ## std err
  ${module.oebs_pods.stderr}

  # kubectl get blockdevice -n openebs
  ${module.oebs_blockdevices.stdout}
  ## exit status
  ${module.oebs_blockdevices.exitstatus}
  ## std err
  ${module.oebs_blockdevices.stderr}


  # oebs_blockdevices_list
  ${module.oebs_blockdevices_list.stdout}
  ## exit status
  ${module.oebs_blockdevices_list.exitstatus}
  ## std err
  ${module.oebs_blockdevices_list.stderr}

  # oebs_blockdevices_claimfile
  ${module.oebs_blockdevices_claimfile.stdout}
  ## exit status
  ${module.oebs_blockdevices_claimfile.exitstatus}
  ## std err
  ${module.oebs_blockdevices_claimfile.stderr}

  # oebs_blockdevices_claim_csp
  ${module.oebs_blockdevices_claim_csp.stdout}
  ## exit status
  ${module.oebs_blockdevices_claim_csp.exitstatus}
  ## std err
  ${module.oebs_blockdevices_claim_csp.stderr}

  # oebs_blockdevices_claim_csp
  ${module.oebs_blockdevices_claim_csp.stdout}
  ## exit status
  ${module.oebs_blockdevices_claim_csp.exitstatus}
  ## std err
  ${module.oebs_blockdevices_claim_csp.stderr}

  # oebs_verify_csp
  ${module.oebs_verify_csp.stdout}
  ## exit status
  ${module.oebs_verify_csp.exitstatus}
  ## std err
  ${module.oebs_verify_csp.stderr}

  # oebs_verify_csp
  ${module.oebs_verify_csp.stdout}
  ## exit status
  ${module.oebs_verify_csp.exitstatus}
  ## std err
  ${module.oebs_verify_csp.stderr}

  EOT
}





