data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

# amazon web services (aws) kubernetes eks tenant cluster

module "tenant-k8s-eks" {
  source = "github.com/phan-t/terraform-slm-sandpit/02-platform/k8s/aws"
  
  region                        = data.terraform_remote_state.tcm.outputs.aws_region
  deployment_id                 = data.terraform_remote_state.tcm.outputs.deployment_id
  cluster_version               = "1.32"
  cluster_suffix                = var.tenant_name
  worker_desired_capacity       = 1
  worker_instance_types         = ["m7i.large"]
}

# vault sercrets operator

module "vault-secrets-operator" {
  source = "./01-vault-secrets-operator"

  providers = {
    helm = helm.tenant-eks
    kubernetes = kubernetes.tenant-eks
  }

  tenant_name        = var.tenant_name
  vault_address      = data.terraform_remote_state.tcm.outputs.vault_ui_fqdn
  helm_chart_version = "0.10.0"

  depends_on = [ 
    module.tenant-k8s-eks
  ]
}

# vault tenant configuration

module "vault-ent-tenant" {
  source = "./02-vault-tenant-onboarding"

  providers = {
    kubernetes = kubernetes.tenant-eks
  }

  tenant_name               = var.tenant_name
  kubernetes_api_endpoint   = module.tenant-k8s-eks.cluster_api_endpoint
  kubernetes_ca_certificate = module.tenant-k8s-eks.cluster_ca_certificate

  depends_on = [ 
    module.vault-secrets-operator 
  ]
}

# kubernetes tenant onboarding

module "k8s-tenant-onboarding" {
  source = "./03-k8s-tenant-onboarding"

  providers = {
    kubernetes = kubernetes.tenant-eks
  }

  tenant_name = var.tenant_name

  depends_on = [ 
    module.vault-secrets-operator 
  ]
}