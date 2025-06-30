# Makefile for Local Kubernetes Cluster with Flux GitOps

# Variables
TF_VARS_FILE = vars.tfvars
CLUSTER_NAME = $(shell grep 'cluster_name' $(TF_VARS_FILE) | cut -d'=' -f2 | tr -d ' "')
APP_NAME = $(shell grep 'app_name' $(TF_VARS_FILE) | cut -d'=' -f2 | tr -d ' "')
GITHUB_OWNER = $(shell grep 'github_owner' $(TF_VARS_FILE) | cut -d'=' -f2 | tr -d ' "')

# Colors
RED = \033[0;31m
GREEN = \033[0;32m
YELLOW = \033[1;33m
BLUE = \033[0;34m
NC = \033[0m # No Color

.PHONY: help init plan apply destroy install clean status logs test

# Default target
help:
	@echo "$(BLUE)Local Kubernetes Cluster with Flux GitOps$(NC)"
	@echo ""
	@echo "$(YELLOW)Available commands:$(NC)"
	@echo "  init      - Initialize OpenTofu"
	@echo "  plan      - Plan OpenTofu changes"
	@echo "  apply     - Apply OpenTofu configuration"
	@echo "  destroy   - Destroy OpenTofu resources"
	@echo "  install   - Run installation script"
	@echo "  clean     - Run cleanup script"
	@echo "  status    - Check cluster and Flux status"
	@echo "  logs      - Show application logs"
	@echo "  test      - Run tests"
	@echo "  access    - Access application and monitoring"
	@echo "  scale     - Scale application"
	@echo "  update    - Update application"

# Initialize OpenTofu
init:
	@echo "$(BLUE)🔧 Initializing OpenTofu...$(NC)"
	tofu init

# Plan OpenTofu changes
plan: init
	@echo "$(BLUE)📋 Planning OpenTofu changes...$(NC)"
	tofu plan -var-file=$(TF_VARS_FILE)

# Apply OpenTofu configuration
apply: init
	@echo "$(BLUE)🚀 Applying OpenTofu configuration...$(NC)"
	tofu apply -var-file=$(TF_VARS_FILE) -auto-approve

# Destroy OpenTofu resources
destroy:
	@echo "$(RED)🗑️  Destroying OpenTofu resources...$(NC)"
	tofu destroy -var-file=$(TF_VARS_FILE) -auto-approve

# Run installation script
install: apply
	@echo "$(BLUE)🔧 Running installation script...$(NC)"
	@if [ -f "install-scripts.sh" ]; then \
		chmod +x install-scripts.sh; \
		./install-scripts.sh; \
	else \
		echo "$(RED)❌ Installation script not found. Run 'make apply' first.$(NC)"; \
		exit 1; \
	fi

# Run cleanup script
clean:
	@echo "$(YELLOW)🧹 Running cleanup script...$(NC)"
	@if [ -f "cleanup.sh" ]; then \
		chmod +x cleanup.sh; \
		./cleanup.sh; \
	else \
		echo "$(RED)❌ Cleanup script not found.$(NC)"; \
		exit 1; \
	fi

# Check cluster and Flux status
status:
	@echo "$(BLUE)📊 Checking cluster and Flux status...$(NC)"
	@echo "$(YELLOW)Cluster Status:$(NC)"
	kubectl get nodes
	@echo ""
	@echo "$(YELLOW)Flux Status:$(NC)"
	flux check
	@echo ""
	@echo "$(YELLOW)Application Status:$(NC)"
	kubectl get pods -l app=$(APP_NAME)
	@echo ""
	@echo "$(YELLOW)Services:$(NC)"
	kubectl get services -l app=$(APP_NAME)
	@echo ""
	@echo "$(YELLOW)Ingress:$(NC)"
	kubectl get ingress -l app=$(APP_NAME)

# Show application logs
logs:
	@echo "$(BLUE)📝 Showing application logs...$(NC)"
	kubectl logs -l app=$(APP_NAME) --tail=50 -f

# Run tests
test:
	@echo "$(BLUE)🧪 Running tests...$(NC)"
	@if [ -f "main.go" ]; then \
		go test -v ./...; \
	else \
		echo "$(YELLOW)No Go tests found.$(NC)"; \
	fi

# Access application and monitoring
access:
	@echo "$(BLUE)🌐 Access Information:$(NC)"
	@echo ""
	@echo "$(YELLOW)Application:$(NC)"
	@echo "  kubectl port-forward svc/$(APP_NAME) 8080:80"
	@echo "  curl http://localhost:8080"
	@echo ""
	@echo "$(YELLOW)Monitoring:$(NC)"
	@echo "  Prometheus: kubectl port-forward svc/prometheus-operated 9090:9090 -n monitoring"
	@echo "  Grafana: kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring"
	@echo ""
	@echo "$(YELLOW)Flux UI:$(NC)"
	@echo "  kubectl port-forward svc/flux-system 9000:9000 -n flux-system"

# Scale application
scale:
	@echo "$(BLUE)📈 Scaling application...$(NC)"
	@read -p "Enter number of replicas: " replicas; \
	kubectl scale deployment $(APP_NAME) --replicas=$$replicas

# Update application
update:
	@echo "$(BLUE)🔄 Updating application...$(NC)"
	flux reconcile source git $(APP_NAME)
	flux reconcile helmrelease $(APP_NAME)

# Quick setup (init + apply + install)
setup: install

# Quick teardown (destroy + clean)
teardown: destroy clean

# Show cluster info
info:
	@echo "$(BLUE)ℹ️  Cluster Information:$(NC)"
	@echo "Cluster Name: $(CLUSTER_NAME)"
	@echo "Application: $(APP_NAME)"
	@echo "GitHub Owner: $(GITHUB_OWNER)"
	@echo ""
	@echo "$(YELLOW)Repository URLs:$(NC)"
	@tofu output -raw flux_repository_url 2>/dev/null || echo "Not available"
	@tofu output -raw app_repository_url 2>/dev/null || echo "Not available"

# Show help for specific command
help-%:
	@echo "$(BLUE)Help for command: $*$(NC)"
	@case "$*" in \
		init) echo "Initialize OpenTofu and download providers" ;; \
		plan) echo "Show what OpenTofu will do" ;; \
		apply) echo "Create infrastructure resources" ;; \
		install) echo "Run the complete installation script" ;; \
		clean) echo "Remove all resources and files" ;; \
		status) echo "Check the status of cluster and applications" ;; \
		logs) echo "Show application logs" ;; \
		test) echo "Run application tests" ;; \
		access) echo "Show access information for services" ;; \
		scale) echo "Scale the application replicas" ;; \
		update) echo "Trigger Flux reconciliation" ;; \
		*) echo "Unknown command: $*" ;; \
	esac 