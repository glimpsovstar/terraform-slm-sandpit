resource "vault_identity_entity" "testuser1" {
  name      = "testuser1"

  metadata  = {
    email = "testuser1@sbx.hashidemos.io"
  }
}

resource "vault_identity_group" "testing" {
  name     = "testing"
  member_entity_ids = [
    vault_identity_entity.testuser1.id
  ]
}

resource "vault_identity_entity_alias" "testuser1" {
  name            = "testuser1"
  mount_accessor  = vault_auth_backend.userpass.accessor
  canonical_id    = vault_identity_entity.testuser1.id
}