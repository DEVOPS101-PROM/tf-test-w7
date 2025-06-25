# GKE Module

This module creates a Google Kubernetes Engine (GKE) cluster with a managed node pool.

## Usage

```hcl
module "gke" {
  source         = "../modules/gke"
  GOOGLE_REGION  = "europe-west1"
  GOOGLE_PROJECT = "your-project-id"
  GKE_NUM_NODES  = 2
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| GOOGLE_REGION | The region to deploy the GKE cluster | `string` | n/a | yes |
| GOOGLE_PROJECT | The project to deploy the GKE cluster | `string` | n/a | yes |
| GKE_NUM_NODES | The number of nodes to deploy in the GKE cluster | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | Name of the GKE cluster |
| cluster_endpoint | Endpoint for GKE cluster |

## Requirements

- Google Cloud provider must be configured
- Google Cloud project must exist
- Appropriate permissions to create GKE clusters 