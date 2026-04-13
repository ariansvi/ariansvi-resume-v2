resource "google_container_cluster" "main" {
  provider = google-beta

  name    = var.cluster_name
  project = var.project_id
  # Zonal cluster (single control plane) — ~$72/mo cheaper than regional.
  # Fine for a personal site; for production HA flip back to var.region.
  location = "${var.region}-a"

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

  # Maintenance window — daily 2-6 AM UTC
  maintenance_policy {
    daily_maintenance_window {
      start_time = "02:00"
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
