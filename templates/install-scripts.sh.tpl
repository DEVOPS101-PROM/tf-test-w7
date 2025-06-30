#!/bin/bash

set -euo pipefail

# Colors for output
# (No variable assignments needed, use codes directly)

# Configuration
CLUSTER_NAME="${cluster_name}"
GITHUB_OWNER="${github_owner}"
FLUX_REPO="${cluster_name}-flux-bootstrap"
APP_REPO="${app_name}"

echo -e "\033[0;34m🚀 Starting local Kubernetes cluster setup with Flux and GitOps\033[0m"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install required tools
install_tools() {
    echo -e "\033[1;33m📦 Installing required tools...\033[0m"
    
    # Install Kind
    if ! command_exists kind; then
        echo "Installing Kind..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind
    fi
    
    # Install kubectl
    if ! command_exists kubectl; then
        echo "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        chmod +x kubectl
        sudo mv kubectl /usr/local/bin/
    fi
    
    # Install Helm
    if ! command_exists helm; then
        echo "Installing Helm..."
        curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    fi
    
    # Install Flux CLI
    if ! command_exists flux; then
        echo "Installing Flux CLI..."
        curl -s https://fluxcd.io/install.sh | sudo bash
    fi
    
    # Install Docker (if not running)
    if ! docker info >/dev/null 2>&1; then
        echo -e "\033[0;31m❌ Docker is not running. Please start Docker and try again.\033[0m"
        exit 1
    fi
}

# Function to create Kind cluster
create_cluster() {
    echo -e "\033[1;33m🏗️  Creating Kind cluster...\033[0m"
    
    # Create cluster with configuration
    kind create cluster --name $CLUSTER_NAME --config kind-config.yaml
    
    # Wait for cluster to be ready
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    echo -e "\033[0;32m✅ Kind cluster created successfully\033[0m"
}

# Function to install Envoy Gateway
install_envoy_gateway() {
    echo -e "\033[1;33m🌐 Installing Envoy Gateway...\033[0m"
    
    # Install Envoy Gateway
    helm repo add envoy-gateway https://envoyproxy.github.io/envoy-gateway
    helm repo update
    
    helm install envoy-gateway envoy-gateway/envoy-gateway \
        --namespace envoy-gateway-system \
        --create-namespace \
        --set gateway.envoyGateway.gateway.controllerName=gateway.envoyproxy.io/gatewayclass-controller
    
    # Wait for Envoy Gateway to be ready
    kubectl wait --for=condition=Ready pods -n envoy-gateway-system --all --timeout=300s
    
    echo -e "\033[0;32m✅ Envoy Gateway installed successfully\033[0m"
}

# Function to install monitoring stack
install_monitoring() {
    echo -e "\033[1;33m📊 Installing monitoring stack...\033[0m"
    
    # Install Prometheus Operator
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    helm install prometheus prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --create-namespace \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.podMonitorSelectorNilUsesHelmValues=false
    
    # Wait for monitoring to be ready
    kubectl wait --for=condition=Ready pods -n monitoring --all --timeout=300s
    
    echo -e "\033[0;32m✅ Monitoring stack installed successfully\033[0m"
}

# Function to bootstrap Flux
bootstrap_flux() {
    echo -e "\033[1;33m🔄 Bootstrapping Flux...\033[0m"
    
    # Bootstrap Flux
    flux bootstrap github \
        --owner=$GITHUB_OWNER \
        --repository=$FLUX_REPO \
        --branch=main \
        --path=./clusters/$CLUSTER_NAME \
        --personal \
        --private=false
    
    echo -e "\033[0;32m✅ Flux bootstrapped successfully\033[0m"
}

# Function to apply application manifests
apply_app_manifests() {
    echo -e "\033[1;33m📋 Applying application manifests...\033[0m"
    
    # Apply Flux manifests for the application
    kubectl apply -f flux-app-manifests.yaml
    
    echo -e "\033[0;32m✅ Application manifests applied successfully\033[0m"
}

# Function to verify installation
verify_installation() {
    echo -e "\033[1;33m🔍 Verifying installation...\033[0m"
    
    # Check Flux status
    echo "Checking Flux status..."
    flux check
    
    # Check cluster status
    echo "Checking cluster status..."
    kubectl get nodes
    kubectl get pods --all-namespaces
    
    # Check Envoy Gateway
    echo "Checking Envoy Gateway..."
    kubectl get pods -n envoy-gateway-system
    
    # Check monitoring
    echo "Checking monitoring stack..."
    kubectl get pods -n monitoring
    
    echo -e "\033[0;32m✅ Installation verification completed\033[0m"
}

# Function to display access information
display_access_info() {
    echo -e "\033[0;34m🎉 Setup completed successfully!\033[0m"
    echo ""
    echo -e "\033[1;33m📋 Access Information:\033[0m"
    echo "Cluster Name: $CLUSTER_NAME"
    echo "Flux Repository: https://github.com/$GITHUB_OWNER/$FLUX_REPO"
    echo "App Repository: https://github.com/$GITHUB_OWNER/$APP_REPO"
    echo ""
    echo -e "\033[1;33m🔗 Useful Commands:\033[0m"
    echo "kubectl cluster-info --context kind-$CLUSTER_NAME"
    echo "flux get sources git"
    echo "flux get helmreleases"
    echo "kubectl port-forward svc/$APP_REPO 8080:80"
    echo ""
    echo -e "\033[1;33m📊 Monitoring URLs:\033[0m"
    echo "Prometheus: kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring"
    echo "Grafana: kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
    echo ""
    echo -e "\033[0;32m🚀 Your GitOps pipeline is ready!\033[0m"
}

# Main execution
main() {
    install_tools
    create_cluster
    install_envoy_gateway
    install_monitoring
    bootstrap_flux
    apply_app_manifests
    verify_installation
    display_access_info
}

# Run main function
main "$@" 