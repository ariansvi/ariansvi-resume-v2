# ─── Bootstrap: GCP Project + State Bucket ───────────────────────────
# This is the ONE thing you run manually before everything else.
# It creates the GCP project, enables APIs, and creates the Terraform
# state bucket that all other Terraform configs use.
#
# Usage:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply -var billing_account=XXXXXX-XXXXXX-XXXXXX
#
# After this, all other Terraform runs are fully automated.
# ─────────────────────────────────────────────────────────────────────

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # Bootstrap uses LOCAL state (chicken-and-egg: can't use GCS before it exists)
  # After running this, the state file stays local. Treat it as sacred.
  # Optionally migrate it to GCS after the bucket is created.
}

provider "google" {
  # No project set — we're creating it
}

# ─── Variables ───────────────────────────────────────────────────────

variable "project_id" {
  description = "GCP project ID to create"
  type        = string
  default     = "ariansvi-resume"
}

variable "project_name" {
  description = "Human-readable project name"
  type        = string
  default     = "Arian Svirsky Resume"
}

variable "billing_account" {
  description = "GCP billing account ID (format: XXXXXX-XXXXXX-XXXXXX)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Default GCP region"
  type        = string
  default     = "us-central1"
}

variable "org_id" {
  description = "GCP organization ID (leave empty for personal accounts)"
  type        = string
  default     = ""
}

variable "folder_id" {
  description = "GCP folder ID (leave empty for no folder)"
  type        = string
  default     = ""
}

# ─── GCP Project ─────────────────────────────────────────────────────

resource "google_project" "resume" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account

  # For personal accounts (no org), omit org_id and folder_id
  org_id    = var.org_id != "" ? var.org_id : null
  folder_id = var.folder_id != "" ? var.folder_id : null

  labels = {
    purpose    = "resume"
    managed_by = "terraform"
  }

  deletion_policy = "DELETE"
}

# ─── Enable Required APIs ────────────────────────────────────────────

locals {
  apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each = toset(local.apis)

  project = google_project.resume.project_id
  service = each.value

  disable_dependent_services = false
  disable_on_destroy         = false
}

# ─── Terraform State Bucket ──────────────────────────────────────────

resource "google_storage_bucket" "tfstate" {
  name     = "${var.project_id}-tfstate"
  project  = google_project.resume.project_id
  location = var.region

  uniform_bucket_level_access = true
  force_destroy               = false

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 5
    }
    action {
      type = "Delete"
    }
  }

  labels = {
    purpose    = "terraform-state"
    managed_by = "terraform-bootstrap"
  }

  depends_on = [google_project_service.apis["storage.googleapis.com"]]
}

# ─── Outputs ─────────────────────────────────────────────────────────

output "project_id" {
  description = "Created GCP project ID"
  value       = google_project.resume.project_id
}

output "project_number" {
  description = "GCP project number (needed for GitHub Actions OIDC)"
  value       = google_project.resume.number
}

output "tfstate_bucket" {
  description = "Terraform state bucket name"
  value       = google_storage_bucket.tfstate.name
}

output "next_steps" {
  description = "What to do after bootstrap"
  value       = <<-EOT

    Bootstrap complete! Next steps:

    1. Note your project number: ${google_project.resume.number}
       (You'll need this as a GitHub Actions secret: GCP_PROJECT_NUMBER)

    2. Authenticate gcloud:
       gcloud auth application-default login
       gcloud config set project ${google_project.resume.project_id}

    3. Run the main Terraform:
       cd ../
       terraform init
       terraform apply -var-file=environments/prod/terraform.tfvars

    4. Or use the full bootstrap script:
       bash scripts/bootstrap.sh --skip-terraform-bootstrap

  EOT
}
