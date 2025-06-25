.PHONY: help init plan apply destroy local-test flux-check flux-suspend flux-resume

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize Terraform/OpenTofu
	tofu init

install-flux-provider: ## Install Flux provider for OpenTofu
	@echo "Installing Flux provider for OpenTofu..."
	./scripts/install-flux-provider.sh

init-with-flux: ## Initialize with Flux provider installation
	@echo "Installing Flux provider and initializing..."
	./scripts/install-flux-provider.sh
	tofu init

plan: ## Plan Terraform/OpenTofu changes
	tofu plan -var-file=vars.tfvars

apply: ## Apply Terraform/OpenTofu changes
	tofu apply -var-file=vars.tfvars -auto-approve

destroy: ## Destroy Terraform/OpenTofu infrastructure
	tofu destroy -var-file=vars.tfvars -auto-approve

local-test: ## Run local testing with kind cluster
	tofu apply -var-file=vars.tfvars -var="enable_local_testing=true" -auto-approve

flux-check: ## Check Flux status
	kubectl get flux -A
	kubectl get gitrepository -A
	kubectl get helmrelease -A

flux-suspend: ## Suspend Flux reconciliation
	kubectl patch kustomization flux-system -n flux-system --type='merge' -p='{"spec":{"suspend":true}}'

flux-resume: ## Resume Flux reconciliation
	kubectl patch kustomization flux-system -n flux-system --type='merge' -p='{"spec":{"suspend":false}}'

# TF-Controller commands
tf-controller-check: ## Check TF-Controller status
	@echo "=== TF-Controller Pods ==="
	kubectl get pods -n flux-system -l app.kubernetes.io/name=tf-controller
	@echo ""
	@echo "=== Terraform Resources ==="
	kubectl get terraforms -A
	@echo ""
	@echo "=== Terraform Sources ==="
	kubectl get gitrepository -A | grep terraform

tf-controller-logs: ## Show TF-Controller logs
	kubectl logs -n flux-system -l app.kubernetes.io/name=tf-controller -f

tf-controller-suspend: ## Suspend Terraform reconciliation
	@read -p "Enter Terraform resource name: " name; \
	read -p "Enter namespace (default: flux-system): " namespace; \
	namespace=$${namespace:-flux-system}; \
	kubectl patch terraform $$name -n $$namespace --type='merge' -p='{"spec":{"suspend":true}}'

tf-controller-resume: ## Resume Terraform reconciliation
	@read -p "Enter Terraform resource name: " name; \
	read -p "Enter namespace (default: flux-system): " namespace; \
	namespace=$${namespace:-flux-system}; \
	kubectl patch terraform $$name -n $$namespace --type='merge' -p='{"spec":{"suspend":false}}'

tf-controller-force-reconcile: ## Force Terraform reconciliation
	@read -p "Enter Terraform resource name: " name; \
	read -p "Enter namespace (default: flux-system): " namespace; \
	namespace=$${namespace:-flux-system}; \
	kubectl annotate terraform $$name -n $$namespace fluxcd.io/reconcileAt="$$(date +%s)"

tf-controller-approve-plan: ## Approve a Terraform plan
	@read -p "Enter Terraform resource name: " name; \
	read -p "Enter plan ID: " plan_id; \
	read -p "Enter namespace (default: flux-system): " namespace; \
	namespace=$${namespace:-flux-system}; \
	kubectl patch terraform $$name -n $$namespace --type='merge' -p='{"spec":{"approvePlan":"$$plan_id"}}'

tf-controller-state: ## Show Terraform state information
	@echo "=== Terraform State Secrets ==="
	kubectl get secrets -n flux-system -l terraform.toolkit.fluxcd.io/name
	@echo ""
	@echo "=== Recent Terraform Events ==="
	kubectl get events -n flux-system --sort-by='.lastTimestamp' | grep terraform | tail -10

setup-gke: ## Setup GKE cluster and Flux
	@echo "Setting up GKE cluster and Flux..."
	tofu apply -var-file=vars.tfvars -auto-approve
	@echo "Waiting for Flux to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=flux -n flux-system --timeout=300s
	@echo "Flux is ready!"

deploy-kbot: ## Deploy kbot application via Flux
	@echo "Deploying kbot application..."
	kubectl apply -f flux-manifests/apps/kbot/
	@echo "kbot deployment initiated. Check status with: make flux-check"

cleanup: ## Clean up all resources
	@echo "Cleaning up all resources..."
	kubectl delete -f flux-manifests/apps/kbot/ --ignore-not-found=true
	tofu destroy -var-file=vars.tfvars -auto-approve

# Development helpers
fmt: ## Format Terraform/OpenTofu files
	tofu fmt -recursive

validate: ## Validate Terraform/OpenTofu configuration
	tofu validate

# Monitoring
logs: ## Show Flux logs
	kubectl logs -n flux-system -l app.kubernetes.io/name=flux -f

status: ## Show cluster and application status
	@echo "=== Cluster Status ==="
	kubectl get nodes
	@echo ""
	@echo "=== Flux Status ==="
	kubectl get flux -A
	@echo ""
	@echo "=== Applications ==="
	kubectl get helmrelease -A
	@echo ""
	@echo "=== TF-Controller Status ==="
	kubectl get terraforms -A
	@echo ""
	@echo "=== Pods ==="
	kubectl get pods -A

# Local testing helpers
setup-local: ## Setup local kind cluster for testing
	@echo "Setting up local kind cluster..."
	tofu apply -var-file=vars.tfvars -var="enable_local_testing=true" -auto-approve
	@echo "Local cluster ready!"

cleanup-local: ## Clean up local kind cluster
	@echo "Cleaning up local kind cluster..."
	tofu destroy -var-file=vars.tfvars -var="enable_local_testing=true" -auto-approve
	@echo "Local cluster cleaned up!" 