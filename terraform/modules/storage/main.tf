# Backup bucket for SQLite DB snapshots
resource "google_storage_bucket" "backups" {
  name          = "arian-svirsky-resume-backups-${var.environment}"
  project       = var.project_id
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
