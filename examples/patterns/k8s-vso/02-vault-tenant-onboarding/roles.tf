resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.tenant_name
  bound_service_account_names      = ["${var.kubernetes_vso_service_account_name}"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["secrets-read-only"]
  alias_name_source                = "serviceaccount_name"

  namespace                        = vault_namespace.tenant.path
}


resource "vault_jwt_auth_backend_role" "secrets-read-only" {
  backend         = vault_jwt_auth_backend.jwt.path
  role_name       = var.tenant_name
  role_type       = "jwt"
  bound_audiences = ["https://kubernetes.default.svc"]

  # use the nested service account name as the user claim
  user_claim              = "/kubernetes.io/serviceaccount/name"
  user_claim_json_pointer = true
  token_policies          = ["secrets-read-only"]

  # enables wildcard matching for claims
  bound_claims_type = "glob"
  bound_claims = {
    # service account name must match
    "/kubernetes.io/serviceaccount/name" = var.kubernetes_vso_service_account_name,
    # the namespace must match
    "/kubernetes.io/namespace" = "tenant*"
  }

  namespace       = vault_namespace.tenant.path
}