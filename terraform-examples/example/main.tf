terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Example: Google Cloud Storage Bucket
resource "google_storage_bucket" "example" {
  name     = "${var.project_id}-${var.environment}-example-bucket"
  location = var.region
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
  
  labels = {
    environment = var.environment
    managed_by  = "tf-controller"
  }
}

# Example: Google Cloud Pub/Sub Topic
resource "google_pubsub_topic" "example" {
  name = "${var.environment}-example-topic"
  
  labels = {
    environment = var.environment
    managed_by  = "tf-controller"
  }
}

# Example: Google Cloud IAM Service Account
resource "google_service_account" "example" {
  account_id   = "${var.environment}-example-sa"
  display_name = "Example Service Account for ${var.environment}"
  description  = "Service account managed by TF-Controller"
}

# Example: Google Cloud IAM Policy Binding
resource "google_project_iam_member" "example" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.example.email}"
} 