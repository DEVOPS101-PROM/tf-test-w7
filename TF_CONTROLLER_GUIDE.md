# TF-Controller Integration Guide

This guide explains how to use [TF-Controller](https://flux-iac.github.io/tofu-controller/) with your existing Flux GitOps infrastructure to enable Terraform/OpenTofu infrastructure management through GitOps.

## 🎯 What is TF-Controller?

TF-Controller is a Kubernetes controller for Flux that enables GitOps automation for Terraform/OpenTofu resources. It allows you to:

- **Automate Terraform operations** through GitOps workflows
- **Detect and fix infrastructure drift** automatically
- **Manage Terraform state** as Kubernetes secrets
- **Support multiple GitOps models** (automation, manual approval, drift detection only)

## 🏗️ Architecture Overview

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

## 🚀 Quick Start

### 1. Enable TF-Controller

TF-Controller is already included in your Flux configuration. To enable it:

```bash
# Update your vars.tfvars file
enable_tf_controller_examples = true
environment = "dev"

# Apply the configuration
make apply
```

### 2. Verify TF-Controller Installation

```bash
# Check TF-Controller pods
kubectl get pods -n flux-system -l app.kubernetes.io/name=tf-controller

# Check TF-Controller CRDs
kubectl get crd | grep terraform
```

### 3. Create Your First Terraform Resource

Create a GitRepository source for your Terraform configurations:

```yaml
# flux-manifests/infrastructure/terraform-source.yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: terraform-configs
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/your-username/your-repo
  ref:
    branch: main
  path: ./terraform-examples
```

Create a Terraform resource:

```yaml
# flux-manifests/infrastructure/example-terraform.yaml
apiVersion: infra.contrib.fluxcd.io/v1alpha1
kind: Terraform
metadata:
  name: example-infrastructure
  namespace: flux-system
spec:
  interval: 5m
  approvePlan: auto
  path: ./terraform-examples/example
  sourceRef:
    kind: GitRepository
    name: terraform-configs
  vars:
    - name: project_id
      value: your-gcp-project-id
    - name: region
      value: us-central1
    - name: environment
      value: dev
  disableDriftDetection: false
  runnerPodTemplate:
    spec:
      serviceAccountName: tf-controller-runner
      containers:
        - name: terraform
          image: hashicorp/terraform:1.3.9
```

## 📁 Terraform Examples Structure

Your project includes example Terraform configurations:

```
terraform-examples/
├── example/              # Development environment
│   ├── main.tf          # Google Cloud resources
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── versions.tf      # Version constraints
└── production/          # Production environment
    ├── main.tf          # Production resources
    ├── variables.tf     # Production variables
    ├── outputs.tf       # Production outputs
    └── versions.tf      # Version constraints
```

### Example Resources

The example configurations include:

- **Google Cloud Storage Buckets** with lifecycle policies
- **Pub/Sub Topics** for messaging
- **Service Accounts** with IAM permissions
- **Cloud KMS Keys** for encryption (production)

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

**Use Case:** Development environments, non-critical infrastructure

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

**Use Case:** Production environments, critical infrastructure

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

**Use Case:** Compliance monitoring, audit trails

## 🔧 Configuration Options

### Basic Configuration

```yaml
apiVersion: infra.contrib.fluxcd.io/v1alpha1
kind: Terraform
metadata:
  name: my-infrastructure
  namespace: flux-system
spec:
  interval: 5m                    # Reconciliation interval
  approvePlan: auto               # Auto-approve plans
  path: ./terraform-examples/example  # Path to Terraform config
  sourceRef:
    kind: GitRepository
    name: terraform-configs
  vars:                           # Terraform variables
    - name: project_id
      value: my-project-id
    - name: environment
      value: dev
```

### Advanced Configuration

```yaml
apiVersion: infra.contrib.fluxcd.io/v1alpha1
kind: Terraform
metadata:
  name: production-infrastructure
  namespace: flux-system
spec:
  interval: 10m
  approvePlan: ""                 # Manual approval
  path: ./terraform-examples/production
  sourceRef:
    kind: GitRepository
    name: terraform-configs
  vars:
    - name: project_id
      value: my-project-id
    - name: environment
      value: production
  disableDriftDetection: false    # Enable drift detection
  runnerPodTemplate:              # Custom runner pod
    spec:
      serviceAccountName: tf-controller-runner
      containers:
        - name: terraform
          image: hashicorp/terraform:1.3.9
          env:
            - name: GOOGLE_APPLICATION_CREDENTIALS
              value: /var/secrets/google/key.json
          volumeMounts:
            - name: google-key
              mountPath: /var/secrets/google
              readOnly: true
      volumes:
        - name: google-key
          secret:
            secretName: google-credentials
```

## 🔍 Monitoring and Debugging

### Check TF-Controller Status

```bash
# Check TF-Controller pods
kubectl get pods -n flux-system -l app.kubernetes.io/name=tf-controller

# Check Terraform resources
kubectl get terraforms -A

# Check Terraform source
kubectl get gitrepository -A

# View TF-Controller logs
kubectl logs -n flux-system -l app.kubernetes.io/name=tf-controller
```

### Check Terraform Resources

```bash
# List all Terraform resources
kubectl get terraforms -A

# Describe a specific Terraform resource
kubectl describe terraform example-infrastructure -n flux-system

# Check Terraform state
kubectl get secrets -n flux-system -l terraform.toolkit.fluxcd.io/name=example-infrastructure
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

# Check runner pod logs
kubectl logs -n flux-system -l job-name=terraform-example-infrastructure
```

## 🔐 Security Considerations

### 1. Service Account Permissions

Ensure runner pods have minimal required permissions:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tf-controller-role
rules:
  - apiGroups: [""]
    resources: ["secrets", "configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: ["infra.contrib.fluxcd.io"]
    resources: ["terraforms", "terraforms/status"]
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
```

### 2. State Encryption

Terraform state is stored as Kubernetes secrets. Consider:

- Using encrypted storage for etcd
- Implementing network policies for runner pods
- Using Cloud KMS for additional encryption

### 3. Credential Management

For Google Cloud authentication:

```yaml
# Create a secret with Google Cloud credentials
kubectl create secret generic google-credentials \
  --from-file=key.json=/path/to/service-account-key.json \
  -n flux-system

# Reference in Terraform resource
spec:
  runnerPodTemplate:
    spec:
      volumes:
        - name: google-key
          secret:
            secretName: google-credentials
      containers:
        - name: terraform
          env:
            - name: GOOGLE_APPLICATION_CREDENTIALS
              value: /var/secrets/google/key.json
          volumeMounts:
            - name: google-key
              mountPath: /var/secrets/google
              readOnly: true
```

## 🐛 Troubleshooting

### Common Issues

1. **TF-Controller not starting**: Check Flux installation and component configuration
2. **Permission denied**: Verify RBAC permissions for runner pods
3. **State conflicts**: Ensure unique paths for different Terraform configurations
4. **Network issues**: Check runner pod network connectivity to external services

### OpenTofu Provider Issues

If you encounter provider registry errors with OpenTofu:

```bash
# Error: Failed to query available provider packages
# Could not retrieve the list of available versions for provider hashicorp/flux

# Solution 1: Use the provided script (Recommended)
make install-flux-provider
tofu init

# Solution 2: Manual installation
./scripts/install-flux-provider.sh
tofu init

# Solution 3: Alternative .terraformrc configuration
cat > .terraformrc << EOF
provider_installation {
  direct {
    exclude = ["registry.opentofu.org/hashicorp/flux"]
  }
  network_mirror {
    url = "https://registry.terraform.io/"
    include = ["registry.opentofu.org/hashicorp/flux"]
  }
}
EOF
tofu init
```

### Debug Commands

```bash
# Check TF-Controller events
kubectl get events -n flux-system --sort-by='.lastTimestamp'

# Check Terraform resource status
kubectl describe terraform example-infrastructure -n flux-system

# Check runner pod logs
kubectl logs -n flux-system -l job-name=terraform-example-infrastructure
```

## 📚 Best Practices

### 1. Resource Organization

- Use separate Terraform configurations for different environments
- Implement consistent naming conventions
- Use tags/labels for resource management

### 2. State Management

- Use unique paths for different Terraform configurations
- Implement state backup strategies
- Monitor state size and performance

### 3. Security

- Use least-privilege service accounts
- Implement network policies for runner pods
- Regularly rotate credentials

### 4. Monitoring

- Set up alerts for Terraform failures
- Monitor drift detection events
- Track resource costs and usage

## 🔄 Migration from Manual Terraform

### Step 1: Prepare Terraform Configurations

1. Organize your Terraform code in the `terraform-examples/` directory
2. Ensure all variables are properly defined
3. Test configurations locally

### Step 2: Create TF-Controller Resources

1. Create GitRepository source
2. Create Terraform resource with manual approval initially
3. Test plan generation

### Step 3: Migrate State

1. Import existing state into TF-Controller
2. Verify resource reconciliation
3. Enable automatic drift detection

### Step 4: Enable Automation

1. Switch to automatic approval for non-critical resources
2. Implement proper monitoring and alerting
3. Document procedures and runbooks

## 📖 Additional Resources

- [TF-Controller Documentation](https://flux-iac.github.io/tofu-controller/)
- [Flux Documentation](https://fluxcd.io/docs/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Google Cloud Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🆘 Getting Help

If you encounter issues:

1. Check the [TF-Controller troubleshooting guide](https://flux-iac.github.io/tofu-controller/troubleshooting/)
2. Review Flux and Terraform logs
3. Check the [Flux community](https://fluxcd.io/community/)
4. Open an issue in the [TF-Controller repository](https://github.com/flux-iac/tofu-controller) 