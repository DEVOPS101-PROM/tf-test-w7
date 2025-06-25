# Troubleshooting Guide

## 🚨 Поширені проблеми та їх вирішення

### 1. Помилка з legacy модулями

**Проблема:**
```
Error: Module is incompatible with count, for_each, and depends_on
```

**Рішення:**
Використовуйте спрощену версію без зовнішніх модулів:

```bash
# Перейменуйте файли
mv main.tf main.tf.backup
mv main-simple.tf main.tf
mv outputs.tf outputs.tf.backup
mv outputs-simple.tf outputs.tf

# Ініціалізуйте заново
tofu init
```

### 2. Проблеми з Flux bootstrap

**Проблема:**
```
Error: flux_bootstrap_git resource not found
```

**Рішення:**
Переконайтеся, що Flux CLI встановлений:

```bash
# Встановити Flux CLI
curl -s https://fluxcd.io/install.sh | sudo bash

# Перевірити версію
flux version
```

### 3. Проблеми з kind кластером

**Проблема:**
```
Error: kind command not found
```

**Рішення:**
```bash
# Встановити kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Перевірити встановлення
kind version
```

### 4. Проблеми з Google Cloud

**Проблема:**
```
Error: google: could not find default credentials
```

**Рішення:**
```bash
# Авторизуватися в Google Cloud
gcloud auth login
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 5. Проблеми з GitHub токеном

**Проблема:**
```
Error: GitHub API rate limit exceeded
```

**Рішення:**
```bash
# Створити Personal Access Token з правами:
# - repo (повний доступ)
# - workflow (запуск Actions)
# - admin:org (для організацій)

# Встановити токен
export GITHUB_TOKEN="your-token-here"
```

### 6. Проблеми з kubectl

**Проблема:**
```
Error: Unable to connect to the server
```

**Рішення:**
```bash
# Для GKE
gcloud container clusters get-credentials CLUSTER_NAME --region REGION --project PROJECT_ID

# Для kind
kubectl cluster-info --context kind-flux-test
```

### 7. Проблеми з Flux синхронізацією

**Проблема:**
```
Flux не синхронізує зміни
```

**Рішення:**
```bash
# Перевірити статус
kubectl get gitrepository -A
kubectl describe gitrepository kbot -n flux-system

# Перезапустити Flux
kubectl delete pod -l app.kubernetes.io/name=flux -n flux-system

# Перевірити SSH ключі
kubectl get secret flux-system -n flux-system -o yaml
```

### 8. Проблеми з Helm чартами

**Проблема:**
```
Error: chart not found
```

**Рішення:**
```bash
# Перевірити HelmRelease
kubectl get helmrelease -A
kubectl describe helmrelease kbot -n flux-system

# Перевірити Helm чарт
helm repo list
helm search repo kbot
```

## 🔧 Альтернативні підходи

### Спрощений варіант без зовнішніх модулів

Якщо виникають проблеми з зовнішніми модулями, використовуйте спрощену версію:

1. **Використовуйте `main-simple.tf`:**
```bash
cp main-simple.tf main.tf
cp outputs-simple.tf outputs.tf
```

2. **Ініціалізуйте заново:**
```bash
tofu init
```

3. **Застосуйте конфігурацію:**
```bash
tofu apply -var-file=vars.tfvars -auto-approve
```

### Локальне тестування без GKE

Для швидкого тестування без GKE:

```bash
# Використовуйте тільки kind
tofu apply -var-file=vars.tfvars -var="enable_local_testing=true" -auto-approve
```

## 📞 Отримання допомоги

### Корисні команди для діагностики

```bash
# Перевірка статусу
make status

# Перегляд логів
make logs

# Перевірка Flux
make flux-check

# Валідація конфігурації
tofu validate

# Форматування коду
tofu fmt -recursive
```

### Логи та діагностика

```bash
# Логи Flux
kubectl logs -n flux-system -l app.kubernetes.io/name=flux

# Логи додатку
kubectl logs -l app.kubernetes.io/name=kbot -n kbot

# Опис ресурсів
kubectl describe gitrepository kbot -n flux-system
kubectl describe helmrelease kbot -n flux-system
```

## 🆘 Екстрені заходи

### Повне очищення

```bash
# Видалити всі ресурси
make cleanup

# Очистити kind кластери
kind delete cluster --all

# Очистити Docker
docker system prune -a

# Видалити .terraform
rm -rf .terraform .terraform.lock.hcl
```

### Відновлення з резервної копії

```bash
# Відновити оригінальні файли
mv main.tf.backup main.tf
mv outputs.tf.backup outputs.tf

# Ініціалізувати заново
tofu init
``` 