# create sample kv-v2 secrets
resource "vault_mount" "kvv2" {
  path        = "secrets"
  type        = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }
}

resource "vault_kv_secret_v2" "example1" {
  mount                      = vault_mount.kvv2.path
  name                       = "example1"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    zip  = "zap",
    foo = "bar",
  }
  )
}
