# Инструкция по деплою Ultimate Agent SaaS

## 🎯 Что было исправлено

**Проблема:** Dockerfile искали файлы в корне контекста сборки, а не в подпапках.

**Исправления в Dockerfile:**

### 1. OpenClaw Gateway (`openclaw/Dockerfile`)
```dockerfile
# Было: COPY openclaw.json /root/.openclaw/openclaw.json
# Стало: COPY ./openclaw/openclaw.json /root/.openclaw/openclaw.json
```

### 2. n8n (`n8n/Dockerfile`)
```dockerfile
# Было: COPY ultimate-agent-workflow.json /data/
# Стало: COPY ./n8n/ultimate-agent-workflow.json /data/
```

### 3. DuckDuckGo Proxy (`ddg-proxy/Dockerfile`)
```dockerfile
# Было: COPY ddg_proxy.py .
# Стало: COPY ./ddg-proxy/ddg_proxy.py .
```

## 🚀 Автоматическая загрузка в GitHub

### Вариант 1: Полный скрипт (рекомендуется)
```powershell
# Запустите из PowerShell с правами администратора
cd "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"
.\deploy_to_github.ps1
```

### Вариант 2: Быстрый скрипт
```powershell
cd "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"
.\quick_deploy.ps1
```

### Вариант 3: Вручную
```powershell
# Перейдите в папку проекта
cd "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"

# Инициализируйте Git если нужно
git init

# Настройте удалённый репозиторий
git remote add origin https://github.com/Kabael/ultimate-agent.git

# Добавьте .gitignore
echo "node_modules/" > .gitignore
echo ".env" >> .gitignore
echo "*.log" >> .gitignore

# Добавьте файлы и создайте коммит
git add .
git commit -m "Fix Dockerfile paths for Render deployment"

# Отправьте в GitHub
git push -u origin main
```

## 🔄 Деплой на Render.com

После загрузки в GitHub:

### Шаг 1: Очистка кеша на Render
1. Откройте https://dashboard.render.com
2. Найдите ваш Blueprint "ultimate-agent"
3. Нажмите "Manual Deploy"
4. Выберите **"Clear build cache & deploy"**
5. Дождитесь завершения сборки (5-10 минут)

### Шаг 2: Проверка логов
После деплоя проверьте логи каждого сервиса:

1. **OpenClaw Gateway** - должен запуститься на порту 18789
2. **n8n** - должен запуститься с workflow
3. **DuckDuckGo Proxy** - должен запуститься на порту 8000
4. **Backend API** - должен запуститься на порту 3000

### Шаг 3: Настройка переменных окружения
На Render Dashboard добавьте:

1. **Для OpenClaw Gateway:**
   - `DEEPSEEK_API_KEY` = `sk-a5f795364f2c4b04b01f9f2909d516e2`

2. **Для Backend API:**
   - `TELEGRAM_BOT_TOKEN` = (ваш токен бота)
   - `GOOGLE_SHEETS_API_KEY` = (ваш ключ Google Sheets)

## 📁 Структура проекта после исправлений

```
ultimate-agent-saas/
├── backend/
│   ├── Dockerfile          # Node.js бэкенд
│   └── server.js          # Express API
├── ddg-proxy/
│   ├── Dockerfile          # ✅ ИСПРАВЛЕНО: COPY ./ddg-proxy/ddg_proxy.py
│   └── ddg_proxy.py       # DuckDuckGo прокси
├── n8n/
│   ├── Dockerfile          # ✅ ИСПРАВЛЕНО: COPY ./n8n/ultimate-agent-workflow.json
│   └── ultimate-agent-workflow.json  # Готовый workflow
├── openclaw/
│   ├── Dockerfile          # ✅ ИСПРАВЛЕНО: COPY ./openclaw/openclaw.json
│   └── openclaw.json      # Конфигурация OpenClaw
├── render.yaml            # Конфигурация Render Blueprint
├── deploy_to_github.ps1   # Скрипт автоматической загрузки
├── quick_deploy.ps1       # Быстрый скрипт деплоя
└── DEPLOY_INSTRUCTIONS.md # Эта инструкция
```

## 🐛 Возможные проблемы и решения

### Проблема 1: "File not found" при сборке
**Решение:** Убедитесь, что вы очистили кеш на Render ("Clear build cache & deploy")

### Проблема 2: Git ошибка "Permission denied"
**Решение:** Проверьте токен доступа GitHub или используйте SSH ключ

### Проблема 3: Docker build timeout
**Решение:** Render Free tier имеет ограничения. Убедитесь, что:
- Dockerfile оптимизированы (используют кеширование)
- Используются легковесные базовые образы (alpine)
- Убраны ненужные зависимости

### Проблема 4: Сервисы не могут подключиться друг к другу
**Решение:** На Render все сервисы в одной сети. Используйте имена сервисов:
- OpenClaw Gateway: `http://openclaw-gateway:18789`
- DuckDuckGo Proxy: `http://duckduckgo-proxy:8000`
- Backend API: `http://ultimate-agent-api:3000`

## ✅ Проверка работоспособности

После успешного деплоя:

1. **Проверьте health check:**
   - `https://ultimate-agent-api.onrender.com/health` → должно вернуть `{"status":"ok"}`

2. **Проверьте n8n:**
   - `https://n8n.onrender.com` → должна открыться страница входа

3. **Проверьте DuckDuckGo Proxy:**
   - `https://duckduckgo-proxy.onrender.com/search?q=test` → должен вернуть JSON

4. **Проверьте Telegram бота:**
   - Отправьте `/start` вашему боту → должен ответить с ссылкой на Google Sheet

## 📞 Поддержка

Если проблемы остаются:
1. Проверьте логи на Render Dashboard
2. Убедитесь, что все файлы загружены в GitHub
3. Попробуйте удалить и создать Blueprint заново

**Удачи с деплоем! 🚀**