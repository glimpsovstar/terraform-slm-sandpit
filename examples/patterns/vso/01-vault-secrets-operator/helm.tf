resource "local_file" "vso-helm-values" {
  content = templatefile("${path.module}/templates/vso-helm.yml.tpl", {
    vault_address = var.vault_address
    vault_namespace = var.tenant_name
    vault_role = var.tenant_name
    })
  filename = "${path.module}/vso-helm.yml.tmp"
}

# vault secrets operator
resource "helm_release" "vso" {
  name          = "vault-secrets-operator"
  chart         = "vault-secrets-operator"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "vault"
  timeout       = "300"
  wait          = true
  values        = [
    local_file.vso-helm-values.content
  ]

  depends_on    = [
    kubernetes_namespace.vault,
  ]
}