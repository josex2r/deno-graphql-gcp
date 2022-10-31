# Display the service URL
output "bucket_id" {
  value = google_storage_bucket.static.id
}

output "load_balancer_ip" {
  value = module.lb-http.external_ip
}

output "load_balancer_url" {
  value = "http://${module.lb-http.external_ip}"
}
