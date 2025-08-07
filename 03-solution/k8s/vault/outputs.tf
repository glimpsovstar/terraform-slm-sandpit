output "vault_hostname" {
  description = "The hostname used to access Vault"
  value       = var.use_route53_dns ? local.route53_hostname : "Use the LoadBalancer hostname shown below"
}

output "vault_url" {
  description = "The URL to access Vault"
  value       = var.use_route53_dns ? "https://${local.route53_hostname}" : "Use https://<LoadBalancer_hostname> shown below"
}

# Output the actual LoadBalancer hostname when not using Route53
data "kubernetes_service" "nginx_ingress_for_output" {
  count = var.use_route53_dns ? 0 : 1
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  
  depends_on = [kubernetes_ingress_v1.vault]
}

output "actual_loadbalancer_hostname" {
  description = "The actual AWS LoadBalancer hostname (when not using Route53)"
  value       = var.use_route53_dns ? null : try(data.kubernetes_service.nginx_ingress_for_output[0].status[0].load_balancer[0].ingress[0].hostname, "LoadBalancer not ready")
}

output "vault_ui_fqdn" {
  description = "The Vault UI FQDN"
  value       = var.use_route53_dns ? local.route53_hostname : try(data.kubernetes_service.nginx_ingress_for_output[0].status[0].load_balancer[0].ingress[0].hostname, "LoadBalancer not ready")
}

output "vault_ingress_loadbalancer_fqdn" {
  description = "NGINX ingress controller load balancer FQDN"
  value       = var.use_route53_dns ? try(data.kubernetes_service.nginx_ingress[0].status[0].load_balancer[0].ingress[0].hostname, "LoadBalancer not ready") : try(data.kubernetes_service.nginx_ingress_for_output[0].status[0].load_balancer[0].ingress[0].hostname, "LoadBalancer not ready")
}

output "vault_ca_cert_pem" {
  value       = tls_self_signed_cert.ca-cert.cert_pem
}