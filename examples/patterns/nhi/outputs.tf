output "test_app_private_fqdn" {
  value = module.vm-test-app.private_fqdn
}

output "minio_fqdn" {
  description = "minio fqdn"
  value       = "http://minio.tphan.sbx.hashidemos.io:9001"
}

output "minio_console_fqdn" {
  description = "minio consule fqdn"
  value       = "http://minio-console.tphan.sbx.hashidemos.io:9001"
}