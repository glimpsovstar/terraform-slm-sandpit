resource "vault_cert_auth_backend_role" "machine-auth" {
    name           = var.common_name
    certificate    = vault_pki_secret_backend_cert.machine-id.certificate
    backend        = var.machine_auth_mount_path
    token_ttl      = 300
    token_max_ttl  = 600
    token_policies = ["${var.machine_auth_policy}"]
}