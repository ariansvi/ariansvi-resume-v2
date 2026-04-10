resource "google_dns_managed_zone" "main" {
  name        = "resume-zone-${var.environment}"
  project     = var.project_id
  dns_name    = "${var.domain}."
  description = "DNS zone for ${var.domain} - managed by Terraform"

  dnssec_config {
    state = "on"
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# A record will be created after ingress gets an external IP
# For now, just the zone + NS delegation from GoDaddy
