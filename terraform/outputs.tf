output "frontend_url" {
  description = "Cloud Run URL for the frontend (use this to test before DNS is live)"
  value       = module.cloudrun.frontend_url
}

output "backend_url" {
  description = "Cloud Run URL for the backend API"
  value       = module.cloudrun.backend_url
}

output "apex_dns_records" {
  description = "DNS records required for the apex domain mapping"
  value       = module.cloudrun.apex_dns_records
}

output "www_dns_records" {
  description = "DNS records required for the www domain mapping"
  value       = module.cloudrun.www_dns_records
}

output "dns_name_servers" {
  description = "Cloud DNS nameservers (set these in GoDaddy)"
  value       = module.dns.name_servers
}

output "registry_url" {
  description = "Artifact Registry URL"
  value       = module.gar.registry_url
}
