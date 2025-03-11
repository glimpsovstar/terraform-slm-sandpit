data "kubernetes_service" "vault-ui" {
  metadata {
    name = "vault-ui"
    namespace = "vault"
  }
  
  depends_on = [
    helm_release.vault-ent-server
  ]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" : "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  parameters = {
    fsType    = "ext4"
    encrypted = true
    type      = "gp3"
  }
}

resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "kubernetes_secret" "ent-license" {
  metadata {
    name = "vault-ent-license"
    namespace = "vault"
  }

  data = {
    license = var.ent_license
  }
}

resource "kubernetes_secret" "tls" {
  metadata {
    name      = "vault-tls-certificates"
    namespace = "vault"
  }

  data = {
    "vault.ca"  = tls_self_signed_cert.ca-cert.cert_pem
    "vault.crt" = tls_locally_signed_cert.server-signed-cert.cert_pem
    "vault.key" = nonsensitive(tls_private_key.server-key.private_key_pem)
  }
}