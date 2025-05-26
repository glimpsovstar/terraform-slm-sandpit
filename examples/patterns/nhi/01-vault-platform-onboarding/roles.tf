resource "vault_pki_secret_backend_role" "trusted-machine" {
   backend            = vault_mount.pki-int-machine-id.path
   issuer_ref         = vault_pki_secret_backend_issuer.int-machine-id.issuer_id
   name               = "trusted-machine"
   ttl                = 86400
   max_ttl            = 172800
   key_type           = "ed25519"
   key_bits           = 4096
   ext_key_usage      = ["ClientAuth"]
   allow_any_name     = true
   allow_subdomains   = false
   allowed_uri_sans   = ["spiffe://*"]
   organization       = ["HashiCorp"]
   country            = ["AU"]
}