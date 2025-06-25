terraform {
 
  required_providers {
 
    flux = {
      source = "fluxcd/flux"
      version = "1.6.2"
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