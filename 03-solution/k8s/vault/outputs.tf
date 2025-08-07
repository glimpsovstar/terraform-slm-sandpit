output "vault_ui_fqdn" {
  description = "vault ingress FQDN"
  value       = "https://${local.vault_hostname}"
}

output "vault_ingress_loadbalancer_fqdn" {
  description = "NGINX ingress controller load balancer FQDN"
  value       = data.kubernetes_service.nginx_ingress_always.status.0.load_balancer.0.ingress.0.hostname
}

output "vault_ca_cert_pem" {
  value       = tls_self_signed_cert.ca-cert.cert_pem
}