# create tls certificate auth method for machine authentication
resource "vault_auth_backend" "machine-auth" {
  type = "cert"
}

# create userpass auth method for oidc human authentication
resource "vault_auth_backend" "userpass" {
  path       = "userpass"
  type       = "userpass"
}

# create test user resources for oidc human authentication
resource "vault_generic_endpoint" "testuser1" {
  path                 = "auth/userpass/users/testuser1"
  ignore_absent_fields = true

  data_json = <<EOT
{
"token_policies": ["oidc-auth"],
"token_ttl": "1h",
"password": "HashiCorp1!"
}
EOT

  depends_on = [
    vault_auth_backend.userpass
  ]
}

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