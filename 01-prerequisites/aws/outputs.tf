output "bastion_public_fqdn" {
  description = "Public fqdn of bastion"
  value       = aws_instance.bastion.public_dns
}

# KMS outputs for Vault auto-unseal
output "vault_kms_key_id" {
  description = "KMS key ID for Vault auto-unseal"
  value       = aws_kms_key.vault_unseal.key_id
}

output "vault_kms_policy_arn" {
  description = "IAM policy ARN for Vault KMS access"
  value       = aws_iam_policy.vault_kms_unseal.arn
}