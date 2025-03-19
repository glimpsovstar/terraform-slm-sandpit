# create kubernetes auth backend
resource "vault_auth_backend" "kubernetes" {
  type      = "kubernetes"

  namespace = vault_namespace.tenant.path
}

# retreive token_reviewer_jwt for vault kubernetes auth backend config
data "kubernetes_secret" "vso-auth" {
  metadata {
    name = var.kubernetes_vso_service_account_name
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

// jwt authentication
# allows oidc discovery urls to not require authentication
resource "kubernetes_cluster_role_binding" "oidc_discovery_anonymous" {
  metadata {
    name = "oidc-discovery-anonymous"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "system:service-account-issuer-discovery"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "Group"
    name      = "system:unauthenticated"
    api_group = "rbac.authorization.k8s.io"
  }
}

# create jwt auth backend
resource "vault_jwt_auth_backend" "jwt" {
  path                  = "jwt"
  oidc_discovery_url    = var.kubernetes_oidc_discovery_url
  # oidc_discovery_ca_pem = base64decode(var.kubernetes_ca_certificate)
  bound_issuer          = var.kubernetes_oidc_discovery_url

  namespace             = vault_namespace.tenant.path

  depends_on = [ 
    kubernetes_cluster_role_binding.oidc_discovery_anonymous 
  ]
}