terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 3.3"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "run_api" {
  service = "run.googleapis.com"

  disable_on_destroy = true
}

# Create the Cloud Run service
module "cloud_run" {
  source = "./modules/cloud_run"
  project_id = var.project_id
  app_name = var.app_name
  locations = var.locations
  image = var.image

  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.run_api]
}

# Create a bucket with a simple entrypoint file
resource "google_storage_bucket" "static" {
  name          = "static-${var.app_name}"
  location = var.region

  force_destroy = true
  storage_class = "STANDARD"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_object" "index" {
  name         = "index.html"
  content      = file("../assets/index.html")
  content_type = "text/html"
  bucket       = google_storage_bucket.static.name
}

resource "google_storage_bucket_object" "error_404" {
  name         = "404.html"
  content      = file("../assets/404.html")
  content_type = "text/html"
  bucket       = google_storage_bucket.static.name
}

resource "google_storage_default_object_acl" "static_acl" {
  bucket = google_storage_bucket.static.name

  role_entity = ["READER:allUsers"]
}

resource "google_compute_backend_bucket" "static" {
  name        = "static-backend-${var.app_name}"
  description = "Contains static resources for example app"
  bucket_name = google_storage_bucket.static.name
  enable_cdn  = false
}

# Create Global HTTP load balancer
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = "lb-${var.app_name}"
  project = var.project_id

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl
  labels                          = { "example-label" = "cloud-run-example" }

  url_map           = google_compute_url_map.urlmap.self_link
  create_url_map    = false

  backends = {
    default = {
      description = null

      groups = [
        for neg in module.cloud_run.network_endpoint_groups:
        {
          group = neg.id
        }
      ]

      enable_cdn              = false
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = null
        oauth2_client_secret = null
      }

      log_config = {
        enable      = true
        sample_rate = 1.0
      }
    }
  }
}

resource "google_compute_url_map" "urlmap" {
  name        = "urlmap-${var.app_name}"
  default_service = google_compute_backend_bucket.static.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name = "allpaths"
    default_service = google_compute_backend_bucket.static.self_link

    path_rule {
      paths = [
        "/graphql",
        "/graphql/*",
      ]
      service = module.lb-http.backend_services.default.self_link
    }
  }
}
