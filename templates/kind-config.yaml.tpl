kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${cluster_name}

# Configure nodes
nodes:
%{ for i in range(num_nodes) ~}
- role: ${i == 0 ? "control-plane" : "worker"}
  image: ${node_image}
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 30000
    hostPort: 30000
    protocol: TCP
%{ endfor ~}

# Networking configuration
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
  disableDefaultCNI: false

# Feature gates for modern Kubernetes features
featureGates:
  IPv6DualStack: true
  ServiceAccountIssuerDiscovery: true

# Runtime configuration
runtimeConfig:
  "api/alpha": "true"
  "api/beta": "true" 