output "simple_bucket_name" {
  value = aws_cloudformation_stack.main.outputs["SimpleBucketName"]
}