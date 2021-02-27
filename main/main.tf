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
  default = "tfenv"
  
  validation {
    #TODO Actual supported regex is [A-Za-z0-9\-_]*
    condition     = can(regex("[A-Za-z0-9]*", var.env_name))
    error_message = "Environment name must satisfy regular expression pattern '[A-Za-z0-9]*-' ."
  }
}

variable "min_size" {
  type    = number
  default = 1
}

variable "desired_capacity" {
  type    = number
  default = 3
}

variable "max_size" {
  type    = number
  default = 12
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "root_size" {
  type    = number
  default = 16
}

variable "root_device" {
  type    = string
  default = "/dev/sda1"
}

variable "extra_size" {
  type    = number
  default = 1
}

variable "extra_device" {
  type    = string
  default = "/dev/sdh"
}


resource "aws_cloudformation_stack" "bc" {
  name = var.env_name

  parameters = {
    EnvName = var.env_name
    MinSize = var.min_size
    DesiredCapacity = var.desired_capacity
    MaxSize = var.max_size
    EKSInstanceType  = var.instance_type
    RootVolDevice = var.root_device
    RootVolSize = var.root_size
    ExtraVolDevice = var.extra_device
    ExtraVolSize = var.extra_size
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }


  capabilities = ["CAPABILITY_NAMED_IAM"]
  disable_rollback = true
  template_body = file("${path.module}/.main.out.yaml")
}
