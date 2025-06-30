# Cluster Configuration
variable "cluster_name" {
  type        = string
  default     = "local-cluster"
  description = "Name of the Kind cluster"
}

variable "kind_num_nodes" {
  type        = number
  default     = 3
  description = "Number of nodes in the Kind cluster"
}

variable "kind_node_image" {
  type        = string
  default     = "kindest/node:v1.28.0"
  description = "Docker image for Kind nodes"
}

# GitHub Configuration
variable "github_owner" {
  type        = string
  description = "GitHub username or organization"
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token"
  sensitive   = true
}

# Application Configuration
variable "app_name" {
  type        = string
  default     = "kbot"
  description = "Name of the application to deploy"
}

variable "image_repository" {
  type        = string
  default     = "ghcr.io"
  description = "Container image repository"
}

variable "image_tag" {
  type        = string
  default     = "latest"
  description = "Container image tag"
}

variable "chart_version" {
  type        = string
  default     = "0.1.0"
  description = "Helm chart version"
}

# Registry Configuration
variable "registry_username" {
  type        = string
  description = "Container registry username"
  default     = ""
}

variable "registry_password" {
  type        = string
  description = "Container registry password"
  sensitive   = true
  default     = ""
}