variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "github_owner" {
  description = "GitHub username or organization"
  type        = string
}

variable "github_repository_name" {
  description = "Name of the GitHub repository for Flux GitOps"
  type        = string
}

variable "flux_namespace" {
  description = "Namespace for Flux components"
  type        = string
  default     = "flux-system"
}

variable "private_key" {
  description = "Private SSH key for Flux Git authentication"
  type        = string
  sensitive   = true
}

variable "public_key" {
  description = "Public SSH key for Flux Git authentication"
  type        = string
}

variable "config_path" {
  description = "Path to the Kubernetes config file"
  type        = string
  default     = "~/.kube/config"
}

variable "target_path" {
  description = "Path in the Git repository where Flux will store its configuration"
  type        = string
  default     = "clusters/kind"
}

variable "github_token" {
  description = "GitHub personal access token for authentication"
  type        = string
  sensitive   = true
} 