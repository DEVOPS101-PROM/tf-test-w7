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

# Production Storage Bucket with enhanced security
resource "google_storage_bucket" "production" {
  name     = "${var.project_id}-${var.environment}-storage"
  location = var.region
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  labels = {
    environment = var.environment
    managed_by  = "tf-controller"
    tier        = "production"
  }
}

# Production Pub/Sub Topic with Dead Letter Queue
resource "google_pubsub_topic" "production" {
  name = "${var.environment}-production-topic"
  
  labels = {
    environment = var.environment
    managed_by  = "tf-controller"
    tier        = "production"
  }
}

# Dead Letter Queue Topic
resource "google_pubsub_topic" "dead_letter" {
  name = "${var.environment}-dead-letter-topic"
  
  labels = {
    environment = var.environment
    managed_by  = "tf-controller"
    purpose     = "dead-letter-queue"
  }
}

# Production Service Account with minimal permissions
resource "google_service_account" "production" {
  account_id   = "${var.environment}-production-sa"
  display_name = "Production Service Account"
  description  = "Service account for production workloads managed by TF-Controller"
}

# IAM Policy for production service account
resource "google_project_iam_member" "storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.production.email}"
}

resource "google_project_iam_member" "pubsub_publisher" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.production.email}"
}

# Cloud KMS Key for encryption (if needed)
resource "google_kms_key_ring" "production" {
  name     = "${var.environment}-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "production" {
  name     = "${var.environment}-key"
  key_ring = google_kms_key_ring.production.id
  
  lifecycle {
    prevent_destroy = true
  }
} 