output "repo_url" {
  description = "URL of the created GitHub repository"
  value       = github_repository.flux_gitops.html_url
} 