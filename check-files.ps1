# Скрипт проверки файлов для Ultimate Agent SaaS
Write-Host "=== ПРОВЕРКА ФАЙЛОВ ULTIMATE AGENT SAAS ===" -ForegroundColor Cyan

# Проверка структуры
Write-Host "`n1. Структура папок:" -ForegroundColor Yellow
Get-ChildItem -Recurse -Directory | Select-Object FullName | Format-Table -AutoSize

Write-Host "`n2. Ключевые файлы:" -ForegroundColor Yellow
$criticalFiles = @(
    "render.yaml",
    "backend\package.json",
    "backend\server.js",
    "backend\launch.html",
    "openclaw\Dockerfile",
    "openclaw\openclaw.json",
    "n8n\Dockerfile",
    "n8n\ultimate-agent-workflow.json",
    "ddg-proxy\Dockerfile",
    "ddg-proxy\ddg_proxy.py"
)

foreach ($file in $criticalFiles) {
    $fullPath = Join-Path $PSScriptRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file (ОТСУТСТВУЕТ!)" -ForegroundColor Red
    }
}

# Проверка Dockerfile
Write-Host "`n3. Проверка Dockerfile:" -ForegroundColor Yellow

# OpenClaw Dockerfile
$openclawDocker = Get-Content "openclaw\Dockerfile" -Raw
if ($openclawDocker -match "COPY.*openclaw/openclaw.json") {
    Write-Host "  ❌ OpenClaw Dockerfile: НЕПРАВИЛЬНЫЙ COPY путь" -ForegroundColor Red
} else {
    Write-Host "  ✅ OpenClaw Dockerfile: OK" -ForegroundColor Green
}

# n8n Dockerfile
$n8nDocker = Get-Content "n8n\Dockerfile" -Raw
if ($n8nDocker -match "COPY.*n8n/ultimate-agent-workflow.json") {
    Write-Host "  ❌ n8n Dockerfile: НЕПРАВИЛЬНЫЙ COPY путь" -ForegroundColor Red
} else {
    Write-Host "  ✅ n8n Dockerfile: OK" -ForegroundColor Green
}

# Проверка render.yaml
Write-Host "`n4. Проверка render.yaml:" -ForegroundColor Yellow
$renderYaml = Get-Content "render.yaml" -Raw
if ($renderYaml -match "dockerfilePath:.*openclaw/Dockerfile") {
    Write-Host "  ✅ render.yaml: OpenClaw путь правильный" -ForegroundColor Green
}
if ($renderYaml -match "dockerfilePath:.*n8n/Dockerfile") {
    Write-Host "  ✅ render.yaml: n8n путь правильный" -ForegroundColor Green
}

Write-Host "`n=== ПРОВЕРКА ЗАВЕРШЕНА ===" -ForegroundColor Cyan
Write-Host "`nСоздание архива..." -ForegroundColor Yellow
Compress-Archive -Path * -DestinationPath "ultimate-agent-saas-fixed.zip" -Force
Write-Host "✅ Архив создан: ultimate-agent-saas-fixed.zip" -ForegroundColor Green