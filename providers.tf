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
      version = "~> 5.88.0"
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

provider "aws" {
  region = var.aws_region
}

data "aws_eks_cluster" "platform" {
  count = var.deploy_platform_k8s_eks ? 1 : 0

  name = var.deploy_platform_k8s_eks == true ? module.platform-k8s-eks[0].cluster_name : null 
}

provider "kubernetes" {
  alias = "platform-eks"
  host                   = var.deploy_platform_k8s_eks == true ? data.aws_eks_cluster.platform[0].endpoint : null
  cluster_ca_certificate = var.deploy_platform_k8s_eks == true ? base64decode(data.aws_eks_cluster.platform[0].certificate_authority.0.data) : null
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.deploy_platform_k8s_eks == true ? data.aws_eks_cluster.platform[0].name : ""]
    command     = "aws"
  }
}

provider "helm" {
  alias = "platform-eks"
  kubernetes {
    host                   = var.deploy_platform_k8s_eks == true ? data.aws_eks_cluster.platform[0].endpoint : null
    cluster_ca_certificate = var.deploy_platform_k8s_eks == true ? base64decode(data.aws_eks_cluster.platform[0].certificate_authority.0.data) : null
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", var.deploy_platform_k8s_eks == true ? data.aws_eks_cluster.platform[0].name : ""]
      command     = "aws"
    }
  }
}