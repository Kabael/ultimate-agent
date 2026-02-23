# n8n с готовым workflow для Ultimate Agent SaaS
FROM n8nio/n8n:latest

WORKDIR /data

# Установка community nodes
RUN npm install n8n-nodes-openclaw

# Копирование workflow
COPY ./ultimate-agent-workflow.json /data/

# Настройка переменных окружения
ENV N8N_PROTOCOL=https
ENV N8N_HOST=n8n.onrender.com
ENV WEBHOOK_URL=https://ultimate-agent-api.onrender.com
ENV EXECUTIONS_DATA_PRUNE=true
ENV EXECUTIONS_DATA_MAX_AGE=168
ENV GENERIC_TIMEZONE=Europe/Moscow
ENV N8N_USER_FOLDER=/data
ENV N8N_ENCRYPTION_KEY=ultimate-agent-saas-encryption-key-2026
# Явно указываем слушать все интерфейсы (на случай, если по умолчанию localhost)
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Открытие порта
EXPOSE 5678

# Запуск n8n (используем прямую команду, без npx)
CMD ["n8n", "start"]
