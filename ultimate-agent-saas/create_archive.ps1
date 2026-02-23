# Скрипт для создания архива Ultimate Agent SaaS
# Запуск: PowerShell -ExecutionPolicy Bypass -File create_archive.ps1

Write-Host "🚀 Создание архива Ultimate Agent SaaS..." -ForegroundColor Green

# Проверка структуры
$requiredFiles = @(
    "render.yaml",
    "README.md",
    "DEPLOYMENT_GUIDE.md",
    "launch.html",
    "backend\package.json",
    "backend\server.js",
    "openclaw\Dockerfile",
    "openclaw\openclaw.json",
    "n8n\Dockerfile",
    "n8n\ultimate-agent-workflow.json",
    "ddg-proxy\Dockerfile",
    "ddg-proxy\ddg_proxy.py"
)

Write-Host "📁 Проверка файлов..." -ForegroundColor Cyan
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file - НЕ НАЙДЕН!" -ForegroundColor Red
        exit 1
    }
}

# Создание архива
$archiveName = "ultimate-agent-saas.zip"
$sourceFolder = "."

Write-Host "📦 Создание архива $archiveName..." -ForegroundColor Cyan

try {
    # Удаляем старый архив если есть
    if (Test-Path $archiveName) {
        Remove-Item $archiveName -Force
    }
    
    # Создаём архив
    Compress-Archive -Path @(
        "render.yaml",
        "README.md",
        "DEPLOYMENT_GUIDE.md",
        "launch.html",
        "backend",
        "openclaw",
        "n8n",
        "ddg-proxy"
    ) -DestinationPath $archiveName -CompressionLevel Optimal
    
    # Проверяем размер
    $archiveSize = (Get-Item $archiveName).Length / 1MB
    $archiveSizeFormatted = "{0:N2}" -f $archiveSize
    
    Write-Host "🎉 Архив создан успешно!" -ForegroundColor Green
    Write-Host "📊 Размер: $archiveSizeFormatted MB" -ForegroundColor Yellow
    Write-Host "📁 Файл: $(Resolve-Path $archiveName)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Содержимое архива:" -ForegroundColor Cyan
    Write-Host "├── render.yaml - Конфигурация Render.com" -ForegroundColor Gray
    Write-Host "├── README.md - Основная документация" -ForegroundColor Gray
    Write-Host "├── DEPLOYMENT_GUIDE.md - Пошаговая инструкция" -ForegroundColor Gray
    Write-Host "├── launch.html - Страница запуска для клиентов" -ForegroundColor Gray
    Write-Host "├── backend/ - Node.js API сервер" -ForegroundColor Gray
    Write-Host "├── openclaw/ - OpenClaw Gateway" -ForegroundColor Gray
    Write-Host "├── n8n/ - n8n с workflow" -ForegroundColor Gray
    Write-Host "└── ddg-proxy/ - DuckDuckGo поиск" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🚀 Что делать дальше:" -ForegroundColor Green
    Write-Host "1. Загрузите архив на Render.com через Blueprint" -ForegroundColor Yellow
    Write-Host "2. Создайте Telegram бота через @BotFather" -ForegroundColor Yellow
    Write-Host "3. Получите Google Sheets API ключ" -ForegroundColor Yellow
    Write-Host "4. Настройте переменные окружения в Render" -ForegroundColor Yellow
    Write-Host "5. Запустите launch.html для клиентов" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📚 Подробная инструкция в DEPLOYMENT_GUIDE.md" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Ошибка создания архива: $_" -ForegroundColor Red
    exit 1
}