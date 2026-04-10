resource "google_artifact_registry_repository" "main" {
  provider = google-beta

  location      = var.region
  project       = var.project_id
  repository_id = "resume"
  description   = "Docker images for resume app"
  format        = "DOCKER"

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"

    most_recent_versions {
      keep_count = 10
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}
