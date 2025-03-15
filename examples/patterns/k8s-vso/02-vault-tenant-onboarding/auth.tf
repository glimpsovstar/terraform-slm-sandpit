# create kubernetes auth backend
resource "vault_auth_backend" "kubernetes" {
  type      = "kubernetes"

  namespace = vault_namespace.tenant.path
}

# retreive token_reviewer_jwt for vault kubernetes auth backend config
data "kubernetes_secret" "vso-auth" {
  metadata {
    name = "vso-auth"
    namespace = "vault"
  }
}

resource "vault_kubernetes_auth_backend_config" "this" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = var.kubernetes_api_endpoint
  kubernetes_ca_cert     = base64decode(var.kubernetes_ca_certificate)
  token_reviewer_jwt     = data.kubernetes_secret.vso-auth.data["token"]
  disable_local_ca_jwt   = true

  namespace              = vault_namespace.tenant.path
}