locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

# amazon web services (aws) infrastructure

module "infra-aws" {
  source  = "./01-prerequisites-infra/aws"
  
  region                      = var.aws_region
  deployment_id               = local.deployment_id
  vpc_cidr                    = var.aws_vpc_cidr
}