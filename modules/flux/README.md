# Flux Module

This module bootstraps Flux CD on a Kubernetes cluster.

## Usage

```hcl
module "flux" {
  source = "../modules/flux"
  cluster_name = "gke-my-project"
  github_owner = "your-username"
  github_repository_name = "flux-gitops"
  flux_namespace = "flux-system"
  private_key = module.tls.private_key
  public_key  = module.tls.public_key
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the Kubernetes cluster | `string` | n/a | yes |
| github_owner | GitHub username or organization | `string` | n/a | yes |
| github_repository_name | Name of the GitHub repository for Flux GitOps | `string` | n/a | yes |
| flux_namespace | Namespace for Flux components | `string` | `"flux-system"` | no |
| private_key | Private SSH key for Flux Git authentication | `string` | n/a | yes |
| public_key | Public SSH key for Flux Git authentication | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| flux_bootstrap_status | Status of Flux bootstrap |

## Requirements

- Flux provider must be configured
- Kubernetes cluster must be accessible
- GitHub repository must exist
- SSH keys must be generated 