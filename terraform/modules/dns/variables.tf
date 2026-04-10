variable "project_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "environment" {
  type = string
}

variable "ingress_ip" {
  description = "External IP of the ingress load balancer"
  type        = string
  default     = ""
}
