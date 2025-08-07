terraform {
  # cloud {
  #   organization = "tphan"
  #   workspaces {
  #     name = "terraform-slm-sandpit"
  #     project = "sandpits"
  #   }
  # }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

locals {
  cluster_name = "${local.deployment_id}-platform"
}

provider "aws" {
  region = var.aws_region
}

# Data sources to connect to the EKS cluster - only when cluster exists
data "aws_eks_cluster" "platform" {
  count = var.deploy_platform_k8s_eks ? 1 : 0
  name  = local.cluster_name
}

data "aws_eks_cluster_auth" "platform" {
  count = var.deploy_platform_k8s_eks ? 1 : 0
  name  = local.cluster_name
}

# Static provider configuration that works across all steps
provider "kubernetes" {
  alias = "platform-eks"
  
  # This configuration works because:
  # - Step 1: count=0, so no data sources evaluated, providers unused
  # - Step 2: EKS cluster created, data sources populated after cluster exists  
  # - Step 3: Full connectivity for Kubernetes resources
  host                   = length(data.aws_eks_cluster.platform) > 0 ? data.aws_eks_cluster.platform[0].endpoint : null
  cluster_ca_certificate = length(data.aws_eks_cluster.platform) > 0 ? base64decode(data.aws_eks_cluster.platform[0].certificate_authority[0].data) : null
  token                  = length(data.aws_eks_cluster_auth.platform) > 0 ? data.aws_eks_cluster_auth.platform[0].token : null
}

provider "helm" {
  alias = "platform-eks" 
  kubernetes {
    host                   = length(data.aws_eks_cluster.platform) > 0 ? data.aws_eks_cluster.platform[0].endpoint : null
    cluster_ca_certificate = length(data.aws_eks_cluster.platform) > 0 ? base64decode(data.aws_eks_cluster.platform[0].certificate_authority[0].data) : null
    token                  = length(data.aws_eks_cluster_auth.platform) > 0 ? data.aws_eks_cluster_auth.platform[0].token : null
  }
}