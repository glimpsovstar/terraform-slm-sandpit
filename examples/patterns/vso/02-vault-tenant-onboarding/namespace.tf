resource "vault_namespace" "tenant" {
  path = var.tenant_name
}