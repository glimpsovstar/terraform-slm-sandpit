output "cluster_name" {
  description = "eks cluster name"
  value       = module.eks.cluster_name
}

output "cluster_api_endpoint" {
  description = "eks cluster api endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "eks cluster ca certificate"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_issuer_url" {
  description = "eks cluster oidc issuer url"
  value       = module.eks.cluster_oidc_issuer_url
}