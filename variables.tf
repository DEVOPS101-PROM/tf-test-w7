variable "google_region" {
  type    = string
  default = "us-central1"
  description = "The region to deploy the GKE cluster"
}

variable "google_project" {
  type    = string
  description = "The project to deploy the GKE cluster"
}  
variable "gke_num_nodes" {
  type    = number
  default = 2
  description = "The number of nodes to deploy in the GKE cluster"
}
variable "disk_size" {
  type    = number
  default = 10
  description = "The size of the disk to deploy in the GKE cluster"
}
variable "disk_type" {
  type    = string
  default = "pd-standard"
  description = "The type of the disk to deploy in the GKE cluster"
}