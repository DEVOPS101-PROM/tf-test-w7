# Local Kubernetes Cluster with Flux GitOps

This Terraform module creates a complete local Kubernetes development environment with Flux GitOps, TLS certificates, GitHub repository management, and a full CI/CD pipeline.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   Flux System   │    │   Kind Cluster  │
│                 │◄──►│                 │◄──►│                 │
│ - App Code      │    │ - GitRepository │    │ - Envoy Gateway │
│ - Helm Charts   │    │ - HelmRelease   │    │ - Monitoring    │
│ - CI/CD Pipeline│    │ - Kustomization │    │ - Application   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  GitHub Actions │    │   TLS Certificates│   │   Local Access  │
│                 │    │                 │    │                 │
│ - Build Image   │    │ - Flux Identity │    │ - Port Forward  │
│ - Push Registry │    │ - Git Auth      │    │ - Ingress       │
│ - Update Chart  │    │ - Security      │    │ - Metrics       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Features

- **Local Kubernetes Cluster**: Kind-based cluster with multi-node setup
- **Flux GitOps**: Automated deployment and reconciliation
- **TLS Certificates**: Secure communication with generated certificates
- **GitHub Integration**: Automated repository creation and management
- **CI/CD Pipeline**: Complete GitHub Actions workflow
- **Envoy Gateway**: Modern ingress controller with IPVS support
- **Monitoring Stack**: Prometheus and Grafana for observability
- **Helm Charts**: Standardized application deployment
- **Auto-scaling**: HPA for automatic scaling based on metrics

## 📋 Prerequisites

- Docker Desktop or Docker Engine
- Terraform >= 1.0
- GitHub Personal Access Token
- Container Registry credentials (optional)

## 🛠️ Installation

### 1. Configure Variables

Edit `vars.tfvars` with your specific values:

```hcl
# Cluster Configuration
cluster_name = "local-cluster"
kind_num_nodes = 3
kind_node_image = "kindest/node:v1.28.0"

# GitHub Configuration
github_owner = "your-github-username"
github_token = "your-github-personal-access-token"

# Application Configuration
app_name = "kbot"
image_repository = "ghcr.io"
image_tag = "latest"
chart_version = "0.1.0"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan and Apply

```bash
terraform plan -var-file=vars.tfvars
terraform apply -var-file=vars.tfvars
```

### 4. Run Installation Script

```bash
chmod +x install-scripts.sh
./install-scripts.sh
```

## 📁 Generated Files

After running Terraform, the following files will be created:

- `kind-config.yaml` - Kind cluster configuration
- `flux-bootstrap.yaml` - Flux bootstrap manifests
- `flux-app-manifests.yaml` - Application Flux manifests
- `app-values.yaml` - Helm values for the application
- `.github/workflows/ci-cd.yaml` - GitHub Actions workflow
- `Dockerfile` - Multi-stage Docker build
- `go.mod` - Go module file
- `main.go` - Sample Go application
- `charts/` - Complete Helm chart structure

## 🔧 Configuration

### Kind Cluster

The Kind cluster is configured with:
- Multi-node setup (1 control-plane + 2 workers)
- Ingress-ready nodes
- Port mappings for HTTP/HTTPS
- Modern Kubernetes features enabled

### Flux Setup

Flux is configured with:
- GitRepository for source control
- HelmRelease for application deployment
- Kustomization for manifest management
- TLS certificates for secure communication

### Envoy Gateway

Envoy Gateway provides:
- Modern ingress controller
- IPVS load balancing
- TLS termination
- Traffic routing

### Monitoring

The monitoring stack includes:
- Prometheus for metrics collection
- Grafana for visualization
- ServiceMonitor for application metrics
- AlertManager for notifications

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test**: Run tests and security scans
2. **Build**: Build and push Docker image
3. **Update Chart**: Bump Helm chart version
4. **Deploy**: Trigger Flux reconciliation
5. **Notify**: Success/failure notifications

### Pipeline Triggers

- Push to main/develop branches
- Pull requests
- Manual workflow dispatch

## 🎯 Usage

### Accessing the Application

```bash
# Port forward to access the application
kubectl port-forward svc/kbot 8080:80

# Access via browser
curl http://localhost:8080
```

### Monitoring Access

```bash
# Prometheus
kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring

# Grafana
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

### Flux Commands

```bash
# Check Flux status
flux check

# View Git repositories
flux get sources git

# View Helm releases
flux get helmreleases

# Trigger reconciliation
flux reconcile source git kbot
flux reconcile helmrelease kbot
```

### Cluster Management

```bash
# Switch to Kind cluster context
kubectl cluster-info --context kind-local-cluster

# View all resources
kubectl get all --all-namespaces

# Delete cluster
kind delete cluster --name local-cluster
```

## 🔒 Security

- TLS certificates for Flux communication
- Secure GitHub token handling
- Container image scanning with Trivy
- Pod security contexts
- Network policies (configurable)

## 📊 Monitoring and Observability

- **Metrics**: Prometheus collects application and cluster metrics
- **Logging**: Structured JSON logging with configurable levels
- **Health Checks**: Liveness and readiness probes
- **Auto-scaling**: HPA based on CPU and memory usage

## 🧪 Testing

The setup includes:
- Unit tests for the Go application
- Security scanning with Trivy
- Helm chart validation
- Flux reconciliation verification

## 🔧 Troubleshooting

### Common Issues

1. **Docker not running**
   ```bash
   sudo systemctl start docker
   ```

2. **Kind cluster creation fails**
   ```bash
   kind delete cluster --name local-cluster
   docker system prune -f
   ```

3. **Flux bootstrap fails**
   ```bash
   flux uninstall
   kubectl delete namespace flux-system
   ```

4. **Port conflicts**
   ```bash
   # Check what's using the ports
   sudo netstat -tlnp | grep :80
   sudo netstat -tlnp | grep :443
   ```

### Debug Commands

```bash
# Check cluster status
kubectl get nodes
kubectl get pods --all-namespaces

# Check Flux logs
kubectl logs -n flux-system -l app=flux

# Check application logs
kubectl logs -l app=kbot

# Check ingress status
kubectl get ingress
kubectl describe ingress kbot
```

## 📈 Scaling

The application supports horizontal scaling:

```bash
# Scale manually
kubectl scale deployment kbot --replicas=5

# Check HPA status
kubectl get hpa
kubectl describe hpa kbot
```

## 🔄 Updates and Maintenance

### Updating the Application

1. Make changes to your application code
2. Push to GitHub
3. GitHub Actions will automatically:
   - Build new image
   - Update Helm chart
   - Deploy via Flux

### Updating Infrastructure

```bash
# Update Terraform configuration
terraform plan -var-file=vars.tfvars
terraform apply -var-file=vars.tfvars

# Update Flux
flux upgrade
```

## 📚 Additional Resources

- [Flux Documentation](https://fluxcd.io/docs/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [Envoy Gateway Documentation](https://gateway.envoyproxy.io/)
- [Helm Documentation](https://helm.sh/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review the logs and status
3. Open an issue on GitHub
4. Contact the maintainers

---

**Happy GitOps-ing! 🚀** 