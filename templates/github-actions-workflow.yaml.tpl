name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:
    inputs:
      version:
        description: 'Version to release'
        required: false
        default: ''

env:
  REGISTRY: ${image_repository}
  IMAGE_NAME: $${app_name}

jobs:
  test:
    name: Test
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Go
      uses: actions/setup-go@v4
      with:
        go-version: '1.21'

    - name: Run tests
      run: |
        go test -v ./...
        go vet ./...
        go fmt ./...

    - name: Run security scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'fs'
        scan-ref: '.'
        format: 'sarif'
        output: 'trivy-results.sarif'

  build:
    name: Build and Push
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'
    outputs:
      image_tag: $${{ steps.meta.outputs.tags }}
      version: $${{ steps.version.outputs.version }}
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        fetch-depth: 0

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: $${{ env.REGISTRY }}
        username: $${{ secrets.REGISTRY_USERNAME }}
        password: $${{ secrets.REGISTRY_PASSWORD }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: $${{ env.REGISTRY }}/$${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=semver,pattern=$${{version}}
          type=semver,pattern=$${{major}}.$${{minor}}
          type=sha,prefix=$${{branch}}-

    - name: Generate version
      id: version
      run: |
        if [ "$${{ github.event.inputs.version }}" != "" ]; then
          echo "version=$${{ github.event.inputs.version }}" >> $GITHUB_OUTPUT
        else
          echo "version=$(date +'%Y.%m.%d-%H%M%S')" >> $GITHUB_OUTPUT
        fi

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: |
          $${{ steps.meta.outputs.tags }}
          $${{ env.REGISTRY }}/$${{ env.IMAGE_NAME }}:$${{ steps.version.outputs.version }}
        labels: $${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  update-helm-chart:
    name: Update Helm Chart
    needs: build
    runs-on: ubuntu-latest
    if: github.event_name == 'push' || github.event_name == 'workflow_dispatch'
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        token: $${{ secrets.GITHUB_TOKEN }}

    - name: Configure Git
      run: |
        git config --local user.email "action@github.com"
        git config --local user.name "GitHub Action"

    - name: Update Helm chart version
      run: |
        # Update Chart.yaml version
        sed -i "s/version: .*/version: $${{ needs.build.outputs.version }}/" charts/$${app_name}/Chart.yaml
        sed -i "s/appVersion: .*/appVersion: \"$${{ needs.build.outputs.version }}\"/" charts/$${app_name}/Chart.yaml
        
        # Update values.yaml with new image tag
        sed -i "s|repository: .*|repository: $${{ env.REGISTRY }}/$${{ env.IMAGE_NAME }}|" charts/$${app_name}/values.yaml
        sed -i "s/tag: .*/tag: \"$${{ needs.build.outputs.version }}\"/" charts/$${app_name}/values.yaml

    - name: Commit and push changes
      run: |
        git add charts/$${app_name}/Chart.yaml charts/$${app_name}/values.yaml
        git commit -m "chore: bump version to $${{ needs.build.outputs.version }}"
        git push

  deploy:
    name: Deploy to Cluster
    needs: [build, update-helm-chart]
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install kubectl
      uses: azure/setup-kubectl@v3
      with:
        version: 'latest'

    - name: Configure kubectl for Kind cluster
      run: |
        echo "Configuring kubectl for local Kind cluster"

    - name: Verify Flux installation
      run: |
        kubectl get pods -n flux-system
        flux check

    - name: Trigger Flux reconciliation
      run: |
        flux reconcile source git $${app_name}
        flux reconcile helmrelease $${app_name}

    - name: Wait for deployment
      run: |
        kubectl wait --for=condition=available --timeout=300s deployment/$${app_name}

  notify:
    name: Notify
    needs: [build, deploy]
    runs-on: ubuntu-latest
    if: always()
    steps:
    - name: Notify on success
      if: needs.build.result == 'success' && needs.deploy.result == 'success'
      run: |
        echo "✅ Deployment successful!"
        echo "Version: $${{ needs.build.outputs.version }}"
        echo "Image: $${{ needs.build.outputs.image_tag }}"

    - name: Notify on failure
      if: needs.build.result == 'failure' || needs.deploy.result == 'failure'
      run: |
        echo "❌ Deployment failed!"
        exit 1 