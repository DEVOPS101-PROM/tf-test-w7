output "tf_controller_ready" {
  description = "Whether TF-Controller resources are ready"
  value       = var.create_example_resources ? "TF-Controller example resources created" : "TF-Controller example resources not created"
}

output "namespace" {
  description = "Namespace where TF-Controller resources are deployed"
  value       = var.namespace
}

output "service_account_name" {
  description = "Name of the ServiceAccount for TF-Controller runner pods"
  value       = var.create_example_resources ? "tf-controller-runner" : null
}

output "terraform_source_name" {
  description = "Name of the Terraform GitRepository source"
  value       = var.create_example_resources ? "terraform-example" : null
}

output "terraform_resource_name" {
  description = "Name of the example Terraform resource"
  value       = var.create_example_resources ? "example-infrastructure" : null
} 