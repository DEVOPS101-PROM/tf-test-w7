# TF-Controller Module for Terraform GitOps Automation
# This module provides examples and configurations for using TF-Controller with Flux

# Example: Terraform source configuration
resource "kubernetes_manifest" "terraform_source" {
  count = var.create_example_resources ? 1 : 0
  
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind       = "GitRepository"
    metadata = {
      name      = "terraform-example"
      namespace = var.namespace
    }
    spec = {
      interval = "1m"
      url      = "https://github.com/${var.github_owner}/${var.github_repository_name}"
      ref = {
        branch = "main"
      }
      path = "./terraform-examples"
    }
  }
}

# Example: Terraform configuration for infrastructure
resource "kubernetes_manifest" "terraform_example" {
  count = var.create_example_resources ? 1 : 0
  
  manifest = {
    apiVersion = "infra.contrib.fluxcd.io/v1alpha1"
    kind       = "Terraform"
    metadata = {
      name      = "example-infrastructure"
      namespace = var.namespace
    }
    spec = {
      interval = "5m"
      approvePlan = "auto"
      path       = "./terraform-examples/example"
      sourceRef = {
        kind = "GitRepository"
        name = "terraform-example"
      }
      vars = [
        {
          name  = "environment"
          value = var.environment
        },
        {
          name  = "project_id"
          value = var.project_id
        }
      ]
      # Enable drift detection
      disableDriftDetection = false
      # Runner pod configuration for multi-tenancy
      runnerPodTemplate = {
        spec = {
          serviceAccountName = "tf-controller-runner"
          containers = [
            {
              name  = "terraform"
              image = "hashicorp/terraform:1.3.9"
            }
          ]
        }
      }
    }
  }
}

# Service Account for TF-Controller runner pods
resource "kubernetes_service_account" "tf_controller_runner" {
  count = var.create_example_resources ? 1 : 0
  
  metadata {
    name      = "tf-controller-runner"
    namespace = var.namespace
  }
}

# Cluster Role for TF-Controller
resource "kubernetes_cluster_role" "tf_controller_role" {
  count = var.create_example_resources ? 1 : 0
  
  metadata {
    name = "tf-controller-role"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "configmaps"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }

  rule {
    api_groups = ["infra.contrib.fluxcd.io"]
    resources  = ["terraforms", "terraforms/status"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }
}

# Cluster Role Binding
resource "kubernetes_cluster_role_binding" "tf_controller_role_binding" {
  count = var.create_example_resources ? 1 : 0
  
  metadata {
    name = "tf-controller-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "tf-controller-role"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tf-controller-runner"
    namespace = var.namespace
  }
} 