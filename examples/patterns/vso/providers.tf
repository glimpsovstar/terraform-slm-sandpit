terraform {
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
    vault = {
      source  = "hashicorp/vault"
      version = "~>4.6.0"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.tcm.outputs.aws_region
}

provider "vault" {
  address         = data.terraform_remote_state.tcm.outputs.vault_ui_fqdn
  token           = var.vault_token
  skip_tls_verify = true
}

data "aws_eks_cluster" "tenant" {
  name = module.tenant-k8s-eks.cluster_name

  depends_on = [ 
    module.tenant-k8s-eks
  ]
}

provider "kubernetes" {
  alias = "tenant-eks"
  host                   = data.aws_eks_cluster.tenant.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.tenant.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.tenant.name]
    command     = "aws"
  }
}

provider "helm" {
  alias = "tenant-eks"
  kubernetes {
    host                   = data.aws_eks_cluster.tenant.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.tenant.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.tenant.name]
      command     = "aws"
    }
  }
}