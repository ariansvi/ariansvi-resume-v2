provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ─── Artifact Registry ──────────────────────────────────────────────

module "gar" {
  source = "./modules/gar"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

# ─── Firestore (analytics storage) ──────────────────────────────────

module "firestore" {
  source = "./modules/firestore"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

# ─── IAM (CI/CD + backend service account) ──────────────────────────

module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  environment = var.environment
}

# ─── Cloud Run services (frontend + backend) ────────────────────────

module "cloudrun" {
  source = "./modules/cloudrun"

  project_id                    = var.project_id
  region                        = var.region
  environment                   = var.environment
  domain                        = var.domain
  registry_url                  = module.gar.registry_url
  backend_service_account_email = module.iam.backend_service_account_email
  stats_username                = var.stats_username
  stats_password                = var.stats_password

  depends_on = [module.firestore, module.iam, module.gar]
}

# ─── Cloud DNS ───────────────────────────────────────────────────────

module "dns" {
  source = "./modules/dns"

  project_id      = var.project_id
  domain          = var.domain
  environment     = var.environment
  apex_cname_data = module.cloudrun.apex_dns_records
  www_cname_data  = module.cloudrun.www_dns_records
}

# ─── GCS (used for Terraform state and any future backups) ──────────

module "storage" {
  source = "./modules/storage"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}
