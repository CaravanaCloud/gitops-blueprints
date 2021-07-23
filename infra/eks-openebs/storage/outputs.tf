output "bucket_name" {
  value = aws_cloudformation_stack.storage.outputs["ArtifactsBucketName"]
}
