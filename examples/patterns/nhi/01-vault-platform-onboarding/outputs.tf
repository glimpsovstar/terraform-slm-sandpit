output "oidc_client_id_minio" {
  value = vault_identity_oidc_client.minio.client_id
}

output "oidc_client_secret_minio" {
  value = vault_identity_oidc_client.minio.client_secret
}