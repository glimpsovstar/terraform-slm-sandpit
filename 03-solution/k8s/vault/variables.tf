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