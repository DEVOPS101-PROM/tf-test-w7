variable "GOOGLE_REGION" {
  type    = string
  default = "us-central1"
  description = "The region to deploy the GKE cluster"
}

variable "GOOGLE_PROJECT" {
  type    = string
  description = "The project to deploy the GKE cluster"
}  

variable "GKE_NUM_NODES" {
  type    = number
  default = 1
  description = "The number of nodes to deploy in the GKE cluster"
}

variable "enable_local_testing" {
  type    = bool
  default = false
  description = "Enable local kind cluster for testing"
}

variable "flux_namespace" {
  type    = string
  default = "flux-system"
  description = "Namespace for Flux components"
}

variable "github_owner" {
  type    = string
  description = "GitHub username or organization"
}

variable "github_repository_name" {
  type    = string
  default = "flux-gitops"
  description = "Name of the GitHub repository for Flux GitOps"
}

variable "github_token" {
  type    = string
  sensitive = true
  description = "GitHub personal access token"
}

variable "platform" {
  description = "Cluster platform: gke or kind"
  type        = string
  default     = "kind"
}

variable "enable_tf_controller_examples" {
  description = "Enable TF-Controller example resources"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}