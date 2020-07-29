
data "terraform_remote_state" "vpc" {
  backend = "gcs"
  config = {
    bucket = "itse-state-798274192702"
    prefix = "terraform/deploy"
  }
}

data "google_client_config" "default" {
}
