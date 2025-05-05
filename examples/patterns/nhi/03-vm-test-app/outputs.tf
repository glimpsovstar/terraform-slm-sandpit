output "private_fqdn" {
  description = "private fqdn"
  value       = aws_instance.test-app.private_dns
}