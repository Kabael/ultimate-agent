# Скрипт для автоматической загрузки Ultimate Agent SaaS в GitHub
# и деплоя на Render.com

param(
    [string]$CommitMessage = "Fix Dockerfile paths for Render deployment",
    [string]$GitHubRepo = "https://github.com/Kabael/ultimate-agent.git",
    [switch]$ForceInit = $false
)

Write-Host "🚀 Ultimate Agent SaaS - Автоматический деплой" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan

# Проверяем, установлен ли Git
try {
    $gitVersion = git --version
    Write-Host "✅ Git установлен: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git не установлен!" -ForegroundColor Red
    Write-Host "Скачайте Git с https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

# Переходим в папку проекта
$ProjectPath = "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"
Set-Location $ProjectPath
Write-Host "📁 Рабочая папка: $ProjectPath" -ForegroundColor Green

# Проверяем статус Git репозитория
$gitStatus = git status --porcelain 2>$null
$isGitRepo = $?

if (-not $isGitRepo -or $ForceInit) {
    Write-Host "🔄 Инициализация нового Git репозитория..." -ForegroundColor Yellow
    
    # Удаляем старый .git если есть
    if (Test-Path ".git") {
        Remove-Item -Path ".git" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "🗑️  Удалён старый .git каталог" -ForegroundColor Yellow
    }
    
    # Инициализируем новый репозиторий
    git init
    Write-Host "✅ Git репозиторий инициализирован" -ForegroundColor Green
} else {
    Write-Host "✅ Git репозиторий уже инициализирован" -ForegroundColor Green
}

# Создаем .gitignore если его нет
$gitignoreContent = @"
# Игнорируем системные файлы
.DS_Store
Thumbs.db
*.log
*.tmp
*.temp

# Игнорируем зависимости Node.js
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Игнорируем зависимости Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
ENV/

# Игнорируем IDE файлы
.vscode/
.idea/
*.swp
*.swo

# Игнорируем конфиденциальные данные
.env
.env.local
.env.development.local
.env.test.local
.env.production.local
secrets/
keys/
*.key
*.pem

# Игнорируем сгенерированные файлы
dist/
build/
out/
.coverage
.nyc_output

# Игнорируем файлы операционной системы
.DS_Store
Desktop.ini
"@

if (-not (Test-Path ".gitignore")) {
    $gitignoreContent | Out-File -FilePath ".gitignore" -Encoding UTF8
    Write-Host "✅ Создан .gitignore файл" -ForegroundColor Green
} else {
    Write-Host "✅ .gitignore уже существует" -ForegroundColor Green
}

# Проверяем подключение к удалённому репозиторию
$remoteUrl = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0 -or -not $remoteUrl) {
    Write-Host "🔗 Настраиваем подключение к GitHub репозиторию..." -ForegroundColor Yellow
    
    # Запрашиваем URL репозитория если не указан
    if (-not $GitHubRepo) {
        $GitHubRepo = Read-Host "Введите URL вашего GitHub репозитория (например: https://github.com/username/repo.git)"
    }
    
    git remote add origin $GitHubRepo
    Write-Host "✅ Подключено к удалённому репозиторию: $GitHubRepo" -ForegroundColor Green
} else {
    Write-Host "✅ Уже подключено к удалённому репозиторию: $remoteUrl" -ForegroundColor Green
}

# Проверяем изменения
Write-Host "📊 Проверяем изменения в файлах..." -ForegroundColor Cyan
$changes = git status --porcelain
if ($changes) {
    Write-Host "📝 Найдены изменения:" -ForegroundColor Yellow
    $changes | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    
    # Добавляем все файлы
    Write-Host "➕ Добавляем файлы в индекс..." -ForegroundColor Yellow
    git add .
    
    # Коммитим изменения
    Write-Host "💾 Создаём коммит..." -ForegroundColor Yellow
    git commit -m $CommitMessage
    
    Write-Host "✅ Коммит создан: `"$CommitMessage`"" -ForegroundColor Green
} else {
    Write-Host "✅ Нет изменений для коммита" -ForegroundColor Green
}

# Пушим изменения
Write-Host "🚀 Отправляем изменения в GitHub..." -ForegroundColor Cyan
try {
    # Пробуем push с установкой upstream
    git push -u origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Изменения успешно отправлены в GitHub!" -ForegroundColor Green
    } else {
        # Если ветка main ещё не существует на удалённом репозитории
        Write-Host "🔄 Создаём ветку main на удалённом репозитории..." -ForegroundColor Yellow
        git push -u origin HEAD:main
    }
} catch {
    Write-Host "⚠️  Ошибка при отправке: $_" -ForegroundColor Red
    Write-Host "Попробуйте выполнить команду вручную: git push -u origin main" -ForegroundColor Yellow
}

# Проверяем успешность
$pushSuccess = $LASTEXITCODE -eq 0
if ($pushSuccess) {
    Write-Host ""
    Write-Host "🎉 УСПЕХ! Файлы загружены в GitHub!" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    
    # Инструкции для Render
    Write-Host ""
    Write-Host "📋 ДАЛЬНЕЙШИЕ ДЕЙСТВИЯ ДЛЯ DEPLOY НА RENDER:" -ForegroundColor Cyan
    Write-Host "1. Откройте https://dashboard.render.com" -ForegroundColor Yellow
    Write-Host "2. Нажмите 'New +' → 'Blueprint'" -ForegroundColor Yellow
    Write-Host "3. Вставьте URL вашего репозитория: $GitHubRepo" -ForegroundColor Yellow
    Write-Host "4. Нажмите 'Apply'" -ForegroundColor Yellow
    Write-Host "5. Дождитесь завершения сборки (5-10 минут)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔄 Если сборка уже была запущена ранее:" -ForegroundColor Cyan
    Write-Host "1. Откройте Blueprint на Render" -ForegroundColor Yellow
    Write-Host "2. Нажмите 'Manual Deploy'" -ForegroundColor Yellow
    Write-Host "3. Выберите 'Clear build cache & deploy'" -ForegroundColor Yellow
    Write-Host "4. Дождитесь завершения" -ForegroundColor Yellow
    
    # Показываем структуру проекта
    Write-Host ""
    Write-Host "📁 СТРУКТУРА ПРОЕКТА:" -ForegroundColor Cyan
    Get-ChildItem -Recurse -File | Select-Object -First 20 | ForEach-Object {
        Write-Host "  $($_.FullName.Replace($ProjectPath, ''))" -ForegroundColor Gray
    }
    
    # Проверяем исправленные Dockerfile
    Write-Host ""
    Write-Host "✅ ИСПРАВЛЕННЫЕ DOCKERFILE:" -ForegroundColor Green
    $dockerfiles = Get-ChildItem -Recurse -Filter "Dockerfile"
    foreach ($dockerfile in $dockerfiles) {
        Write-Host "  $($dockerfile.FullName.Replace($ProjectPath, ''))" -ForegroundColor Gray
        $content = Get-Content $dockerfile.FullName -First 3 -Tail 3
        Write-Host "    Последние строки:" -ForegroundColor DarkGray
        $content | ForEach-Object { Write-Host "      $_" -ForegroundColor DarkGray }
    }
} else {
    Write-Host ""
    Write-Host "❌ ОШИБКА ПРИ ОТПРАВКЕ В GITHUB" -ForegroundColor Red
    Write-Host "Проверьте:" -ForegroundColor Yellow
    Write-Host "1. Доступ к интернету" -ForegroundColor Yellow
    Write-Host "2. Права на запись в репозиторий" -ForegroundColor Yellow
    Write-Host "3. Токен доступа GitHub (если требуется)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✨ Скрипт завершён!" -ForegroundColor Cyan