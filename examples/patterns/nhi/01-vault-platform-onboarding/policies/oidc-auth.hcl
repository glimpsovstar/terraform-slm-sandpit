path "identity/oidc/provider/minio/authorize" {
  capabilities = [ "read" ]
}

path "identity/oidc/token/*" {
  capabilities = ["read"]
}