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
  default = 1
}

variable "max_size" {
  type    = number
  default = 12
}

variable "instance_type" {
  type    = string
  default = "t3.medium"
}

variable "image_id" {
  type    = string
  default = "ami-025102f49d03bec05"
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


module "iam_admin" {
  source = "./iam_admin"
  env_name = var.env_name
}

module "storage" {
  source = "./storage"
  env_name = var.env_name
}

module "kubectl_layer" {
  source = "./kubectl_layer"
  env_name = var.env_name
}

module "network" {
  source = "./network"
  env_name = var.env_name
}

module "eks_cluster" {
  source = "./eks_cluster"
  env_name = var.env_name
  depends_on = [module.network]
}

module "eks_nodegroup" {
  source = "./eks_nodegroup"
  env_name = var.env_name
  min_size = var.min_size
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  instance_type = var.instance_type
  image_id = var.image_id
  root_size = var.root_size
  root_device = var.root_device
  extra_size = var.extra_size
  extra_device = var.extra_device
  depends_on = [module.eks_cluster]
}

module "kubectl_lambda" {
  source = "./kubectl_lambda"
  env_name = var.env_name
  bucket_name = module.storage.bucket_name
  layer_arn = module.kubectl_layer.layer_arn
  depends_on = [module.eks_cluster]
}

#module "invoke_kubectl_version" {
#  source = "./invoke_kubectl"
#  kubectl_fn = module.kubectl_lambda.kubectl_fn
#  kubectl_cmd = "kubectl version"
#}

#module "invoke_helm_version" {
#  source = "./invoke_kubectl"
#  kubectl_fn = module.kubectl_lambda.kubectl_fn
#  kubectl_cmd = "helm version"
#}

#module "invoke_eksctl_version" {
#  source = "./invoke_kubectl"
#  kubectl_fn = module.kubectl_lambda.kubectl_fn
#  kubectl_cmd = "eksctl version"
#}


