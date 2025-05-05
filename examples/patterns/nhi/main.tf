data "terraform_remote_state" "tcm" {
  backend = "local"

  config = {
    path = "../../../terraform.tfstate"
  }
}

module "vault-platform-onboarding" {
  source = "./01-vault-platform-onboarding"  

  minio_console_address = "minio-console.tphan.sbx.hashidemos.io"
}

# module "vm-test-app" {
#   source = "./03-vm-test-app"

#   deployment_id       = data.terraform_remote_state.tcm.outputs.deployment_id
#   bastion_public_fqdn = data.terraform_remote_state.tcm.outputs.aws_bastion_public_fqdn
#   vault_address       = data.terraform_remote_state.tcm.outputs.vault_ui_fqdn
#   vault_version       = "1.19.0"
# }

# minio
module "k8s-minio" {
  source = "./04-k8s-minio"

  providers = {
    kubernetes = kubernetes.platform-eks
    helm       = helm.platform-eks
  }

  helm_chart_version       = "5.4.0"
  route53_sandbox_prefix   = "tphan"
  vault_address            = data.terraform_remote_state.tcm.outputs.vault_ui_fqdn
  oidc_client_id_minio     = module.vault-platform-onboarding.oidc_client_id_minio
  oidc_client_secret_minio = module.vault-platform-onboarding.oidc_client_secret_minio
}