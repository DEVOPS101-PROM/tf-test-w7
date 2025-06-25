# TLS Module

This module generates RSA SSH keys for Flux Git authentication.

## Usage

```hcl
module "tls" {
  source = "../modules/tls"
}
```

## Outputs

| Name | Description |
|------|-------------|
| private_key | Private key for Flux SSH authentication |
| public_key | Public key for Flux SSH authentication |

## Requirements

- TLS provider must be available 