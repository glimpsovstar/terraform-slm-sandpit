resource "local_file" "vault-ent-server-helm-values" {
  content = templatefile("${path.module}/templates/sm-vault-ent-server-helm.yml.tpl", {
    version  = var.vault_version
    replicas = var.replicas
    api_addr = "https://vault.${data.aws_route53_zone.hashidemos.name}:8200"
    })
  filename = "${path.module}/sm-vault-ent-server-helm.yml.tmp"
}

# vault enterprise server
resource "helm_release" "vault-ent-server" {
  name          = "vault"
  chart         = "vault"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "vault"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.vault-ent-server-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.vault,
    kubernetes_secret.ent-license,
  ]
}