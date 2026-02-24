# Создание исправленного архива для Render.com
Write-Host "Создание исправленного архива Ultimate Agent SaaS v3..." -ForegroundColor Cyan

# Создаём временную директорию
$tempDir = "C:\Users\Kazra\.openclaw\workspace\temp_ultimate_saas_v3"
if (Test-Path $tempDir) {
    Remove-Item -Path $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Копируем только нужные файлы
Write-Host "Копирование файлов..." -ForegroundColor Yellow

# Основные файлы
Copy-Item -Path ".\README.md" -Destination "$tempDir\" -Force
Copy-Item -Path ".\render.yaml" -Destination "$tempDir\" -Force
Copy-Item -Path ".\DEPLOYMENT_GUIDE.md" -Destination "$tempDir\" -Force

# Папки
$folders = @("backend", "openclaw", "n8n", "ddg-proxy")
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        Copy-Item -Path "$folder\*" -Destination "$tempDir\$folder\" -Recurse -Force
        Write-Host "  ✓ $folder" -ForegroundColor Green
    }
}

# Удаляем ненужные файлы
$excludeFiles = @("*.bat", "*.ps1", "*.zip", "check-*", "deploy-*", "quick_*", "FIX_*", "PRODUCT_*", "README_*", "DEPLOY_*")
foreach ($pattern in $excludeFiles) {
    Get-ChildItem -Path $tempDir -Filter $pattern -Recurse | Remove-Item -Force
}

# Создаём архив
$archivePath = ".\ultimate-agent-saas-fixed-v3.zip"
if (Test-Path $archivePath) {
    Remove-Item -Path $archivePath -Force
}

Write-Host "Создание архива..." -ForegroundColor Yellow
Compress-Archive -Path "$tempDir\*" -DestinationPath $archivePath -Force

# Очистка
Remove-Item -Path $tempDir -Recurse -Force

Write-Host "`n✅ Архив создан: $archivePath" -ForegroundColor Green
Write-Host "Размер: $([math]::Round((Get-Item $archivePath).Length / 1KB, 2)) KB" -ForegroundColor Cyan

Write-Host "`n=== ИНСТРУКЦИЯ ===" -ForegroundColor Magenta
Write-Host "1. Загрузите этот архив в Render.com:" -ForegroundColor White
Write-Host "   - Откройте https://dashboard.render.com" -ForegroundColor White
Write-Host "   - Нажмите 'New +' → 'Blueprint'" -ForegroundColor White
Write-Host "   - Загрузите архив '$archivePath'" -ForegroundColor White
Write-Host "2. Настройте переменные окружения:" -ForegroundColor White
Write-Host "   - DEEPSEEK_API_KEY для openclaw-gateway" -ForegroundColor White
Write-Host "   - TELEGRAM_BOT_TOKEN для ultimate-agent-api" -ForegroundColor White
Write-Host "   - GOOGLE_SHEETS_API_KEY для ultimate-agent-api" -ForegroundColor White
Write-Host "3. Запустите деплой!" -ForegroundColor White