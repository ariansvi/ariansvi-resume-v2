variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "domain" {
  description = "Domain name for the resume site"
  type        = string
  default     = "ariansvi.com"
}

variable "stats_username" {
  description = "Username for /stats dashboard"
  type        = string
  sensitive   = true
  default     = "arian"
}

variable "stats_password" {
  description = "Password for /stats dashboard"
  type        = string
  sensitive   = true
}

variable "test" {
  default = true
}
