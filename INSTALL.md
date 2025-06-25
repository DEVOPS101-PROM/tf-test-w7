# Installation Guide

Цей документ містить покрокові інструкції для встановлення всіх необхідних інструментів для роботи з проектом.

## 🛠️ Необхідні інструменти

### 1. OpenTofu

**Ubuntu/Debian:**
```bash
# Додати репозиторій
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Встановити OpenTofu
sudo apt update && sudo apt install opentofu
```

**macOS:**
```bash
brew install opentofu
```

**Windows:**
```bash
choco install opentofu
```

### 2. kubectl

**Ubuntu/Debian:**
```bash
# Завантажити kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**macOS:**
```bash
brew install kubectl
```

**Windows:**
```bash
choco install kubernetes-cli
```

### 3. kind (Kubernetes in Docker)

```bash
# Завантажити kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### 4. Google Cloud SDK

**Ubuntu/Debian:**
```bash
# Додати репозиторій
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Встановити gcloud
sudo apt-get update && sudo apt-get install google-cloud-cli
```

**macOS:**
```bash
brew install google-cloud-sdk
```

**Windows:**
```bash
# Завантажити з https://cloud.google.com/sdk/docs/install
```

### 5. Docker

**Ubuntu/Debian:**
```bash
# Встановити Docker
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

**macOS:**
```bash
brew install --cask docker
```

**Windows:**
```bash
# Завантажити Docker Desktop з https://www.docker.com/products/docker-desktop
```

### 6. Make

**Ubuntu/Debian:**
```bash
sudo apt-get install make
```

**macOS:**
```bash
brew install make
```

**Windows:**
```bash
choco install make
```

## 🔧 Налаштування

### 1. Google Cloud

```bash
# Авторизація в Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud auth application-default login
```

### 2. GitHub

```bash
# Створити Personal Access Token
# 1. Перейти в GitHub Settings -> Developer settings -> Personal access tokens
# 2. Створити новий token з правами:
#    - repo (повний доступ до репозиторіїв)
#    - workflow (запуск GitHub Actions)
# 3. Скопіювати token
```

### 3. Перевірка встановлення

```bash
# Перевірити всі інструменти
opentofu --version
kubectl version --client
kind version
gcloud version
docker --version
make --version
```

## 🚀 Швидкий старт

Після встановлення всіх інструментів:

1. **Клонувати репозиторій:**
```bash
git clone <your-repo-url>
cd tf-test-w7
```

2. **Налаштувати змінні:**
```bash
cp vars.tfvars.example vars.tfvars
# Відредагувати vars.tfvars
```

3. **Запустити локальне тестування:**
```bash
./scripts/test-local.sh
```

## 🔍 Troubleshooting

### Проблеми з правами доступу

```bash
# Додати користувача в групу docker
sudo usermod -aG docker $USER
# Перезавантажити сесію
newgrp docker
```

### Проблеми з Google Cloud

```bash
# Перевірити авторизацію
gcloud auth list
gcloud config list

# Переустановити авторизацію
gcloud auth application-default login
```

### Проблеми з kind

```bash
# Очистити всі кластери
kind delete cluster --all

# Перевірити Docker
docker ps
```

## 📚 Додаткові ресурси

- [OpenTofu Documentation](https://opentofu.org/docs/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [Google Cloud Documentation](https://cloud.google.com/docs)
- [Docker Documentation](https://docs.docker.com/) 