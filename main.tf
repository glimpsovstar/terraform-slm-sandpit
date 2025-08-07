locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

# amazon web services (aws) infrastructure

module "infra-aws" {
  source = "./01-prerequisites/aws"
  
  region        = var.aws_region
  deployment_id = local.deployment_id
  vpc_cidr      = var.aws_vpc_cidr
}

# amazon web services (aws) kubernetes eks cluster

module "platform-k8s-eks" {
  source = "./02-platform/k8s/aws"

  count = var.deploy_platform_k8s_eks ? 1 : 0
  
  region                  = var.aws_region
  deployment_id           = local.deployment_id
  cluster_version         = "1.32"
  cluster_suffix          = "platform"
  worker_desired_capacity = 3
  worker_instance_types   = ["m7i.large"]
}

# hashicorp vault enterprise server kubernetes deployment

module "solution-k8s-vault-ent" {
  source = "./03-solution/k8s/vault"

  providers = {
    helm = helm.platform-eks
    kubernetes = kubernetes.platform-eks
   }
   
  count = var.deploy_solution_k8s_vault ? 1 : 0

  deployment_id          = local.deployment_id
  vault_version          = "1.19.1"
  ent_license            = var.vault_ent_license
  helm_chart_version     = "0.30.0"
  route53_sandbox_prefix = var.aws_route53_sandbox_prefix
  
  # Auto-unseal configuration
  kms_key_id         = module.platform-k8s-eks[0].vault_kms_key_id
  vault_kms_role_arn = module.platform-k8s-eks[0].vault_kms_role_arn
  aws_region         = var.aws_region
  
  # Let's Encrypt configuration - now using production
  use_letsencrypt_prod = true
}