data "kubernetes_service" "minio-console" {
  metadata {
    name = "minio-console"
    namespace = "minio"
  }
  
  depends_on = [
    helm_release.minio
  ]
}

data "kubernetes_secret" "vault-tls-certificates" {
  metadata {
    name = "vault-tls-certificates"
    namespace = "vault"
  }
}

resource "kubernetes_namespace" "minio" {
  metadata {
    name = "minio"
  }
}

resource "kubernetes_secret" "minio-trusted-certs" {
  metadata {
    name      = "minio-trusted-certs"
    namespace = "minio"
  }

  data = {
    "vault.crt" = data.kubernetes_secret.vault-tls-certificates.data["vault.crt"]
  }
}