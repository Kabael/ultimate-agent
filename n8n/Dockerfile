# Используем официальный образ n8n
FROM n8nio/n8n:latest

WORKDIR /data

# Устанавливаем community nodes
RUN npm install n8n-nodes-openclaw

# Копируем workflow (файл должен быть в папке n8n)
COPY ultimate-agent-workflow.json /data/

# Явно указываем слушать все интерфейсы
ENV N8N_LISTEN_ADDRESS=0.0.0.0
ENV PORT=5678

# Открываем порт
EXPOSE 5678

# Запускаем n8n (используем полный путь, чтобы избежать проблем с PATH)
CMD ["/usr/local/bin/n8n", "start"]
