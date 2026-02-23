# Быстрый деплой Ultimate Agent SaaS в GitHub

Write-Host "🚀 Быстрая загрузка в GitHub..." -ForegroundColor Cyan

# Устанавливаем переменные
$repoUrl = "https://github.com/Kabael/ultimate-agent.git"
$commitMsg = "Fix Dockerfile paths for Render deployment"

# Переходим в папку проекта
cd "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"

# Проверяем Git
Write-Host "🔍 Проверяем Git..." -ForegroundColor Yellow
git --version
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Git не установлен!" -ForegroundColor Red
    exit 1
}

# Инициализируем репозиторий если нужно
if (-not (Test-Path ".git")) {
    Write-Host "🔄 Инициализируем Git репозиторий..." -ForegroundColor Yellow
    git init
}

# Настраиваем удалённый репозиторий
Write-Host "🔗 Настраиваем подключение к GitHub..." -ForegroundColor Yellow
git remote remove origin 2>$null
git remote add origin $repoUrl

# Создаем .gitignore если его нет
if (-not (Test-Path ".gitignore")) {
    @"
node_modules/
.env
*.log
__pycache__/
.DS_Store
"@ | Out-File ".gitignore" -Encoding UTF8
}

# Добавляем и коммитим
Write-Host "💾 Добавляем файлы..." -ForegroundColor Yellow
git add .

Write-Host "📝 Создаём коммит..." -ForegroundColor Yellow
git commit -m $commitMsg

# Пушим
Write-Host "🚀 Отправляем в GitHub..." -ForegroundColor Cyan
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ УСПЕХ! Файлы загружены!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Дальнейшие действия:" -ForegroundColor Cyan
    Write-Host "1. Откройте https://dashboard.render.com" -ForegroundColor Yellow
    Write-Host "2. Нажмите 'Manual Deploy' → 'Clear build cache & deploy'" -ForegroundColor Yellow
    Write-Host "3. Дождитесь завершения сборки" -ForegroundColor Yellow
} else {
    Write-Host "❌ Ошибка при отправке" -ForegroundColor Red
    Write-Host "Попробуйте: git push -u origin main" -ForegroundColor Yellow
}