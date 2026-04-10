# Service account for GitHub Actions CI/CD
resource "google_service_account" "ci_cd" {
  account_id   = "resume-ci-cd"
  display_name = "Resume CI/CD Service Account"
  project      = var.project_id
}

# Workload Identity Federation for GitHub Actions (keyless auth)
resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  project                   = var.project_id
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  project                            = var.project_id
  display_name                       = "GitHub Actions Provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == 'ariansvi/ariansvi-resume-v2'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Allow GitHub Actions to impersonate the CI/CD service account
resource "google_service_account_iam_binding" "ci_cd_workload_identity" {
  service_account_id = google_service_account.ci_cd.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/ariansvi/ariansvi-resume-v2"
  ]
}

# CI/CD permissions — push images to Artifact Registry
resource "google_project_iam_member" "ci_cd_gar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

# CI/CD permissions — deploy to GKE
resource "google_project_iam_member" "ci_cd_gke_developer" {
  project = var.project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.ci_cd.email}"
}

# Service account for the backend app (Workload Identity)
resource "google_service_account" "backend" {
  account_id   = "resume-backend"
  display_name = "Resume Backend Service Account"
  project      = var.project_id
}

# Backend can read/write to backup bucket
resource "google_project_iam_member" "backend_storage" {
  project = var.project_id
  role    = "roles/storage.objectUser"
  member  = "serviceAccount:${google_service_account.backend.email}"
}
