module "gke_cluster" {
  source         = "github.com/DEVOPS101-PROM/tf-google-gke-cluster"
  google_region  = var.google_region
  google_project = var.google_project
  gke_num_nodes  = 2
  disk_size      = 10
  disk_type      = "pd-standard"
}