variable function_name {}
variable command {
  default = "kubectl version"
}

data "aws_lambda_invocation" "kubectl_version" {
  function_name = var.function_name
  input = <<JSON
  { "runctl_cmd": "${var.command}" }
JSON
}

output "result" {
  value = data.aws_lambda_invocation.kubectl_version.result
}