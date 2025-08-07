variable "deployment_id" {
  description = "deployment identifier"
  type        = string
}

variable "region" {
  description = "aws region"
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "eks cluster version"
  type        = string
}

variable "cluster_suffix" {
  description = "eks cluster name suffix"
  type        = string
}

variable "worker_desired_capacity" {
  description = "eks worker nodes desired capacity"
  type        = number
}

variable "worker_instance_types" {
  description = "eks worker nodes instance type"
  type        = list(string)
  default     = ["m7i.large"]
}

variable "worker_capacity_type" {
  description = "eks worker nodes capacity type"
  type        = string
  default     = "ON_DEMAND"
}

variable "use_route53_dns" {
  description = "Whether to use Route53 DNS for ingress. When false, port 8200 will be exposed directly"
  type        = bool
  default     = true
}