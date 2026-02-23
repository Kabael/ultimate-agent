# DuckDuckGo Proxy для Ultimate Agent SaaS
FROM python:3.11-alpine

WORKDIR /app

# Установка зависимостей
RUN pip install flask beautifulsoup4 requests

# Копирование кода
COPY ddg_proxy.py .

# Открытие порта
EXPOSE 8000

# Запуск proxy
CMD ["python", "ddg_proxy.py"]