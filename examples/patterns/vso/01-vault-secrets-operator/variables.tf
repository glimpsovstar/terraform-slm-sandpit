
variable "tenant_name" {
  description = "namespace name"
  type        = string
}

variable "vault_address" {
  description = "vault address"
  type        = string
}

variable "helm_chart_version" {
  description = "vso helm chart version"
  type        = string
}

variable "kubernetes_vso_service_account_name" {
  description = "kubernetes vso service account name"
  type        = string
}