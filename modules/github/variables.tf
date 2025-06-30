variable "github_repository_name" {
  description = "Name of the GitHub repository for Flux GitOps"
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_token" {
  description = "GitHub personal access token for authentication"
  type        = string
  sensitive   = true
}

variable "description" {
  description = "Description of the GitHub repository"
  type        = string
  default     = "Flux GitOps repository"
} 