# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "gke-${var.GOOGLE_PROJECT}"
  location = var.GOOGLE_REGION
  project  = var.GOOGLE_PROJECT

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  deletion_protection = false
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "gke-${var.GOOGLE_PROJECT}-node-pool"
  location   = var.GOOGLE_REGION
  project    = var.GOOGLE_PROJECT
  cluster    = google_container_cluster.primary.name
  node_count = var.GKE_NUM_NODES

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.GOOGLE_PROJECT
    }

    machine_type = "e2-medium"
    disk_size_gb = 10
    disk_type    = "pd-standard"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    tags = ["gke-node", "gke-${var.GOOGLE_PROJECT}"]
  }
} 