variable "deployment_id" {
  description = "deployment id"
  type        = string
}

variable "bastion_public_fqdn" {
  description = "public fqdn of bastion node"
  type        =  string 
}

variable "vault_address" {
  type = string
}

variable "vault_ca_cert_pem" {
  type = string
  sensitive = true
}

variable "vault_version" {
  type = string
}
