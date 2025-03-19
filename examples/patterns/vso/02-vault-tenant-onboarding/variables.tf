variable "tenant_name" {
  description = "namespace name"
  type        = string
}

variable "kubernetes_api_endpoint" {
  description = "kubernetes api endpoint"
  type        = string
}

variable "kubernetes_ca_certificate" {
  description = "kubernetes ca certificate"
  type        = string
}

variable "kubernetes_oidc_discovery_url" {
  description = "oidc discovery url"
  type        = string
}

variable "kubernetes_vso_service_account_name" {
  description = "kubernetes vso service account name"
  type        = string
}