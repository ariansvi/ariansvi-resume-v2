resource "google_container_cluster" "main" {
  provider = google-beta

  name     = var.cluster_name
  project  = var.project_id
  location = var.region

  # Autopilot mode — GKE manages nodes, you pay per pod
  enable_autopilot = true

  network    = var.network
  subnetwork = var.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  # Release channel for auto-upgrades
  release_channel {
    channel = "REGULAR"
  }

  # Workload Identity for secure pod-to-GCP auth
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Maintenance window — Sunday 2-6 AM UTC
  maintenance_policy {
    recurring_window {
      start_time = "2024-01-01T02:00:00Z"
      end_time   = "2024-01-01T06:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=SU"
    }
  }

  # Logging and monitoring
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  resource_labels = {
    environment = var.environment
    project     = "resume"
    managed_by  = "terraform"
  }

  deletion_protection = false
}
