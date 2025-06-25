# Kind Module

This module creates a local Kubernetes cluster using kind for testing purposes.

## Usage

```hcl
module "kind" {
  source = "../modules/kind"
  cluster_name = "flux-test"
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the kind cluster | `string` | `"flux-test"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_name | Name of the created kind cluster |

## Requirements

- kind must be installed on the system
- Docker must be running 