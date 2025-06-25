# Flux Bootstrap using the flux provider directly
resource "flux_bootstrap_git" "this" {
  path = var.target_path
  
  # Flux configuration
  version = "v2.0.0"
  namespace = var.flux_namespace
  
  # Components
  components = [
    "source-controller",
    "kustomize-controller", 
    "helm-controller",
    "notification-controller"
  ]
  
  # Wait for Flux to be ready
  watch_all_namespaces = true
} 