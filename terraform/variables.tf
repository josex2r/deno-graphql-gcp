variable "project_id" {}

variable "region" {}

variable "locations" {
  default = ["europe-southwest1", "europe-central2"]
}

variable "app_name" {}

variable "image" {}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type = bool
  default = false
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type = string
  default = ""
}
