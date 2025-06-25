variable "create_example_resources" {
  description = "Whether to create example TF-Controller resources"
  type        = bool
  default     = false
}

variable "namespace" {
  description = "Kubernetes namespace for TF-Controller resources"
  type        = string
  default     = "flux-system"
}

variable "github_owner" {
  description = "GitHub repository owner"
  type        = string
}

variable "github_repository_name" {
  description = "GitHub repository name"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
  default     = ""
} 