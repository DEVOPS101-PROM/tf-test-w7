output "storage_bucket_name" {
  description = "Name of the created Google Cloud Storage bucket"
  value       = google_storage_bucket.example.name
}

output "storage_bucket_url" {
  description = "URL of the created Google Cloud Storage bucket"
  value       = google_storage_bucket.example.url
}

output "pubsub_topic_name" {
  description = "Name of the created Google Cloud Pub/Sub topic"
  value       = google_pubsub_topic.example.name
}

output "service_account_email" {
  description = "Email of the created Google Cloud Service Account"
  value       = google_service_account.example.email
}

output "service_account_name" {
  description = "Name of the created Google Cloud Service Account"
  value       = google_service_account.example.name
} 