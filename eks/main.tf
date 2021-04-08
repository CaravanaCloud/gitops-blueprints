terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
}

provider "aws" {}

variable "env_name" {
  type    = string
  default = "devenv"
}

module "kubectl_lambda"{
  source = "./kubectl_lambda"
}

module "storage"{
  source = "./storage"
  env_name = var.env_name
}

