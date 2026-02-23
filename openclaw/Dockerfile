FROM node:18-alpine

# Устанавливаем git и build tools (необходимо для некоторых npm-пакетов)
RUN apk add --no-cache git python3 make g++

WORKDIR /app

# Устанавливаем OpenClaw глобально
RUN npm install -g openclaw@latest --unsafe-perm=true --allow-root

# Создаём папку для конфига
RUN mkdir -p /root/.openclaw

# Копируем конфиг (ПРАВИЛЬНЫЙ ПУТЬ: просто имя файла, без ./)
COPY openclaw.json /root/.openclaw/openclaw.json

# Открываем порт, который будет слушать OpenClaw (18789)
EXPOSE 18789

# Запуск
CMD ["openclaw", "gateway", "start"]
