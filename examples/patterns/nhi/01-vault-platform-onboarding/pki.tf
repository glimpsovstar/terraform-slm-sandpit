// internal root ca

resource "vault_mount" "pki-root" {
  path        = "pki-root"
  type        = "pki"
  description = "root pki mount"

  default_lease_ttl_seconds = 86400
  max_lease_ttl_seconds     = 31536000
}

resource "vault_pki_secret_backend_root_cert" "root" {
   backend     = vault_mount.pki-root.path
   type        = "internal"
   common_name = "sandpit.com"
   ttl         = 31536000
   issuer_name = "root"
}

resource "vault_pki_secret_backend_issuer" "root" {
   backend                        = vault_mount.pki-root.path
   issuer_ref                     = vault_pki_secret_backend_root_cert.root.issuer_id
   issuer_name                    = vault_pki_secret_backend_root_cert.root.issuer_name
   revocation_signature_algorithm = "SHA256WithRSA"
}

// internal intermediate ca for machine identity

resource "vault_mount" "pki-int-machine-id" {
   path        = "pki-int-machine-id"
   type        = "pki"
   description = "intermediate machine identity pki mount"

   default_lease_ttl_seconds = 86400
   max_lease_ttl_seconds     = 31536000
}

resource "vault_pki_secret_backend_intermediate_cert_request" "int-machine-id" {
   backend     = vault_mount.pki-int-machine-id.path
   type        = "internal"
   common_name = "machine-id.int.sandpit.com"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "int-machine-id" {
   backend     = vault_mount.pki-root.path
   common_name = "machine-id.int.sandpit.com"
   csr         = vault_pki_secret_backend_intermediate_cert_request.int-machine-id.csr
   format      = "pem_bundle"
   ttl         = 31536000
   issuer_ref  = vault_pki_secret_backend_root_cert.root.issuer_id
}

resource "vault_pki_secret_backend_intermediate_set_signed" "int-machine-id" {
   backend     = vault_mount.pki-int-machine-id.path
   certificate = vault_pki_secret_backend_root_sign_intermediate.int-machine-id.certificate
}

resource "vault_pki_secret_backend_issuer" "int-machine-id" {
  backend     = vault_mount.pki-int-machine-id.path
  issuer_ref  = vault_pki_secret_backend_intermediate_set_signed.int-machine-id.imported_issuers[0]
  issuer_name = "machine-id-sandpit-dot-com-intermediate"
}