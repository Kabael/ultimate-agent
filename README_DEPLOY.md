# Ultimate Agent SaaS - Инструкция по развёртыванию

## 🚀 Быстрый старт

### Шаг 1: Загрузите архив на Render.com
1. Перейдите на [Render.com](https://render.com)
2. Нажмите "New +" → "Blueprint"
3. Выберите "Manual Deploy" → "Upload ZIP"
4. Загрузите файл: `ultimate-agent-saas-fixed-v2.zip`
5. Нажмите "Apply"

### Шаг 2: Настройте переменные окружения
После загрузки Blueprint, добавьте следующие переменные:

**Обязательные:**
```
TELEGRAM_BOT_TOKEN=ваш_токен_бота_telegram
GOOGLE_SHEETS_API_KEY=ваш_ключ_google_sheets
DEEPSEEK_API_KEY=sk-a5f795364f2c4b04b01f9f2909d516e2
```

**Опциональные:**
```
BRAVE_API_KEY=ваш_ключ_brave_search (если нужен поиск)
NODE_ENV=production
```

### Шаг 3: Запустите деплой
1. Нажмите "Create Blueprint"
2. Дождитесь завершения сборки (5-10 минут)
3. Все сервисы запустятся автоматически

## 📦 Структура сервисов

Blueprint создаст 5 сервисов:

1. **ultimate-agent-api** (Backend) - порт 3000
2. **openclaw-gateway** (OpenClaw Gateway) - порт 18789
3. **n8n** (Автоматизация) - порт 5678
4. **ddg-proxy** (DuckDuckGo поиск) - порт 8000
5. **postgres** (База данных) - порт 5432

## 🔧 Проверка работоспособности

После деплоя проверьте:

1. **API**: `https://ultimate-agent-api.onrender.com/health`
2. **n8n**: `https://n8n.onrender.com` (логин: admin@example.com, пароль: password)
3. **OpenClaw Gateway**: `https://openclaw-gateway.onrender.com/status`

## 🤖 Настройка Telegram бота

1. Создайте бота через [@BotFather](https://t.me/BotFather)
2. Получите токен
3. Добавьте токен в переменные окружения
4. Бот автоматически начнёт принимать команды

## 📊 Настройка Google Sheets API

1. Перейдите в [Google Cloud Console](https://console.cloud.google.com)
2. Создайте новый проект
3. Включите Google Sheets API
4. Создайте ключ API
5. Добавьте ключ в переменные окружения

## 🎯 Использование

### Через веб-интерфейс:
1. Откройте: `https://ultimate-agent-api.onrender.com/launch.html`
2. Введите артикулы товаров
3. Нажмите "Запустить платформу"

### Через Telegram:
1. Найдите вашего бота в Telegram
2. Отправьте `/start`
3. Укажите артикулы командой `/articles 123456, 789012`

## 🐛 Устранение неполадок

### Ошибка "npm install -g openclaw@latest"
✅ **Исправлено в v2**: Добавлены зависимости git, python3, make, g++

### Ошибка "Command 'n8n' not found"
✅ **Исправлено в v2**: Используется `npx n8n start` вместо `n8n start`

### Ошибка подключения к базе данных
- Проверьте, что PostgreSQL сервис запущен
- Убедитесь, что DATABASE_URL корректно настроен

### Ошибка "No encryption key found" в n8n
✅ **Исправлено в v2**: Добавлена переменная N8N_ENCRYPTION_KEY

## 📁 Файлы проекта

```
ultimate-agent-saas/
├── render.yaml              # Blueprint для Render.com
├── backend/                 # Node.js API
│   ├── Dockerfile
│   ├── package.json
│   ├── server.js
│   └── public/launch.html
├── openclaw/               # OpenClaw Gateway
│   ├── Dockerfile
│   └── openclaw.json
├── n8n/                    # n8n автоматизация
│   ├── Dockerfile
│   └── ultimate-agent-workflow.json
├── ddg-proxy/             # DuckDuckGo прокси
│   ├── Dockerfile
│   └── ddg_proxy.py
└── README.md              # Основная документация
```

## 🔄 Обновление

Для обновления:
1. Внесите изменения в файлы
2. Создайте новый архив: `Compress-Archive -Path * -DestinationPath ultimate-agent-saas-v3.zip`
3. Загрузите на Render.com через Manual Deploy

## 📞 Поддержка

При возникновении проблем:
1. Проверьте логи в Render Dashboard
2. Убедитесь, что все переменные окружения установлены
3. Проверьте доступность внешних API (Telegram, Google Sheets)

---

**Удачи с вашим Ultimate Agent SaaS!** 🚀