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

variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "resume-cluster"
}

variable "ingress_ip" {
  description = "External IP of the ingress load balancer (set after first deploy)"
  type        = string
  default     = ""
}
