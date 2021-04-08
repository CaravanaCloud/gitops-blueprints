variable "env_name" {}

resource "aws_cloudformation_stack" "storage" {
  name = "${var.env_name}-STRG"
  parameters = {
    EnvName = var.env_name
  }
  template_body = file("${path.module}/main.yaml")
}

output "bucket_name" {
  value = aws_cloudformation_stack.storage.outputs["ArtifactsBucketName"]
}