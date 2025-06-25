# GitHub Repository for Flux
resource "github_repository" "flux_gitops" {
  name        = var.github_repository_name
  description = var.description
  visibility  = "private"
  
  topics = [
    "kubernetes",
    "flux",
    "gitops",
    "terraform",
    "gke"
  ]
} 