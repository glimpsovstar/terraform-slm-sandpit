output "ca_chain_pem" {
  value = vault_pki_secret_backend_cert.machine-id.ca_chain
}

output "public_cert_pem" {
  value = vault_pki_secret_backend_cert.machine-id.certificate
}

output "private_key_pem" {
  value = vault_pki_secret_backend_cert.machine-id.private_key
}