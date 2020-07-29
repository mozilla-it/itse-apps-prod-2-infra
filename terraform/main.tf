
provider "google-beta" {
  region = var.region
}

terraform {
  backend "gcs" {
    bucket = "itse-state-798274192702"
    prefix = "terraform/itse-apps-prod-2-infra"
  }
}

locals {
  project_id   = "mozilla-it-service-engineering"
  cluster_name = "itse-apps-prod-2"

  cluster_features = {
    "prometheus" = true
  }
}

module "gke" {
  source           = "github.com/mozilla-it/terraform-modules//gcp/gke?ref=master"
  costcenter       = "1410"
  environment      = "prod"
  project_id       = local.project_id
  name             = local.cluster_name
  region           = var.region
  regional         = true
  network          = data.terraform_remote_state.vpc.outputs.network_name
  subnetwork       = data.terraform_remote_state.vpc.outputs.subnets_names_map[var.region]
  cluster_features = local.cluster_features
}

