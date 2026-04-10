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

# A records pointing to the ingress load balancer IP
resource "google_dns_record_set" "root" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = "A"
  ttl          = 300
  rrdatas      = [var.ingress_ip]

  count = var.ingress_ip != "" ? 1 : 0
}

resource "google_dns_record_set" "www" {
  name         = "www.${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["${var.domain}."]

  count = var.ingress_ip != "" ? 1 : 0
}
