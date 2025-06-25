output "gke_cluster_name" {
  description = "Name of the GKE cluster"
  value       = var.platform == "gke" ? module.gke[0].cluster_name : null
}

output "gke_cluster_endpoint" {
  description = "Endpoint for GKE cluster"
  value       = var.platform == "gke" ? module.gke[0].cluster_endpoint : null
  sensitive   = true
}

output "flux_namespace" {
  description = "Namespace where Flux is installed"
  value       = var.flux_namespace
}

output "github_repository_url" {
  description = "URL of the GitHub repository for Flux GitOps"
  value       = "https://github.com/${var.github_owner}/${var.github_repository_name}"
}

output "flux_ssh_public_key" {
  description = "SSH public key for Flux Git authentication"
  value       = module.tls.public_key
}

output "kind_cluster_name" {
  description = "Name of the kind cluster (if local testing is enabled)"
  value       = var.platform == "kind" ? module.kind[0].cluster_name : null
}

output "flux_bootstrap_status" {
  description = "Status of Flux bootstrap"
  value       = module.flux.flux_bootstrap_status
}

output "tf_controller_status" {
  description = "Status of TF-Controller setup"
  value       = module.tf_controller.tf_controller_ready
}

output "tf_controller_namespace" {
  description = "Namespace where TF-Controller resources are deployed"
  value       = module.tf_controller.namespace
}

output "tf_controller_service_account" {
  description = "ServiceAccount name for TF-Controller runner pods"
  value       = module.tf_controller.service_account_name
}

output "next_steps" {
  description = "Next steps to complete the setup"
  value = var.platform == "kind" ? [
    "1. Check Flux status: kubectl get pods -n ${var.flux_namespace}",
    "2. Check TF-Controller: kubectl get pods -n ${var.flux_namespace} -l app.kubernetes.io/name=tf-controller",
    "3. Deploy kbot app: make deploy-kbot",
    "4. Monitor deployment: make status",
    "5. Cleanup when done: make cleanup"
  ] : [
    "1. Configure kubectl: gcloud container clusters get-credentials ${module.gke[0].cluster_name} --region ${var.GOOGLE_REGION} --project ${var.GOOGLE_PROJECT}",
    "2. Check Flux status: kubectl get pods -n ${var.flux_namespace}",
    "3. Check TF-Controller: kubectl get pods -n ${var.flux_namespace} -l app.kubernetes.io/name=tf-controller",
    "4. Deploy kbot app: make deploy-kbot",
    "5. Monitor deployment: make status",
    "6. Access application: kubectl port-forward svc/kbot 8080:8080 -n kbot"
  ]
} 