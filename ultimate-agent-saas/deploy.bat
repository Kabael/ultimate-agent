@echo off
echo ========================================
echo  Ultimate Agent SaaS - Деплой в GitHub
echo ========================================
echo.

echo [1] Проверяем Git...
git --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Git не установлен!
    echo Скачайте с: https://git-scm.com/download/win
    pause
    exit /b 1
)

echo ✅ Git установлен
echo.

echo [2] Переходим в папку проекта...
cd /d "C:\Users\Kazra\.openclaw\workspace\products\ultimate-agent-saas"
echo ✅ Текущая папка: %cd%
echo.

echo [3] Запускаем PowerShell скрипт...
echo.
powershell -ExecutionPolicy Bypass -File "quick_deploy.ps1"
echo.

echo [4] Готово!
echo.
echo 📋 Дальнейшие действия:
echo 1. Откройте https://dashboard.render.com
echo 2. Нажмите 'Manual Deploy'
echo 3. Выберите 'Clear build cache & deploy'
echo 4. Дождитесь завершения
echo.
pause