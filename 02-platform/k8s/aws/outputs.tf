output "cluster_name" {
  description = "eks cluster name"
  value       = module.eks.cluster_name
}

output "cluster_api_endpoint" {
  description = "eks cluster api endpoint"
  value       = module.eks.cluster_endpoint
}