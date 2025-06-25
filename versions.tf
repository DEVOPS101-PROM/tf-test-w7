terraform {
 
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    flux = {
      source = "fluxcd/flux"
      version = "1.6.2"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}

# Module versions for reproducibility
# locals {
#   module_versions = {
#     gke_cluster     = "v1.0.0"
#     kind_cluster    = "v0.1.0"
#     tls_keys        = "v0.1.0"
#     github_repo     = "v0.1.0"
#     flux_bootstrap  = "v0.1.0"
#   }
# } 