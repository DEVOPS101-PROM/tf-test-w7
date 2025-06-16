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