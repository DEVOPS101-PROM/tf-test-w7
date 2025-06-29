output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  description = "Endpoint for GKE cluster"
  value       = google_container_cluster.primary.endpoint
  sensitive   = true
} 