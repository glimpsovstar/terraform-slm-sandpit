resource "vault_cert_auth_backend_role" "cert" {
    name           = var.common_name
    certificate    = vault_pki_secret_backend_cert.client-auth.certificate
    backend        = var.client_auth_mount_path
    token_ttl      = 300
    token_max_ttl  = 600
    token_policies = ["client-auth"]
}