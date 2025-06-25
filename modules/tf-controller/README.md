# TF-Controller Module

This module integrates [TF-Controller](https://flux-iac.github.io/tofu-controller/) with your Flux GitOps setup to enable Terraform/OpenTofu infrastructure management through GitOps.

## 🎯 Features

- **GitOps Automation for Terraform**: Automatically plan and apply Terraform resources
- **Drift Detection**: Detect and fix infrastructure drift automatically
- **Multi-Tenancy Support**: Run Terraform operations in isolated runner pods
- **Manual Approval Workflow**: Separate plan and apply steps with manual approval
- **State Management**: Store Terraform state as Kubernetes secrets

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Git Repo      │    │   TF-Controller │    │   Kubernetes    │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Terraform   │ │    │ │ Plan/Apply  │ │    │ │ TF State    │ │
│ │ Configs     │ │    │ │ Runner Pods │ │    │ │ Secrets     │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │     Flux CD               │
                    │                           │
                    │ ┌───────────────────────┐ │
                    │ │ GitOps Automation     │ │
                    │ │ - Source Controller   │ │
                    │ │ - TF Controller       │ │
                    │ │ - Drift Detection     │ │
                    │ └───────────────────────┘ │
                    └───────────────────────────┘
```

## 📋 Prerequisites

1. **Flux CD** installed and configured
2. **TF-Controller** component enabled in Flux
3. **Kubernetes cluster** with appropriate RBAC permissions
4. **Git repository** with Terraform configurations

## 🚀 Usage

### Basic Configuration

```hcl
module "tf_controller" {
  source = "./modules/tf-controller"
  
  create_example_resources = true
  namespace               = "flux-system"
  github_owner            = "your-github-username"
  github_repository_name  = "your-repo-name"
  environment             = "dev"
  project_id              = "your-gcp-project-id"
}
```

### Advanced Configuration

```hcl
module "tf_controller" {
  source = "./modules/tf-controller"
  
  create_example_resources = true
  namespace               = "infrastructure"
  github_owner            = var.github_owner
  github_repository_name  = var.github_repository_name
  environment             = var.environment
  project_id              = var.GOOGLE_PROJECT
}
```

## 📁 Terraform Examples Structure

Create the following structure in your Git repository:

```
terraform-examples/
├── example/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── production/
│   ├── main.tf
│   ├── variables.tf
│   └── ...
└── staging/
    ├── main.tf
    ├── variables.tf
    └── ...
```

### Example Terraform Configuration

```hcl
# terraform-examples/example/main.tf
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

resource "google_storage_bucket" "example" {
  name     = "${var.project_id}-example-bucket"
  location = var.region
}

# terraform-examples/example/variables.tf
variable "project_id" {
  description = "Google Cloud project ID"
  type        = string
}

variable "region" {
  description = "Google Cloud region"
  type        = string
  default     = "us-central1"
}
```

## 🔧 TF-Controller CRD Examples

### GitRepository Source

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: terraform-example
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/your-username/your-repo
  ref:
    branch: main
  path: ./terraform-examples
```

### Terraform Resource

```yaml
apiVersion: infra.contrib.fluxcd.io/v1alpha1
kind: Terraform
metadata:
  name: example-infrastructure
  namespace: flux-system
spec:
  interval: 5m
  approvePlan: auto  # or "plan-xxx" for manual approval
  path: ./terraform-examples/example
  sourceRef:
    kind: GitRepository
    name: terraform-example
  vars:
    - name: project_id
      value: your-project-id
    - name: region
      value: us-central1
  disableDriftDetection: false
  runnerPodTemplate:
    spec:
      serviceAccountName: tf-controller-runner
      containers:
        - name: terraform
          image: hashicorp/terraform:1.3.9
```

## 🎛️ GitOps Models

### 1. GitOps Automation Model

```yaml
spec:
  approvePlan: auto
  disableDriftDetection: false
```

**Features:**
- Automatic plan and apply
- Drift detection and correction
- Full GitOps automation

### 2. Manual Approval Model

```yaml
spec:
  approvePlan: ""  # Empty for plan-only
  disableDriftDetection: false
```

**Features:**
- Plan generation only
- Manual approval required
- Review workflow support

### 3. Drift Detection Only

```yaml
spec:
  approvePlan: ""
  disableDriftDetection: false
  readOnly: true
```

**Features:**
- Read-only drift detection
- No automatic changes
- Monitoring only

## 🔍 Monitoring and Debugging

### Check TF-Controller Status

```bash
# Check TF-Controller pods
kubectl get pods -n flux-system -l app.kubernetes.io/name=tf-controller

# Check Terraform resources
kubectl get terraforms -A

# Check Terraform source
kubectl get gitrepository -A

# View Terraform logs
kubectl logs -n flux-system -l app.kubernetes.io/name=tf-controller
```

### Common Commands

```bash
# Suspend Terraform reconciliation
kubectl patch terraform example-infrastructure -n flux-system \
  --type='merge' -p='{"spec":{"suspend":true}}'

# Resume Terraform reconciliation
kubectl patch terraform example-infrastructure -n flux-system \
  --type='merge' -p='{"spec":{"suspend":false}}'

# Force reconciliation
kubectl annotate terraform example-infrastructure -n flux-system \
  fluxcd.io/reconcileAt="$(date +%s)"
```

## 🔐 Security Considerations

1. **Service Account Permissions**: Ensure runner pods have minimal required permissions
2. **State Encryption**: Terraform state is stored as Kubernetes secrets
3. **Network Policies**: Consider restricting runner pod network access
4. **Image Security**: Use trusted Terraform images and scan for vulnerabilities

## 📚 Additional Resources

- [TF-Controller Documentation](https://flux-iac.github.io/tofu-controller/)
- [Flux Documentation](https://fluxcd.io/docs/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

## 🐛 Troubleshooting

### Common Issues

1. **TF-Controller not starting**: Check Flux installation and component configuration
2. **Permission denied**: Verify RBAC permissions for runner pods
3. **State conflicts**: Ensure unique paths for different Terraform configurations
4. **Network issues**: Check runner pod network connectivity to external services

### Debug Commands

```bash
# Check TF-Controller events
kubectl get events -n flux-system --sort-by='.lastTimestamp'

# Check Terraform resource status
kubectl describe terraform example-infrastructure -n flux-system

# Check runner pod logs
kubectl logs -n flux-system -l job-name=terraform-example-infrastructure
``` 