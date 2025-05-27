locals {
  spiffe_id = "spiffe://sbx.hashidemos.io/${var.team_name}/${var.machine_function}"
}

data "vault_auth_backend" "cert" {
  path = var.machine_auth_mount_path
}

resource "vault_identity_entity" "machine-id" {
  name      = var.common_name

  metadata  = {
    spiffe_id = local.spiffe_id
  }
}

resource "vault_identity_entity_alias" "cert-auth" {
  name            = var.common_name
  mount_accessor  = data.vault_auth_backend.cert.accessor
  canonical_id    = vault_identity_entity.machine-id.id
}

resource "vault_identity_group" "this" {
  name     = var.team_name
  member_entity_ids = [
    vault_identity_entity.machine-id.id
  ]
}

# create testing identity token resources
resource "vault_identity_oidc_key" "machine-id" {
  name      = var.common_name
  allowed_client_ids = ["*"]
  algorithm = "RS256"
  verification_ttl = 7200
  rotation_period = 7200
}

resource "vault_identity_oidc_role" "machine-id" {
  name = var.common_name
  key  = vault_identity_oidc_key.machine-id.name
  template = "{\"spiffe_id\": ${local.spiffe_id} }"
  ttl = 60
}