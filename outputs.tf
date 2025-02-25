// generic outputs

output "deployment_id" {
  description = "deployment identifier"
  value       = local.deployment_id
}

// amazon web services (aws) outputs

output "aws_bastion_public_fqdn" {
  description = "aws public fqdn of bastion node"
  value       = module.infra-aws.bastion_public_fqdn
}