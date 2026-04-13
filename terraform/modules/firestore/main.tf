# Firestore in Native mode. Only one database per project is free-tier
# eligible and it must be named "(default)".
resource "google_firestore_database" "default" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  # Allow destroy for dev; lock down in prod if you actually care.
  deletion_policy = "DELETE"
}
