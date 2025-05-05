resource "local_file" "minio-helm-values" {
  content = templatefile("${path.module}/templates/minio-helm.yml.tpl", {
    root_password = "HashiCorp1!"
    oidc_provider_address = "${var.vault_address}/v1/identity/oidc/provider/minio/.well-known/openid-configuration"
    oidc_client_id = var.oidc_client_id_minio
    oidc_client_secret = var.oidc_client_secret_minio
    oidc_redirect_uri = "http://minio-console.tphan.sbx.hashidemos.io:9001/oauth_callback"
    })
  filename = "${path.module}/minio-helm.yml.tmp"
}

# minio
resource "helm_release" "minio" {
  name          = "minio"
  chart         = "minio"
  repository    = "https://charts.min.io"
  version       = var.helm_chart_version
  namespace     = "minio"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.minio-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.minio,
  ]
}