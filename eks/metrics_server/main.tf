module "mainsh" {
  source  = "matti/resource/shell"
  command = "./openebs/main.sh"
}

output "mainsh_out" {
  value = module.mainsh.stdout
}