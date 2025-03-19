# applied manifests
output "applied_manifests" {
  value = { for k, v in kubernetes_manifest.resources : k => v.object }
}