output "ci_cd_service_account_email" {
  value = google_service_account.ci_cd.email
}

output "backend_service_account_email" {
  value = google_service_account.backend.email
}

output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}
