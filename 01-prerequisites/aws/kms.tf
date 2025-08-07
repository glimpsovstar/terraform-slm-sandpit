# AWS KMS Key for Vault Auto-Unseal

resource "aws_kms_key" "vault_unseal" {
  description             = "KMS key for Vault auto-unseal - ${var.deployment_id}"
  deletion_window_in_days = 7
  
  tags = {
    Name        = "${var.deployment_id}-vault-unseal-key"
    Purpose     = "vault-auto-unseal"
    Environment = var.deployment_id
  }
}

resource "aws_kms_alias" "vault_unseal" {
  name          = "alias/${var.deployment_id}-vault-unseal"
  target_key_id = aws_kms_key.vault_unseal.key_id
}

# IAM Policy for Vault to use KMS
resource "aws_iam_policy" "vault_kms_unseal" {
  name        = "${var.deployment_id}-vault-kms-unseal"
  description = "Policy for Vault to use KMS for auto-unseal"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = aws_kms_key.vault_unseal.arn
      }
    ]
  })

  tags = {
    Name        = "${var.deployment_id}-vault-kms-unseal-policy"
    Environment = var.deployment_id
  }
}
