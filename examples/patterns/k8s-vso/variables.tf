variable "tenant_name" {
  description = "tenant name"
  type        = string
}

variable "vault_token" {
  description = "vault token"
  type        = string
  sensitive   = true
}