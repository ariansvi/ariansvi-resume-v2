variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "environment" {
  type = string
}

variable "domain" {
  type = string
}

variable "registry_url" {
  type        = string
  description = "Artifact Registry URL for container images"
}

variable "backend_service_account_email" {
  type = string
}

variable "frontend_image_tag" {
  type    = string
  default = "latest"
}

variable "backend_image_tag" {
  type    = string
  default = "latest"
}

variable "stats_username" {
  type        = string
  sensitive   = true
  description = "Username for /stats dashboard auth"
}

variable "stats_password" {
  type        = string
  sensitive   = true
  description = "Password for /stats dashboard auth"
}
