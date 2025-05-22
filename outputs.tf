# generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

# amazon web services (aws) outputs

output "aws_region" {
  description = "aws region"
  value       = var.aws_region
}

output "aws_bastion_public_fqdn" {
  description = "aws public fqdn of bastion node"
  value       = module.infra-aws.bastion_public_fqdn
}

# hashicorp vault outputs

output "vault_ui_fqdn" {
  description = "vault fqdn"
  value       = var.deploy_solution_k8s_vault == true ? "https://vault.tphan.sbx.hashidemos.io:8200" : null
}

output "vault_ca_cert_pem" {
  description = "vault ca certificate"
  value       = var.deploy_solution_k8s_vault == true ? module.solution-k8s-vault-ent[0].vault_ca_cert_pem : null
  sensitive = true
}