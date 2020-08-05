
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
    "prometheus"         = true
    "external_secrets"   = true
    "flux"               = true
    "flux_helm_operator" = true
  }

  flux_settings = {
    "git.url"  = "git@github.com:mozilla-it/itse-apps-prod-2-infra"
    "git.path" = "k8s"
  }

  node_pools = [
    {
      name               = "default-node-pool",
      machine_type       = "n2-standard-4"
      min_count          = "1"
      max_count          = "20"
      max_surge          = "3"
      autoscaling        = true
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 2
    }
  ]
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
  node_pools       = local.node_pools
  flux_settings    = local.flux_settings
}

