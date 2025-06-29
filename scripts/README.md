# Scripts Directory

Цей каталог містить корисні скрипти для роботи з проектом.

## Доступні скрипти

### `test-local.sh`

Скрипт для швидкого локального тестування з використанням kind кластера.

**Використання:**
```bash
./scripts/test-local.sh
```

**Що робить:**
- Перевіряє наявність необхідних інструментів (kind, kubectl, OpenTofu)
- Створює тестові змінні
- Ініціалізує OpenTofu
- Розгортає kind кластер з Flux
- Чекає готовності Flux
- Показує статус кластера

**Передумови:**
- kind
- kubectl
- OpenTofu

### Створення власних скриптів

Для створення нових скриптів:

1. Створіть файл з розширенням `.sh`
2. Додайте shebang: `#!/bin/bash`
3. Зробіть файл виконуваним: `chmod +x script-name.sh`
4. Додайте документацію в цей README

### Приклади використання

```bash
# Запуск локального тестування
./scripts/test-local.sh

# Перевірка статусу після тестування
make status

# Очищення ресурсів
make cleanup
``` 