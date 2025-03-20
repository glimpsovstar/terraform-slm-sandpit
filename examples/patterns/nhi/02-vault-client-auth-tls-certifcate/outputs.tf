output "client_auth_certificate" {
  value = vault_pki_secret_backend_cert.client-auth.certificate
}

output "client_auth_private_key" {
  value = vault_pki_secret_backend_cert.client-auth.private_key
}