output "vault_ui_fqdn" {
  description = "vault load balancer fqdn"
  value       = data.kubernetes_service.vault-ui.status.0.load_balancer.0.ingress.0.hostname
}