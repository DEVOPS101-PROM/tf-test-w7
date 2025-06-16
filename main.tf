module "gke_cluster" {
  source         = "github.com/DEVOPS101-PROM/tf-google-gke-cluster"
  GOOGLE_REGION  = var.GOOGLE_REGION
  GOOGLE_PROJECT = var.GOOGLE_PROJECT
  GKE_NUM_NODES  = 2
  DISK_SIZE      = 10
  DISK_TYPE      = "pd-standard"
}