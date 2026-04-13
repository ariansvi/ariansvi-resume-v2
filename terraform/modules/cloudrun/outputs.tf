output "frontend_url" {
  value = google_cloud_run_v2_service.frontend.uri
}

output "backend_url" {
  value = google_cloud_run_v2_service.backend.uri
}

output "apex_dns_records" {
  description = "DNS records Cloud Run wants you to create for the apex domain"
  value       = google_cloud_run_domain_mapping.apex.status[0].resource_records
}

output "www_dns_records" {
  description = "DNS records Cloud Run wants you to create for www"
  value       = google_cloud_run_domain_mapping.www.status[0].resource_records
}
