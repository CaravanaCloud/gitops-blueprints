terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

variable "env_name" {
  type    = string
  default = "DEVX"
}

resource "aws_cloudformation_stack" "bcstorage" {
  name = "${var.env_name}-STORAGE"

  parameters = {
    EnvName = var.env_name
  }

  template_body = file("${path.module}/storage.yaml")
}