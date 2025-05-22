terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~>5.0.0"
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

data "aws_eks_cluster" "platform" {
  name = "${data.terraform_remote_state.tcm.outputs.deployment_id}-platform"
}

provider "kubernetes" {
  alias = "platform-eks"
  host                   = data.aws_eks_cluster.platform.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.platform.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.platform.name]
    command     = "aws"
  }
}

provider "helm" {
  alias = "platform-eks"
  kubernetes {
    host                   = data.aws_eks_cluster.platform.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.platform.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.platform.name]
      command     = "aws"
    }
  }
}