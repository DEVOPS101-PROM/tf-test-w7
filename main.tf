module "gke_cluster" {
  source         = "github.com/DEVOPS101-PROM/tf-google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = var.GKE_NUM_NODES
  node_pool_name = "main-node-pool"
  machine_type   = "e2-micro"
  delete_default_node_pool = true
}