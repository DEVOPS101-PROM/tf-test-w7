variable "github_repository_name" {
  description = "Name of the GitHub repository for Flux GitOps"
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "description" {
  description = "Description of the GitHub repository"
  type        = string
  default     = "Flux GitOps repository"
} 