output "public_cert_pem" {
  value = vault_pki_secret_backend_cert.client-auth.certificate
}

output "private_key_pem" {
  value = vault_pki_secret_backend_cert.client-auth.private_key
}