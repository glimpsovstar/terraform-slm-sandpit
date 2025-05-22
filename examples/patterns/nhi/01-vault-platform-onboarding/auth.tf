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