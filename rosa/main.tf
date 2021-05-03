terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}


variable "env_name" {
  type    = string
  default = "tfenv"

  validation {
    condition     = can(regex("[A-Za-z0-9]*", var.env_name))
    error_message = "Environment name must not contain weird chars"
  }
}

module "hello_world" {
  source  = "matti/resource/shell"
  command = "echo Hello environment [${var.env_name}]"
}
