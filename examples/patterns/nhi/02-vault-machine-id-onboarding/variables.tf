variable "pki_mount_path" {
  description = "pki mount path"
  type        = string
}

variable "machine_auth_mount_path" {
  description = "machine authentication mount path"
  type        = string
}

variable "machine_auth_policy" {
  description = "machine authentication policy"
  type        = string
}

variable "common_name" {
  description = "common name"
  type        = string
}

variable "pki_role" {
  description = "pki role"
  type        = string
}