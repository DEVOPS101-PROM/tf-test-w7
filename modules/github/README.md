# GitHub Module

This module creates a GitHub repository for Flux GitOps.

## Usage

```hcl
module "github" {
  source = "../modules/github"
  github_repository_name = "flux-gitops"
  github_owner = "your-username"
  description = "Flux GitOps repository for my project"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| github_repository_name | Name of the GitHub repository for Flux GitOps | `string` | n/a | yes |
| github_owner | GitHub username or organization | `string` | n/a | yes |
| description | Description of the GitHub repository | `string` | `"Flux GitOps repository"` | no |

## Outputs

| Name | Description |
|------|-------------|
| repo_url | URL of the created GitHub repository |

## Requirements

- GitHub provider must be configured
- GitHub token with appropriate permissions 