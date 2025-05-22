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
  name            = "cert-auth"
  mount_accessor  = data.vault_auth_backend.cert.accessor
  canonical_id    = vault_identity_entity.machine-id.id
}

resource "vault_identity_group" "this" {
  name     = var.team_name
  member_entity_ids = [
    vault_identity_entity.machine-id.id
  ]
}
