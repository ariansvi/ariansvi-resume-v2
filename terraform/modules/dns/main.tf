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

# Cloud Run domain mapping uses Google's static anycast endpoints.
# For apex (root) domains Cloud Run accepts only A/AAAA records.
# For sub-domains (www) it uses a CNAME to ghs.googlehosted.com.
# Source: https://cloud.google.com/run/docs/mapping-custom-domains

resource "google_dns_record_set" "apex_a" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = "A"
  ttl          = 300
  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21",
  ]
}

resource "google_dns_record_set" "apex_aaaa" {
  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = "AAAA"
  ttl          = 300
  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15",
  ]
}

resource "google_dns_record_set" "www" {
  name         = "www.${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["ghs.googlehosted.com."]
}
