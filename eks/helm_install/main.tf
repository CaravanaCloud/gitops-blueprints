module "helm_check" {
  source  = "matti/resource/shell"
  command = "helm version || export INSTALL_HELM=1"
}

module "helm_install_cmd" {
  source  = "matti/resource/shell"
  command = "[[ ! -z \"$INSTALL_HELM\" ]] && curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash"
}

module "helm_verify" {
  source  = "matti/resource/shell"
  command = "helm version"
}


output "helm_install_out" {
  value = <<EOT
  # helm_check
  ${module.helm_check.stdout}
  ## exit status
  ${module.helm_check.exitstatus}
  ## std err
  ${module.helm_check.stderr}

  # helm_install_cmd
  ${module.helm_install_cmd.stdout}
  ## exit status
  ${module.helm_install_cmd.exitstatus}
  ## std err
  ${module.helm_install_cmd.stderr}

  # helm_verify
  ${module.helm_verify.stdout}
  ## exit status
  ${module.helm_verify.exitstatus}
  ## std err
  ${module.helm_verify.stderr}

  EOT
}