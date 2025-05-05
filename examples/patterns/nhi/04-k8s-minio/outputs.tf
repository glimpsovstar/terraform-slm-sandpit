output "minio_console_fqdn" {
  description = "minio console load balancer fqdn"
  value       = data.kubernetes_service.minio-console.status.0.load_balancer.0.ingress.0.hostname
}