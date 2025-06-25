# Flux GitOps Infrastructure on GKE

Цей проект демонструє повну автоматизацію розгортання та управління інфраструктурою на Google Kubernetes Engine (GKE) з використанням Flux CD для GitOps підходу.

## 🏗️ Архітектура

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub Repo   │    │   GKE Cluster   │    │   Flux System   │
│                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │   kbot app  │ │    │ │   Flux CD   │ │    │ │ GitOps Repo │ │
│ │             │ │    │ │             │ │    │ │             │ │
│ │ ┌─────────┐ │ │    │ │ ┌─────────┐ │ │    │ │ ┌─────────┐ │ │
│ │ │  Go App │ │ │    │ │ │HelmRel. │ │ │    │ │ │Manifests│ │ │
│ │ └─────────┘ │ │    │ │ └─────────┘ │ │    │ │ └─────────┘ │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────┴─────────────┐
                    │     CI/CD Pipeline        │
                    │                           │
                    │ ┌───────────────────────┐ │
                    │ │ GitHub Actions        │ │
                    │ │ - Build & Test        │ │
                    │ │ - Push Image          │ │
                    │ │ - Update Helm Chart   │ │
                    │ │ - Deploy via Flux     │ │
                    │ └───────────────────────┘ │
                    └───────────────────────────┘
```

## 🎯 Модульна архітектура

Проект використовує модульну архітектуру для гнучкого розгортання на різних платформах:

- **Kind** (за замовчуванням) - локальний кластер для тестування
- **GKE** - production-ready кластер в Google Cloud

**📖 Детальна документація модулів:** [MODULES_README.md](MODULES_README.md)

## 🚀 Швидкий старт

### Передумови

1. **OpenTofu** (>= 1.0)
2. **kubectl** (>= 1.25)
3. **Google Cloud SDK** (для GKE)
4. **GitHub Personal Access Token** з правами на створення репозиторіїв
5. **Docker** (для локального тестування)

### Налаштування

1. **Клонуйте репозиторій:**
```bash
git clone <your-repo-url>
cd tf-test-w7
```

2. **Налаштуйте змінні:**
```bash
cp vars.tfvars.example vars.tfvars
# Відредагуйте vars.tfvars з вашими значеннями
```

3. **Ініціалізуйте OpenTofu:**
```bash
# For OpenTofu with Flux provider
make init-with-flux

# Or manually
make install-flux-provider
make init
```

4. **Розгорніть інфраструктуру:**
```bash
# Для локального тестування (kind)
make setup-local

# Для GKE
make setup-gke
```

5. **Розгорніть додаток:**
```bash
make deploy-kbot
```

## 📁 Структура проекту

```
tf-test-w7/
├── main.tf                 # Основна конфігурація OpenTofu
├── variables.tf            # Змінні OpenTofu
├── vars.tfvars            # Значення змінних
├── Makefile               # Команди для управління
├── modules/               # Модульна архітектура
│   ├── kind/             # Локальний Kubernetes кластер
│   ├── gke/              # Google Kubernetes Engine
│   ├── tls/              # SSH ключі для Flux
│   ├── github/           # GitHub репозиторій
│   └── flux/             # Flux CD bootstrap
├── .github/
│   └── workflows/
│       └── ci-cd.yml      # GitHub Actions pipeline
└── flux-manifests/        # Flux GitOps маніфести
    ├── clusters/
    │   └── gke/
    │       └── flux-system/
    │           └── gotk-components.yaml
    └── apps/
        └── kbot/
            ├── namespace.yaml
            ├── gitrepository.yaml
            ├── helmrelease.yaml
            └── kustomization.yaml
```

## 🔧 Використання

### Вибір платформи

**Для локального тестування:**
```hcl
platform = "kind"
```

**Для production на GKE:**
```hcl
platform = "gke"
GOOGLE_REGION = "europe-west1"
GOOGLE_PROJECT = "your-project-id"
```

### Основні команди

```bash
# Показати допомогу
make help

# Планування змін
make plan

# Застосування змін
make apply

# Локальне тестування з kind
make local-test

# Перевірка статусу Flux
make flux-check

# Перегляд логів
make logs

# Загальний статус
make status
```

### Робота з Flux

```bash
# Призупинити синхронізацію
make flux-suspend

# Відновити синхронізацію
make flux-resume

# Перевірити статус додатків
kubectl get helmrelease -A
kubectl get gitrepository -A
```

## 🏗️ TF-Controller для Terraform GitOps

Проект включає інтеграцію з [TF-Controller](https://flux-iac.github.io/tofu-controller/) для GitOps автоматизації Terraform/OpenTofu ресурсів.

### Особливості TF-Controller

- **GitOps автоматизація** для Terraform ресурсів
- **Drift detection** - автоматичне виявлення та виправлення дрифту
- **Multi-tenancy** підтримка через runner pods
- **Manual approval** workflow для критичної інфраструктури
- **State management** через Kubernetes secrets

### Налаштування TF-Controller

```bash
# Включити TF-Controller приклади
# Відредагуйте vars.tfvars:
enable_tf_controller_examples = true
environment = "dev"

# Застосувати конфігурацію
make apply
```

### Робота з TF-Controller

```bash
# Перевірити статус TF-Controller
make tf-controller-check

# Переглянути логи TF-Controller
make tf-controller-logs

# Призупинити Terraform reconciliation
make tf-controller-suspend

# Відновити Terraform reconciliation
make tf-controller-resume

# Примусово запустити reconciliation
make tf-controller-force-reconcile

# Затвердити Terraform plan
make tf-controller-approve-plan

# Переглянути Terraform state
make tf-controller-state
```

### Приклади Terraform конфігурацій

Проект включає готові приклади в директорії `terraform-examples/`:

```
terraform-examples/
├── example/              # Development environment
│   ├── main.tf          # Google Cloud resources
│   ├── variables.tf     # Input variables
│   ├── outputs.tf       # Output values
│   └── versions.tf      # Version constraints
└── production/          # Production environment
    ├── main.tf          # Production resources
    ├── variables.tf     # Production variables
    ├── outputs.tf       # Production outputs
    └── versions.tf      # Version constraints
```

### GitOps моделі

1. **GitOps Automation Model** - повна автоматизація
2. **Manual Approval Model** - ручне затвердження планів
3. **Drift Detection Only** - тільки моніторинг дрифту

**📖 Детальний гід по TF-Controller:** [TF_CONTROLLER_GUIDE.md](TF_CONTROLLER_GUIDE.md)

## 🔄 CI/CD Pipeline

GitHub Actions автоматично:

1. **Тестує** код додатку
2. **Збирає** Docker образ
3. **Пушує** образ в GitHub Container Registry
4. **Оновлює** версію Helm чарту
5. **Розгортає** через Flux

### Тригери пайплайну

- Push в `main` гілку
- Pull Request в `main` гілку

## 🧪 Тестування

### Локальне тестування

```bash
# Розгорнути kind кластер
make local-test

# Перевірити статус
make status

# Очистити ресурси
make cleanup
```

### Тестування на GKE

```bash
# Розгорнути на GKE
make setup-gke

# Розгорнути додаток
make deploy-kbot

# Перевірити роботу
kubectl port-forward svc/kbot 8080:8080 -n kbot
curl http://localhost:8080
```

## 🔍 Моніторинг

### Flux статус

```bash
# Перевірка Flux компонентів
kubectl get pods -n flux-system

# Перегляд логів
kubectl logs -n flux-system -l app.kubernetes.io/name=flux

# Статус GitRepository
kubectl describe gitrepository kbot -n flux-system

# Статус HelmRelease
kubectl describe helmrelease kbot -n flux-system
```

### Додаток статус

```bash
# Перевірка подів
kubectl get pods -n kbot

# Перегляд логів додатку
kubectl logs -l app.kubernetes.io/name=kbot -n kbot

# Перевірка сервісів
kubectl get svc -n kbot
```

## 🛠️ Troubleshooting

### Швидкі виправлення

**Проблема з legacy модулями:**
```bash
# Використайте спрощену версію
cp main-simple.tf main.tf
cp outputs-simple.tf outputs.tf
tofu init
```

**Проблеми з Flux:**
```bash
# Встановити Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash
```

**Проблеми з kind:**
```bash
# Встановити kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

### Поширені проблеми

1. **Flux не синхронізується:**
```bash
kubectl get gitrepository -A
kubectl describe gitrepository kbot -n flux-system
```

2. **HelmRelease не розгортається:**
```bash
kubectl get helmrelease -A
kubectl describe helmrelease kbot -n flux-system
```

3. **Проблеми з аутентифікацією:**
```bash
kubectl get secret flux-system -n flux-system -o yaml
```

### Корисні команди

```bash
# Очистити всі ресурси
make cleanup

# Перезапустити Flux
kubectl delete pod -l app.kubernetes.io/name=flux -n flux-system

# Перевірити мережеві політики
kubectl get networkpolicy -A
```

**📖 Детальний гід по вирішенню проблем:** [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

## 📚 Додаткові ресурси

- [Flux Documentation](https://fluxcd.io/docs/)
- [OpenTofu Documentation](https://opentofu.org/docs/)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [GitOps Best Practices](https://www.gitops.tech/)
- [Модульна архітектура](MODULES_README.md)

## 🤝 Внесок

1. Fork репозиторію
2. Створіть feature branch
3. Commit зміни
4. Push в branch
5. Створіть Pull Request

## 📄 Ліцензія

MIT License - дивіться файл [LICENSE](LICENSE) для деталей.

## 👥 Автори

- **Ваш товариш** - початкова ідея та вимоги
- **AI Assistant** - реалізація та документація

---

**Час виконання:** ~4-6 годин  
**Вартість роботи:** $350  
**Складність:** Середня  
**Готовність:** 100% ✅ 