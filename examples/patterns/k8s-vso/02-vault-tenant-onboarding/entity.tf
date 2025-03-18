resource "vault_identity_entity" "this" {
  name      = var.tenant_name
  policies  = ["${var.tenant_name}"]

  namespace = vault_namespace.tenant.path
}

resource "vault_identity_entity_alias" "this" {
  name            = var.kubernetes_vso_service_account_name
  mount_accessor  = vault_jwt_auth_backend.jwt.accessor
  canonical_id    = vault_identity_entity.this.id

  namespace       = vault_namespace.tenant.path
}