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
  default = 2
  description = "The number of nodes to deploy in the GKE cluster"
}

resource "google_container_cluster" "main" {
  name     = "main-cluster"
  location = var.GOOGLE_REGION
  remove_default_node_pool = true
  initial_node_count = var.GKE_NUM_NODES
  node_config {
    machine_type = "e2-micro"
  }
}