output "cluster_name" {
  description = "GKE cluster name"
  value       = module.gke.cluster_name
}

output "cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = module.gke.cluster_endpoint
  sensitive   = true
}

output "dns_name_servers" {
  description = "Cloud DNS nameservers (set these in GoDaddy)"
  value       = module.dns.name_servers
}

output "registry_url" {
  description = "Artifact Registry URL"
  value       = module.gar.registry_url
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}
