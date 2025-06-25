provider "google" {
  credentials = "{\"type\": \"service_account\"}"
  project     = "dummy"
  region      = "dummy"
}


# Local development cluster for testing
module "kind" {
  source = "./modules/kind"
  count  = var.platform == "kind" ? 1 : 0
  cluster_name = "flux-test"
}

# GKE Cluster
module "gke" {
  source         = "./modules/gke"
  count          = var.platform == "gke" ? 1 : 0
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
}

# TLS Keys for Flux
module "tls" {
  source = "./modules/tls"
}

# GitHub Repository for Flux
module "github" {
  source = "./modules/github"
  github_repository_name = var.github_repository_name
  github_owner           = var.github_owner
  description            = "Flux GitOps repository for ${var.GOOGLE_PROJECT}"
  
  depends_on = [module.tls]
}

module "flux" {
  source = "./modules/flux"
  cluster_name = var.platform == "gke" ? module.gke[0].cluster_name : module.kind[0].cluster_name
  github_owner = var.github_owner
  github_repository_name = var.github_repository_name
  flux_namespace = var.flux_namespace
  private_key = module.tls.private_key
  public_key  = module.tls.public_key
  config_path = "~/.kube/config"
  target_path = "clusters/kind"
  github_token = var.github_token
  
  depends_on = [module.github, module.kind]
}


provider "flux" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
  git = {
    url = "https://github.com/${var.github_owner}/${var.github_repository_name}.git"
    http = {
      username = "git"
      password = var.github_token
    }
  }
}

# TF-Controller for Terraform GitOps Automation
module "tf_controller" {
  source = "./modules/tf-controller"
  
  create_example_resources = var.enable_tf_controller_examples
  namespace               = var.flux_namespace
  github_owner            = var.github_owner
  github_repository_name  = var.github_repository_name
  environment             = var.environment
  project_id              = var.GOOGLE_PROJECT
}
