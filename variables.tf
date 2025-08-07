# generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "sandpit"
}

# enable & disable modules

variable "deploy_platform_k8s_eks" {
  description = "deploy k8s aws eks"
  type        = bool
  default     = false
}

variable "deploy_solution_k8s_vault" {
  description = "deploy k8s vault"
  type        = bool
  default     = false
}

variable "vault_auto_unseal" {
  description = "enable vault auto-unseal with AWS KMS"
  type        = bool
  default     = true
}

# amazon web services (aws) variables

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = ""
}

variable "aws_route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "use_route53_dns" {
  description = "Use Route53 managed DNS (true) or AWS LoadBalancer hostname (false)"
  type        = bool
  default     = true
}

variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
  default     = "10.200.0.0/16"
}

variable "letsencrypt_email" {
  description = "email address for Let's Encrypt certificate registration"
  type        = string
}

# hashicorp vault enterprise server variables

variable "vault_ent_license" {
  description = "vault enterprise license"
  type        = string
}
