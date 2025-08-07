variable "deployment_id" {
  description = "deployment identifier"
  type        = string
}

variable "vault_version" {
  description = "vault version"
  type        = string
  default     = "latest"
}

variable "ent_license" {
  description = "vault enterprise license"
  type        = string
}

variable "replicas" {
  description = "vault server replicas"
  type        = number
  default     = 3
}

variable "helm_chart_version" {
  description = "vault helm chart version"
  type        = string
}

variable "route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "use_route53_dns" {
  description = "Use Route53 managed DNS (true) or AWS LoadBalancer hostname (false)"
  type        = bool
  default     = true
}

# Auto-unseal variables
variable "kms_key_id" {
  description = "AWS KMS key ID for Vault auto-unseal"
  type        = string
}

variable "vault_kms_role_arn" {
  description = "IAM role ARN for Vault KMS access"
  type        = string
}

variable "aws_region" {
  description = "AWS region for KMS"
  type        = string
}

variable "use_letsencrypt_prod" {
  description = "Use Let's Encrypt production (true) or staging (false)"
  type        = bool
  default     = false
}