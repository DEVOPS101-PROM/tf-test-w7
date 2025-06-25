variable "GOOGLE_REGION" {
  description = "The region to deploy the GKE cluster"
  type        = string
}

variable "GOOGLE_PROJECT" {
  description = "The project to deploy the GKE cluster"
  type        = string
}

variable "GKE_NUM_NODES" {
  description = "The number of nodes to deploy in the GKE cluster"
  type        = number
  default     = 1
} 