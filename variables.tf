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
variable "DISK_SIZE" {
  type    = number
  default = 10
  description = "The size of the disk to deploy in the GKE cluster"
}
variable "DISK_TYPE" {
  type    = string
  default = "pd-standard"
  description = "The type of the disk to deploy in the GKE cluster"
}