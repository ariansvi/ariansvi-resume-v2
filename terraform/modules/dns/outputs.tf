output "name_servers" {
  description = "Nameservers to configure in GoDaddy"
  value       = google_dns_managed_zone.main.name_servers
}

output "zone_name" {
  value = google_dns_managed_zone.main.name
}
