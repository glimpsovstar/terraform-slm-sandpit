variable "helm_chart_version" {
  description = "minio helm chart version"
  type        = string
}

variable "route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "vault_address" {
  type        = string  
}

variable "oidc_client_id_minio" {
  type        = string
}

variable "oidc_client_secret_minio" {
  type        = string
}