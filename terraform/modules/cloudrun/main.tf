# ─── Backend Cloud Run service ──────────────────────────────────────

resource "google_cloud_run_v2_service" "backend" {
  name     = "resume-backend"
  project  = var.project_id
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = var.backend_service_account_email

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = "${var.registry_url}/backend:${var.backend_image_tag}"

      ports {
        container_port = 8000
      }

      env {
        name  = "ENVIRONMENT"
        value = "production"
      }
      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "CORS_ORIGINS"
        value = "https://${var.domain},https://www.${var.domain}"
      }
      env {
        name  = "LOG_LEVEL"
        value = "INFO"
      }
      env {
        name  = "STATS_USERNAME"
        value = var.stats_username
      }
      env {
        name  = "STATS_PASSWORD"
        value = var.stats_password
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      startup_probe {
        http_get {
          path = "/api/health"
          port = 8000
        }
        initial_delay_seconds = 2
        period_seconds        = 3
        timeout_seconds       = 2
        failure_threshold     = 10
      }

      liveness_probe {
        http_get {
          path = "/api/health"
          port = 8000
        }
        period_seconds    = 30
        timeout_seconds   = 3
        failure_threshold = 3
      }
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  lifecycle {
    ignore_changes = [
      # Image is updated by CI; don't let Terraform roll it back.
      template[0].containers[0].image,
    ]
  }
}

# ─── Frontend Cloud Run service ─────────────────────────────────────

resource "google_cloud_run_v2_service" "frontend" {
  name     = "resume-frontend"
  project  = var.project_id
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }

    containers {
      image = "${var.registry_url}/frontend:${var.frontend_image_tag}"

      ports {
        container_port = 8080
      }

      env {
        name  = "BACKEND_URL"
        value = google_cloud_run_v2_service.backend.uri
      }

      resources {
        limits = {
          cpu    = "1"
          memory = "256Mi"
        }
        cpu_idle          = true
        startup_cpu_boost = true
      }

      startup_probe {
        http_get {
          path = "/health"
          port = 8080
        }
        initial_delay_seconds = 1
        period_seconds        = 3
        timeout_seconds       = 2
        failure_threshold     = 10
      }
    }
  }

  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
    ]
  }
}

# ─── Public access for both services ────────────────────────────────

resource "google_cloud_run_v2_service_iam_member" "frontend_public" {
  project  = google_cloud_run_v2_service.frontend.project
  location = google_cloud_run_v2_service.frontend.location
  name     = google_cloud_run_v2_service.frontend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_v2_service_iam_member" "backend_public" {
  project  = google_cloud_run_v2_service.backend.project
  location = google_cloud_run_v2_service.backend.location
  name     = google_cloud_run_v2_service.backend.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# ─── Domain mapping (apex + www) ────────────────────────────────────

resource "google_cloud_run_domain_mapping" "apex" {
  name     = var.domain
  project  = var.project_id
  location = var.region

  metadata {
    namespace = var.project_id
    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }

  spec {
    route_name = google_cloud_run_v2_service.frontend.name
  }
}

resource "google_cloud_run_domain_mapping" "www" {
  name     = "www.${var.domain}"
  project  = var.project_id
  location = var.region

  metadata {
    namespace = var.project_id
    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
  }

  spec {
    route_name = google_cloud_run_v2_service.frontend.name
  }
}
