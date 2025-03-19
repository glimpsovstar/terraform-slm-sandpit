variable "tenant_name" {
  description = "tenant name"
  type        = string
}

variable "vault_token" {
  description = "vault token"
  type        = string
  sensitive   = true
}

variable "kubernetes_vso_service_account_name" {
  description = "kubernetes vso service account name"
  type        = string
  default     = "vso-auth"
}