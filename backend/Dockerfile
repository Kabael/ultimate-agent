FROM node:18-alpine

# Устанавливаем git и build tools (необходимо для некоторых npm-пакетов)
RUN apk add --no-cache git python3 make g++

WORKDIR /app

# Устанавливаем OpenClaw глобально
RUN npm install -g openclaw@latest --unsafe-perm=true --allow-root

# Создаём папку для конфига
RUN mkdir -p /root/.openclaw

# Копируем конфиг (обрати внимание — путь без "./")
COPY openclaw.json /root/.openclaw/openclaw.json

EXPOSE 18789

CMD ["openclaw", "gateway", "start"]
