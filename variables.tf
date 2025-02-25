// generic variables

variable "deployment_name" {
  description = "deployment name to prefix resources"
  type        = string
  default     = "sandpit"
}

// enable & disable modules

variable "deploy_platform_k8s_eks" {
  description = "deploy k8s aws eks"
  type        = bool
  default     = false
}

// amazon web services (aws) variables

variable "aws_region" {
  description = "aws region"
  type        = string
  default     = ""
}

variable "aws_route53_sandbox_prefix" {
  description = "aws route53 sandbox account prefix"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "aws vpc cidr"
  type        = string
  default     = "10.200.0.0/16"
}