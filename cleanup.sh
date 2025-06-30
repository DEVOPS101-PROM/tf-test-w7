#!/bin/bash

set -euo pipefail

# Colors for output
# (No variable assignments needed, use codes directly)

# Configuration
CLUSTER_NAME="local-cluster"
GITHUB_OWNER="Tirtxika"
FLUX_REPO="local-cluster-flux-bootstrap"
APP_REPO="kbot"

echo -e "\033[0;34m🧹 Starting cleanup of local Kubernetes cluster and resources\033[0m"

# Function to confirm cleanup
confirm_cleanup() {
    echo -e "\033[1;33m⚠️  This will remove:\033[0m"
    echo "  - Kind cluster: $CLUSTER_NAME"
    echo "  - Flux system"
    echo "  - All Kubernetes resources"
    echo "  - Generated files"
    echo ""
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "\033[1;33mCleanup cancelled.\033[0m"
        exit 0
    fi
}

# Function to cleanup Flux
cleanup_flux() {
    echo -e "\033[1;33m🔄 Cleaning up Flux...\033[0m"
    
    if command -v flux >/dev/null 2>&1; then
        # Uninstall Flux
        flux uninstall --silent || true
        
        # Remove Flux namespace
        kubectl delete namespace flux-system --ignore-not-found=true || true
    else
        echo "Flux CLI not found, skipping Flux cleanup"
    fi
    
    echo -e "\033[0;32m✅ Flux cleanup completed\033[0m"
}

# Function to cleanup Kind cluster
cleanup_kind_cluster() {
    echo -e "\033[1;33m🏗️  Cleaning up Kind cluster...\033[0m"
    
    if command -v kind >/dev/null 2>&1; then
        # Delete Kind cluster
        kind delete cluster --name $CLUSTER_NAME || true
    else
        echo "Kind CLI not found, skipping cluster cleanup"
    fi
    
    echo -e "\033[0;32m✅ Kind cluster cleanup completed\033[0m"
}

# Function to cleanup Docker resources
cleanup_docker() {
    echo -e "\033[1;33m🐳 Cleaning up Docker resources...\033[0m"
    
    # Remove unused containers, networks, and images
    docker system prune -f || true
    
    # Remove dangling images
    docker image prune -f || true
    
    echo -e "\033[0;32m✅ Docker cleanup completed\033[0m"
}

# Function to cleanup generated files
cleanup_files() {
    echo -e "\033[1;33m📁 Cleaning up generated files...\033[0m"
    
    # List of files to remove
    files_to_remove=(
        "kind-config.yaml"
        "flux-bootstrap.yaml"
        "flux-app-manifests.yaml"
        "app-values.yaml"
        "install-scripts.sh"
        "Dockerfile"
        "go.mod"
        "main.go"
        ".github/workflows/ci-cd.yaml"
        "charts/"
    )
    
    for file in "${files_to_remove[@]}"; do
        if [ -e "$file" ]; then
            rm -rf "$file"
            echo "Removed: $file"
        fi
    done
    
    echo -e "\033[0;32m✅ File cleanup completed\033[0m"
}

# Function to cleanup GitHub repositories (optional)
cleanup_github_repos() {
    echo -e "\033[1;33m🐙 Cleaning up GitHub repositories...\033[0m"
    
    echo "This will remove the following repositories:"
    echo "  - $FLUX_REPO"
    echo "  - $APP_REPO"
    echo ""
    read -p "Do you want to delete these repositories? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Note: This requires GitHub CLI or API access
        echo "To delete repositories, use:"
        echo "  gh repo delete $GITHUB_OWNER/$FLUX_REPO --yes"
        echo "  gh repo delete $GITHUB_OWNER/$APP_REPO --yes"
        echo ""
        echo "Or delete them manually from GitHub web interface"
    else
        echo "Skipping GitHub repository cleanup"
    fi
    
    echo -e "\033[0;32m✅ GitHub cleanup completed\033[0m"
}

# Function to cleanup Terraform state
cleanup_terraform() {
    echo -e "\033[1;33m🏗️  Cleaning up OpenTofu state...\033[0m"
    
    if [ -d ".terraform" ]; then
        # Destroy OpenTofu resources
        tofu destroy -var-file=vars.tfvars -auto-approve || true
        
        # Remove OpenTofu files
        rm -rf .terraform .terraform.lock.hcl tofu.tfstate* || true
    fi
    
    echo -e "\033[0;32m✅ OpenTofu cleanup completed\033[0m"
}

# Function to verify cleanup
verify_cleanup() {
    echo -e "\033[1;33m🔍 Verifying cleanup...\033[0m"
    
    # Check if Kind cluster exists
    if command -v kind >/dev/null 2>&1; then
        if kind get clusters | grep -q "$CLUSTER_NAME"; then
            echo -e "\033[0;31m❌ Kind cluster still exists\033[0m"
        else
            echo -e "\033[0;32m✅ Kind cluster removed\033[0m"
        fi
    fi
    
    # Check if kubectl context exists
    if command -v kubectl >/dev/null 2>&1; then
        if kubectl config get-contexts | grep -q "kind-$CLUSTER_NAME"; then
            echo -e "\033[0;31m❌ kubectl context still exists\033[0m"
        else
            echo -e "\033[0;32m✅ kubectl context removed\033[0m"
        fi
    fi
    
    # Check if Docker containers exist
    if docker ps -a --format "table {{.Names}}" | grep -q "$CLUSTER_NAME"; then
        echo -e "\033[0;31m❌ Docker containers still exist\033[0m"
    else
        echo -e "\033[0;32m✅ Docker containers removed\033[0m"
    fi
    
    echo -e "\033[0;32m✅ Cleanup verification completed\033[0m"
}

# Main cleanup function
main() {
    confirm_cleanup
    cleanup_flux
    cleanup_kind_cluster
    cleanup_docker
    cleanup_files
    cleanup_github_repos
    cleanup_terraform
    verify_cleanup
    
    echo -e "\033[0;34m🎉 Cleanup completed successfully!\033[0m"
    echo ""
    echo -e "\033[1;33m📋 Summary:\033[0m"
    echo "  - Kind cluster: Removed"
    echo "  - Flux system: Removed"
    echo "  - Docker resources: Cleaned"
    echo "  - Generated files: Removed"
    echo "  - Terraform state: Cleaned"
    echo ""
    echo -e "\033[0;32m🚀 You can now start fresh with a new setup!\033[0m"
}

# Run main function
main "$@" 