resource "vault_kubernetes_auth_backend_role" "this" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = var.tenant_name
  bound_service_account_names      = ["vso-auth"]
  bound_service_account_namespaces = ["*"]
  token_ttl                        = 86400
  token_policies                   = ["default", "${var.tenant_name}"]
  alias_name_source                = "serviceaccount_name"

  namespace                        = vault_namespace.tenant.path
}