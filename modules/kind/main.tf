# Kind cluster for local testing
locals {
  cluster_name = var.cluster_name
}

resource "null_resource" "kind_cluster" {
  triggers = {
    cluster_name = local.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      kind create cluster --name ${self.triggers.cluster_name} --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
EOF
    EOT
  }
  
}