# Модульна архітектура Flux GitOps

Цей проект використовує модульну архітектуру для гнучкого розгортання Flux GitOps інфраструктури на різних платформах.

## 🏗️ Архітектура

```
tf-test-w7/
├── main.tf                 # Головний файл з умовним підключенням модулів
├── variables.tf            # Змінні для всіх модулів
├── vars.tfvars            # Значення змінних
├── modules/               # Каталог з модулями
│   ├── kind/             # Локальний Kubernetes кластер
│   ├── gke/              # Google Kubernetes Engine
│   ├── tls/              # SSH ключі для Flux
│   ├── github/           # GitHub репозиторій
│   └── flux/             # Flux CD bootstrap
└── flux-manifests/       # GitOps маніфести
```

## 🎯 Вибір платформи

Проект підтримує дві платформи через змінну `platform`:

### Kind (за замовчуванням)
```hcl
platform = "kind"
```
- Локальний кластер для тестування
- Швидкий старт
- Не потребує Google Cloud

### GKE
```hcl
platform = "gke"
```
- Production-ready кластер
- Повна інтеграція з Google Cloud
- Потребує налаштування GCP

## 📦 Модулі

### 1. Kind Module (`modules/kind/`)
Створює локальний Kubernetes кластер за допомогою kind.

**Змінні:**
- `cluster_name` - назва кластера (за замовчуванням: "flux-test")

**Виводи:**
- `cluster_name` - назва створеного кластера

### 2. GKE Module (`modules/gke/`)
Створює Google Kubernetes Engine кластер з node pool.

**Змінні:**
- `GOOGLE_REGION` - регіон GCP
- `GOOGLE_PROJECT` - ID проекту GCP
- `GKE_NUM_NODES` - кількість вузлів

**Виводи:**
- `cluster_name` - назва кластера
- `endpoint` - endpoint кластера

### 3. TLS Module (`modules/tls/`)
Генерує RSA ключі для SSH аутентифікації Flux.

**Змінні:** Немає

**Виводи:**
- `private_key` - приватний ключ
- `public_key` - публічний ключ

### 4. GitHub Module (`modules/github/`)
Створює GitHub репозиторій для GitOps.

**Змінні:**
- `github_repository_name` - назва репозиторію
- `github_owner` - власник репозиторію
- `description` - опис репозиторію

**Виводи:**
- `repo_url` - URL репозиторію

### 5. Flux Module (`modules/flux/`)
Встановлює та налаштовує Flux CD.

**Змінні:**
- `cluster_name` - назва кластера
- `github_owner` - власник GitHub
- `github_repository_name` - назва репозиторію
- `flux_namespace` - namespace для Flux
- `private_key` - приватний SSH ключ
- `public_key` - публічний SSH ключ

**Виводи:**
- `flux_bootstrap_status` - статус bootstrap

## 🚀 Використання

### Швидкий старт з Kind

```bash
# 1. Клонувати репозиторій
git clone <repository-url>
cd tf-test-w7

# 2. Налаштувати змінні
cp vars.tfvars.example vars.tfvars
# Відредагувати vars.tfvars (platform = "kind")

# 3. Ініціалізувати
tofu init

# 4. Розгорнути
tofu apply -var-file=vars.tfvars
```

### Розгортання на GKE

```bash
# 1. Налаштувати змінні
platform = "gke"
GOOGLE_REGION = "europe-west1"
GOOGLE_PROJECT = "your-project-id"

# 2. Авторизуватися в Google Cloud
gcloud auth login
gcloud config set project your-project-id

# 3. Розгорнути
tofu apply -var-file=vars.tfvars
```

## 🔧 Налаштування

### Змінні для Kind
```hcl
platform = "kind"
flux_namespace = "flux-system"
github_owner = "your-username"
github_repository_name = "flux-gitops"
```

### Змінні для GKE
```hcl
platform = "gke"
GOOGLE_REGION = "europe-west1"
GOOGLE_PROJECT = "your-project-id"
GKE_NUM_NODES = 3
flux_namespace = "flux-system"
github_owner = "your-username"
github_repository_name = "flux-gitops"
```

## 🔄 Workflow

1. **Вибір платформи** через змінну `platform`
2. **Умовне створення** кластера (kind або GKE)
3. **Генерація SSH ключів** для Flux
4. **Створення GitHub репозиторію**
5. **Bootstrap Flux** в кластері
6. **Автоматична синхронізація** GitOps маніфестів

## 📊 Переваги модульної архітектури

- **Гнучкість:** Легко перемикатися між платформами
- **Масштабованість:** Можна додавати нові платформи (EKS, AKS)
- **Чистота:** Кожен модуль відповідає за свою частину
- **Перевикористання:** Модулі можна використовувати окремо
- **Тестування:** Легко тестувати кожен модуль окремо

## 🛠️ Розширення

### Додавання нової платформи

1. Створити новий модуль в `modules/`
2. Додати умову в головний `main.tf`
3. Оновити змінні та виводи

### Приклад для EKS:
```hcl
module "eks" {
  source = "./modules/eks"
  count  = var.platform == "eks" ? 1 : 0
  # ... змінні
}
```

## 📚 Документація модулів

- [Kind Module](modules/kind/README.md)
- [GKE Module](modules/gke/README.md)
- [TLS Module](modules/tls/README.md)
- [GitHub Module](modules/github/README.md)
- [Flux Module](modules/flux/README.md)

## 🎉 Результат

Модульна архітектура дозволяє:
- Швидко перемикатися між платформами
- Легко тестувати та розробляти
- Масштабувати інфраструктуру
- Зберігати код чистим та організованим 