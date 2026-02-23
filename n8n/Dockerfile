FROM n8nio/n8n:latest

WORKDIR /data

# Установка community nodes
RUN npm install n8n-nodes-openclaw

# Копирование workflow (файл должен лежать в папке n8n и называться именно так)
COPY ultimate-agent-workflow.json /data/

# Явно указываем слушать все интерфейсы (на всякий случай)
ENV N8N_LISTEN_ADDRESS=0.0.0.0

# Открываем порт
EXPOSE 5678

# Запуск n8n (используем полный путь к бинарнику, чтобы избежать ошибок PATH)
CMD ["/usr/local/bin/n8n", "start"]
