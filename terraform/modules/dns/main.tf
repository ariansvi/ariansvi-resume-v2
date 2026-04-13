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

# Cloud Run domain mapping asks for specific records (type + rrdata).
# We create whatever it asks for the apex and www names.

locals {
  # Group records by (fqdn, type) because Cloud DNS needs one record_set
  # per (name, type) pair with all rrdatas collected.
  apex_grouped = {
    for t in distinct([for r in var.apex_cname_data : r.type]) : t => [
      for r in var.apex_cname_data : r.rrdata if r.type == t
    ]
  }
  www_grouped = {
    for t in distinct([for r in var.www_cname_data : r.type]) : t => [
      for r in var.www_cname_data : r.rrdata if r.type == t
    ]
  }
}

resource "google_dns_record_set" "apex" {
  for_each = local.apex_grouped

  name         = "${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = each.key
  ttl          = 300
  rrdatas      = each.value
}

resource "google_dns_record_set" "www" {
  for_each = local.www_grouped

  name         = "www.${var.domain}."
  managed_zone = google_dns_managed_zone.main.name
  project      = var.project_id
  type         = each.key
  ttl          = 300
  rrdatas      = each.value
}
