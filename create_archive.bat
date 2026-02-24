@echo off
echo Создание исправленного архива Ultimate Agent SaaS v3...
echo.

REM Создаём временную директорию
set temp_dir=C:\Users\Kazra\.openclaw\workspace\temp_ultimate_saas_v3
if exist "%temp_dir%" rmdir /s /q "%temp_dir%"
mkdir "%temp_dir%"

echo Копирование файлов...

REM Основные файлы
copy "README.md" "%temp_dir%\" >nul
copy "render.yaml" "%temp_dir%\" >nul
copy "DEPLOYMENT_GUIDE.md" "%temp_dir%\" >nul

REM Папки
mkdir "%temp_dir%\backend"
xcopy "backend\*" "%temp_dir%\backend\" /E /I /Y >nul

mkdir "%temp_dir%\openclaw"
xcopy "openclaw\*" "%temp_dir%\openclaw\" /E /I /Y >nul

mkdir "%temp_dir%\n8n"
xcopy "n8n\*" "%temp_dir%\n8n\" /E /I /Y >nul

mkdir "%temp_dir%\ddg-proxy"
xcopy "ddg-proxy\*" "%temp_dir%\ddg-proxy\" /E /I /Y >nul

echo Файлы скопированы.

REM Создаём архив с помощью PowerShell
powershell -Command "Compress-Archive -Path '%temp_dir%\*' -DestinationPath 'ultimate-agent-saas-fixed-v3.zip' -Force"

REM Очистка
rmdir /s /q "%temp_dir%"

echo.
echo ✅ Архив создан: ultimate-agent-saas-fixed-v3.zip
echo.
echo === ИНСТРУКЦИЯ ===
echo 1. Загрузите этот архив в Render.com:
echo    - Откройте https://dashboard.render.com
echo    - Нажмите 'New +' -> 'Blueprint'
echo    - Загрузите архив 'ultimate-agent-saas-fixed-v3.zip'
echo.
echo 2. Настройте переменные окружения:
echo    - DEEPSEEK_API_KEY для openclaw-gateway
echo    - TELEGRAM_BOT_TOKEN для ultimate-agent-api
echo    - GOOGLE_SHEETS_API_KEY для ultimate-agent-api
echo.
echo 3. Запустите деплой!
echo.
pause