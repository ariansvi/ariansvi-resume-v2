variable "project_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "environment" {
  type = string
}

variable "apex_cname_data" {
  description = "Records Cloud Run returns for the apex domain mapping"
  type = list(object({
    name   = string
    type   = string
    rrdata = string
  }))
  default = []
}

variable "www_cname_data" {
  description = "Records Cloud Run returns for the www domain mapping"
  type = list(object({
    name   = string
    type   = string
    rrdata = string
  }))
  default = []
}
