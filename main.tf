locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

# amazon web services (aws) infrastructure

module "infra-aws" {
  source  = "./01-prerequisites/aws"
  
  region        = var.aws_region
  deployment_id = local.deployment_id
  vpc_cidr      = var.aws_vpc_cidr
}

# amazon web services (aws) kubernetes eks cluster

module "platform-k8s-eks" {
  source  = "./02-platform/k8s/aws"

  count = var.deploy_platform_k8s_eks ? 1 : 0
  
  region                  = var.aws_region
  deployment_id           = local.deployment_id
  cluster_version         = "1.32"
  worker_desired_capacity = 3
  worker_instance_types   = ["m7i.large"]
}