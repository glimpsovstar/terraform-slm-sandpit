resource "vault_mount" "kvv2" {
  path        = "secrets"
  type        = "kv-v2"
  options = {
    version = "2"
    type    = "kv-v2"
  }

  namespace = vault_namespace.tenant.path
}

resource "vault_kv_secret_v2" "sample1" {
  mount                      = vault_mount.kvv2.path
  name                       = "sample1"
  cas                        = 1
  delete_all_versions        = true
  data_json                  = jsonencode(
  {
    foo  = "bar",
    baz  = "qux",
    beep = "boop",
  }
  )

  namespace = vault_namespace.tenant.path
}