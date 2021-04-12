variable kubectl_fn {}
variable kubectl_cmd {
  default = "kubectl version"
}

data "aws_lambda_invocation" "kubectl_version" {
  function_name = var.kubectl_fn
  input = <<JSON
  { "runctl_cmd": "${var.kubectl_cmd}" }
JSON
}

output "invocation_result" {
  value = jsondecode(data.aws_lambda_invocation.kubectl_version.result)
}