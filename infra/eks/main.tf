terraform {
  required_providers {
    aws = {
      version = "~> 3.0"
    }
  }
  backend "s3" {}
}

provider "aws" {}

variable "env_name" {
  type    = string

  validation {
    condition     = can(regex("[A-Za-z0-9-]*", var.env_name))
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
  default = "t3a.medium"
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

variable "aws_nuke" {
  type = string
  default = "true"
}

variable "capacity_type" {
  type = string
  default = "ON_DEMAND"
}

module "helm_install" {
  source = "helm_install"
}

module "iam_admin" {
  source = "iam_admin"
  env_name = var.env_name
  aws_nuke = var.aws_nuke
}

module "storage" {
  source = "storage"
  env_name = var.env_name
  aws_nuke = var.aws_nuke
}

module "network" {
  source = "..\/aws\/network"
  env_name = var.env_name
  aws_nuke = var.aws_nuke
}

module "eks_cluster" {
  source = "eks_cluster"
  env_name = var.env_name
  depends_on = [module.network]
  aws_nuke = var.aws_nuke
}

module "eks_nodegroup" {
  source = "eks_nodegroup"
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
  aws_nuke = var.aws_nuke
  capacity_type = var.capacity_type
  depends_on = [module.eks_cluster]
}

module "iam_mapping" {
  source = "iam_mapping"
  cluster_name = module.network.eks_name
  role_arn = module.eks_cluster.eks_role_arn
  depends_on = [module.eks_cluster]
}

module "eks_update_kubeconfig" {
  source  = "matti/resource/shell"
  command = "aws eks update-kubeconfig --name ${module.network.eks_name}"
  depends_on = [module.eks_nodegroup]
}

module "eks_ready" {
  source  = "matti/resource/shell"
  command = "kubectl get nodes"
  depends_on = [module.eks_update_kubeconfig]
}

module "openebs" {
  source = "openebs"
  cluster_name = module.network.eks_name
  depends_on = [module.eks_ready]
}

/* Work In Progress: Kubectl Lambda

module "kubectl_layer" {
  source = "./kubectl_layer"
  env_name = var.env_name
}

module "sam_package" {
  source  = "matti/resource/shell"
  command = "mkdir -p ./kubectl_lambda/target && sam package --template-file ${path.module}/kubectl_lambda/main.yaml --s3-bucket ${module.storage.bucket_name} --output-template-file ${path.module}/kubectl_lambda/target/main.out.yaml "
}

module "kubectl_lambda" {
  source = "./kubectl_lambda"
  env_name = var.env_name
  bucket_name = module.storage.bucket_name
  layer_arn = module.kubectl_layer.layer_arn
  depends_on = [module.storage, module.eks_cluster, module.sam_package.stdout]
}



module "invoke_kubectl_version" {
  source = "./invoke_kubectl"
  command = "kubectl version"
  function_name = module.kubectl_lambda.kubectl_fn
}

module "invoke_helm_version" {
  source = "./invoke_kubectl"
  command = "helm version"
  function_name = module.kubectl_lambda.kubectl_fn
}

module "invoke_eksctl_version" {
  source = "./invoke_kubectl"
  command = "eksctl version"
  function_name = module.kubectl_lambda.kubectl_fn
}
*/
