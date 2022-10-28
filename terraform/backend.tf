terraform {
  backend "gcs" {
    bucket  = "tf-state-graphql-api"
    prefix  = "terraform/state"
  }
}
