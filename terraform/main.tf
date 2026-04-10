provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ─── VPC ─────────────────────────────────────────────────────────────

module "vpc" {
  source = "./modules/vpc"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

# ─── GKE Autopilot ──────────────────────────────────────────────────

module "gke" {
  source = "./modules/gke"

  project_id   = var.project_id
  region       = var.region
  environment  = var.environment
  cluster_name = var.cluster_name
  network      = module.vpc.network_name
  subnetwork   = module.vpc.subnet_name

  depends_on = [module.vpc]
}

# ─── Cloud DNS ───────────────────────────────────────────────────────

module "dns" {
  source = "./modules/dns"

  project_id  = var.project_id
  domain      = var.domain
  environment = var.environment
  ingress_ip  = var.ingress_ip
}

# ─── Artifact Registry ──────────────────────────────────────────────

module "gar" {
  source = "./modules/gar"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

# ─── GCS (Terraform state bucket bootstrapped separately) ────────────

module "storage" {
  source = "./modules/storage"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
}

# ─── IAM ─────────────────────────────────────────────────────────────

module "iam" {
  source = "./modules/iam"

  project_id  = var.project_id
  environment = var.environment
}
