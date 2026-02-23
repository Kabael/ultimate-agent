# OpenClaw Gateway для Ultimate Agent SaaS
FROM node:18-alpine

WORKDIR /app

# Установка зависимостей
RUN apk add --no-cache git python3 make g++

# Установка OpenClaw с явным указанием версии и флагами
RUN npm install -g openclaw@latest --unsafe-perm=true --allow-root

# Создание директории конфигурации
RUN mkdir -p /root/.openclaw

# Копирование конфигурации
COPY ./openclaw.json /root/.openclaw/openclaw.json

# Открытие порта
EXPOSE 18789

# Запуск OpenClaw Gateway
CMD ["openclaw", "gateway", "start", "--port", "18789", "--host", "0.0.0.0"]