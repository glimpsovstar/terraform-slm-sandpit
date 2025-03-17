resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.tenant_name
  }
}

# kube service account for vso-auth
resource "kubernetes_service_account" "vso-auth" {
  metadata {
    name = "vso-auth"
    namespace = var.tenant_name
  }
}

resource "local_file" "global-auth-static-secrets" {
  content = templatefile("${path.module}/templates/global-auth-static-secrets.yml.tpl", {
    vault_path  = "sample1"
    tenant_name = var.tenant_name
    })
  filename = "${path.module}/global-auth-static-secrets.yml.tmp"
}

# retreive all yaml files in the specified directory
locals {
  manifest_files = fileset("${path.module}", "*.yml.tmp")
}

# decode manifest files
locals {
  decoded_manifests = flatten([
    for file in local.manifest_files : provider::kubernetes::manifest_decode_multi(file("${path.module}/${file}"))
  ])
}

# apply each manifest
resource "kubernetes_manifest" "resources" {
  for_each = {
    for manifest in local.decoded_manifests :
    "${manifest.kind}-${lookup(manifest.metadata, "namespace", "default")}-${manifest.metadata.name}" => manifest
  }

  manifest = each.value
}