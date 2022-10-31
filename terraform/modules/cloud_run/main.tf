# Create the Cloud Run service
resource "google_cloud_run_service" "run_service" {
  for_each = toset(var.locations)

  name = "service-${var.app_name}-${each.key}"
  project = var.project_id
  location = each.key

  template {
    spec {
      containers {
        image = var.image
      }
    }
  }

  traffic {
    percent = 100
    latest_revision = true
  }
}

# Allow unauthenticated users to invoke the service
data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "run_all_users" {
  for_each = toset(var.locations)

  service  = google_cloud_run_service.run_service[each.key].name
  location = google_cloud_run_service.run_service[each.key].location
  project = google_cloud_run_service.run_service[each.key].project
  policy_data = data.google_iam_policy.noauth.policy_data
}

# Create a network endpoint group to wrap all available regions
resource "google_compute_region_network_endpoint_group" "neg" {
  for_each = toset(var.locations)

  name                  = "neg-${var.app_name}-${each.key}"
  network_endpoint_type = "SERVERLESS"
  region                = google_cloud_run_service.run_service[each.key].location

  cloud_run {
    service = google_cloud_run_service.run_service[each.key].name
  }
}
