terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

# Generate TLS keys for Flux repositories
module "tls_keys" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  
  algorithm = "ECDSA"
  ecdsa_curve = "P256"
}

# Generate separate TLS keys for app repository
module "app_tls_keys" {
  source = "github.com/den-vasyliev/tf-hashicorp-tls-keys"
  
  algorithm = "ECDSA"
  ecdsa_curve = "P256"
}

# Create GitHub repository for Flux bootstrap
module "flux_repository" {
  source = "github.com/den-vasyliev/tf-github-repository"
  
  github_owner = var.github_owner
  github_token = var.github_token
  repository_name = "${var.cluster_name}-flux-bootstrap"
  repository_visibility = "private"
  branch = "main"
  public_key_openssh = module.tls_keys.public_key_openssh
  public_key_openssh_title = "flux-${var.cluster_name}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}

# Create GitHub repository for the application
module "app_repository" {
  source = "github.com/den-vasyliev/tf-github-repository"
  
  github_owner = var.github_owner
  github_token = var.github_token
  repository_name = var.app_name
  repository_visibility = "private"
  branch = "main"
  public_key_openssh = module.app_tls_keys.public_key_openssh
  public_key_openssh_title = "flux-${var.app_name}-${formatdate("YYYYMMDD-HHmmss", timestamp())}"
}

# Local Kind cluster configuration
resource "local_file" "kind_config" {
  filename = "${path.module}/kind-config.yaml"
  content = templatefile("${path.module}/templates/kind-config.yaml.tpl", {
    cluster_name = var.cluster_name
    node_image   = var.kind_node_image
    num_nodes    = var.kind_num_nodes
  })
}

# Flux bootstrap configuration
resource "local_file" "flux_bootstrap_config" {
  filename = "${path.module}/flux-bootstrap.yaml"
  content = templatefile("${path.module}/templates/flux-bootstrap.yaml.tpl", {
    cluster_name     = var.cluster_name
    github_repo      = "${var.cluster_name}-flux-bootstrap"
    github_owner     = var.github_owner
    github_token     = var.github_token
    private_key_pem  = module.tls_keys.private_key_pem
    public_key_pem   = module.tls_keys.public_key_openssh
  })
}

# Application Helm chart values
resource "local_file" "app_helm_values" {
  filename = "${path.module}/app-values.yaml"
  content = templatefile("${path.module}/templates/app-values.yaml.tpl", {
    app_name = var.app_name
    image_repository = var.image_repository
    image_tag = var.image_tag
  })
}

# Flux GitRepository and HelmRelease manifests
resource "local_file" "flux_app_manifests" {
  filename = "${path.module}/flux-app-manifests.yaml"
  content = templatefile("${path.module}/templates/flux-app-manifests.yaml.tpl", {
    app_name = var.app_name
    github_owner = var.github_owner
    chart_name = var.app_name
    chart_version = var.chart_version
    image_repository = var.image_repository
    image_tag = var.image_tag
  })
}

# Installation script
resource "local_file" "install_script" {
  filename = "${path.module}/install-scripts.sh"
  content = templatefile("${path.module}/templates/install-scripts.sh.tpl", {
    cluster_name = var.cluster_name
    github_owner = var.github_owner
    app_name = var.app_name
  })
  file_permission = "0755"
}

# Cleanup script
resource "local_file" "cleanup_script" {
  filename = "${path.module}/cleanup.sh"
  content = templatefile("${path.module}/templates/cleanup.sh.tpl", {
    cluster_name = var.cluster_name
    github_owner = var.github_owner
    app_name = var.app_name
  })
  file_permission = "0755"
}

# Application source code files
resource "local_file" "dockerfile" {
  filename = "${path.module}/Dockerfile"
  content = templatefile("${path.module}/templates/Dockerfile.tpl", {
    app_name = var.app_name
  })
}

resource "local_file" "go_mod" {
  filename = "${path.module}/go.mod"
  content = templatefile("${path.module}/templates/go.mod.tpl", {
    github_owner = var.github_owner
    app_name = var.app_name
  })
}

resource "local_file" "main_go" {
  filename = "${path.module}/main.go"
  content = templatefile("${path.module}/templates/main.go.tpl", {
    app_name = var.app_name
  })
}

# GitHub Actions workflow for CI/CD
resource "local_file" "github_actions_workflow" {
  filename = "${path.module}/.github/workflows/ci-cd.yaml"
  content = templatefile("${path.module}/templates/github-actions-workflow.yaml.tpl", {
    app_name = var.app_name
    image_repository = var.image_repository
    registry_username = var.registry_username
    registry_password = var.registry_password
  })
  directory_permission = "0755"
}

# Helm chart files
resource "local_file" "chart_yaml" {
  filename = "${path.module}/charts/Chart.yaml"
  content = templatefile("${path.module}/templates/charts/Chart.yaml.tpl", {
    app_name = var.app_name
    chart_version = var.chart_version
    image_tag = var.image_tag
    github_owner = var.github_owner
  })
}

resource "local_file" "chart_values" {
  filename = "${path.module}/charts/values.yaml"
  content = templatefile("${path.module}/templates/charts/values.yaml.tpl", {
    app_name = var.app_name
    image_repository = var.image_repository
    image_tag = var.image_tag
  })
}

resource "local_file" "chart_deployment" {
  filename = "${path.module}/charts/templates/deployment.yaml"
  content = templatefile("${path.module}/templates/charts/templates/deployment.yaml.tpl", {
    app_name = var.app_name
  })
}

resource "local_file" "chart_service" {
  filename = "${path.module}/charts/templates/service.yaml"
  content = templatefile("${path.module}/templates/charts/templates/service.yaml.tpl", {
    app_name = var.app_name
  })
}

resource "local_file" "chart_ingress" {
  filename = "${path.module}/charts/templates/ingress.yaml"
  content = templatefile("${path.module}/templates/charts/templates/ingress.yaml.tpl", {
    app_name = var.app_name
  })
}

resource "local_file" "chart_hpa" {
  filename = "${path.module}/charts/templates/hpa.yaml"
  content = templatefile("${path.module}/templates/charts/templates/hpa.yaml.tpl", {
    app_name = var.app_name
  })
}

resource "local_file" "chart_helpers" {
  filename = "${path.module}/charts/templates/_helpers.tpl"
  content = templatefile("${path.module}/templates/charts/templates/_helpers.tpl", {
    app_name = var.app_name
  })
}

# Outputs
output "cluster_name" {
  description = "Name of the Kind cluster"
  value       = var.cluster_name
}

output "flux_repository_url" {
  description = "URL of the Flux bootstrap repository"
  value       = "https://github.com/${var.github_owner}/${var.cluster_name}-flux-bootstrap"
}

output "app_repository_url" {
  description = "URL of the application repository"
  value       = "https://github.com/${var.github_owner}/${var.app_name}"
}

output "tls_private_key" {
  description = "TLS private key for Flux"
  value       = module.tls_keys.private_key_pem
  sensitive   = true
}

output "tls_public_key" {
  description = "TLS public key for Flux"
  value       = module.tls_keys.public_key_openssh
  sensitive   = true
}

output "setup_instructions" {
  description = "Instructions for setting up the cluster"
  value = <<-EOT
    # Setup Instructions for ${var.cluster_name}
    
    1. Create Kind cluster:
       kind create cluster --name ${var.cluster_name} --config kind-config.yaml
    
    2. Install Flux CLI:
       curl -s https://fluxcd.io/install.sh | sudo bash
    
    3. Bootstrap Flux:
       flux bootstrap github --owner=${var.github_owner} --repository=${var.cluster_name}-flux-bootstrap --branch=main --path=./clusters/${var.cluster_name} --personal
    
    4. Apply application manifests:
       kubectl apply -f flux-app-manifests.yaml
    
    5. Verify Flux installation:
       flux check
    
    6. Monitor GitOps reconciliation:
       flux get sources git
       flux get helmreleases
    
    # Access your application:
    kubectl port-forward svc/${var.app_name} 8080:80
    
    # Or run the automated installation script:
    ./install-scripts.sh
  EOT
}