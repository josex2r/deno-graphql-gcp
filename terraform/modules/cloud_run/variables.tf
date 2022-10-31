variable "locations" {
  description = "Available locations for Cloud Run resource"
  type = list(string)
}

variable "project_id" {
  description = "GCP project ID"
  type = string
}

variable "app_name" {
  type = string
  description = "Application name"
}

variable "image" {
  type = string
  description = "Container registry image name"
}
