#!/bin/bash

set -e

echo "🚀 Starting local testing with kind cluster..."

# Check if kind is installed
if ! command -v kind &> /dev/null; then
    echo "❌ kind is not installed. Please install it first:"
    echo "   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
    echo "   chmod +x ./kind"
    echo "   sudo mv ./kind /usr/local/bin/kind"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install it first."
    exit 1
fi

# Check if OpenTofu is installed
if ! command -v tofu &> /dev/null; then
    echo "❌ OpenTofu is not installed. Please install it first:"
    echo "   https://opentofu.org/docs/intro/install/"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Create test variables
cat > test-vars.tfvars << EOF
GOOGLE_REGION = "local"
GOOGLE_PROJECT = "test-project"
GKE_NUM_NODES = 1
enable_local_testing = true
flux_namespace = "flux-system"
github_owner = "test-user"
github_repository_name = "test-flux-repo"
EOF

echo "📝 Created test variables file"

# Initialize OpenTofu
echo "🔧 Initializing OpenTofu..."
tofu init

# Apply with local testing
echo "🚀 Deploying local kind cluster with Flux..."
tofu apply -var-file=test-vars.tfvars -auto-approve

# Wait for kind cluster to be ready
echo "⏳ Waiting for kind cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=300s

# Wait for Flux to be ready (if deployed)
echo "⏳ Waiting for Flux to be ready..."
if kubectl get namespace flux-system &> /dev/null; then
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=flux -n flux-system --timeout=300s || echo "⚠️  Flux not ready yet, continuing..."
fi

echo "✅ Setup complete!"

# Show status
echo "📊 Cluster status:"
kubectl get nodes
echo ""
echo "📊 All namespaces:"
kubectl get namespaces
echo ""
echo "📊 All pods:"
kubectl get pods -A

echo ""
echo "🎉 Local testing setup complete!"
echo ""
echo "Next steps:"
echo "1. Deploy kbot app: make deploy-kbot"
echo "2. Check status: make status"
echo "3. View logs: make logs"
echo "4. Cleanup: make cleanup-local" 