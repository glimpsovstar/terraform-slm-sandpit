
# create minio oidc resources
resource "vault_identity_oidc_assignment" "minio" {
  name       = "minio"
  entity_ids = [
    vault_identity_entity.testuser1.id,
  ]
  group_ids  = [
    vault_identity_group.testing.id,
  ]
}

resource "vault_identity_oidc_key" "minio" {
  name      = "minio"
  allowed_client_ids = ["*"]
  algorithm = "RS256"
  verification_ttl = 7200
  rotation_period = 7200
}

resource "vault_identity_oidc_client" "minio" {
  name          = "minio"
  redirect_uris = [
    "http://${var.minio_console_address}:9001/oauth_callback",
  ]
  assignments = [
    vault_identity_oidc_assignment.minio.name,
  ]
  key = vault_identity_oidc_key.minio.name
  id_token_ttl     = 2400
  access_token_ttl = 7200
}

resource "vault_identity_oidc_provider" "minio" {
  name = "minio"
  https_enabled = true
  issuer_host = "vault.tphan.sbx.hashidemos.io:8200"
  allowed_client_ids = [
    vault_identity_oidc_client.minio.client_id,
  ]
  scopes_supported = [
    vault_identity_oidc_scope.user.name,
    vault_identity_oidc_scope.groups.name,
    vault_identity_oidc_scope.policies.name
  ]
}

resource "vault_identity_oidc_scope" "user" {
  name        = "user"
  template    = "{\"username\": {{identity.entity.name}}, \"contact\": { \"email\": {{identity.entity.metadata.email}} } }"
}

resource "vault_identity_oidc_scope" "groups" {
  name        = "groups"
  template    = "{\"groups\": {{identity.entity.groups.names}}}"
}

resource "vault_identity_oidc_scope" "policies" {
  name        = "policies"
  template    = "{\"minio\": \"consoleAdmin\"}"
}

# create testing identity token resources
resource "vault_identity_oidc_key" "testing" {
  name      = "testing"
  allowed_client_ids = ["*"]
  algorithm = "RS256"
  verification_ttl = 7200
  rotation_period = 7200
}

resource "vault_identity_oidc_role" "testing" {
  name = "testing"
  key  = vault_identity_oidc_key.testing.name
  template = "{\"username\": {{identity.entity.name}}, \"contact\": { \"email\": {{identity.entity.metadata.email}} } }"
  ttl = 60
}