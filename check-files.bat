@echo off
echo === ПРОВЕРКА ФАЙЛОВ ULTIMATE AGENT SAAS ===

echo.
echo 1. Структура папок:
dir /b /s /ad

echo.
echo 2. Ключевые файлы:
if exist "render.yaml" (echo   ✅ render.yaml) else (echo   ❌ render.yaml (ОТСУТСТВУЕТ!))
if exist "backend\package.json" (echo   ✅ backend\package.json) else (echo   ❌ backend\package.json (ОТСУТСТВУЕТ!))
if exist "backend\server.js" (echo   ✅ backend\server.js) else (echo   ❌ backend\server.js (ОТСУТСТВУЕТ!))
if exist "backend\launch.html" (echo   ✅ backend\launch.html) else (echo   ❌ backend\launch.html (ОТСУТСТВУЕТ!))
if exist "openclaw\Dockerfile" (echo   ✅ openclaw\Dockerfile) else (echo   ❌ openclaw\Dockerfile (ОТСУТСТВУЕТ!))
if exist "openclaw\openclaw.json" (echo   ✅ openclaw\openclaw.json) else (echo   ❌ openclaw\openclaw.json (ОТСУТСТВУЕТ!))
if exist "n8n\Dockerfile" (echo   ✅ n8n\Dockerfile) else (echo   ❌ n8n\Dockerfile (ОТСУТСТВУЕТ!))
if exist "n8n\ultimate-agent-workflow.json" (echo   ✅ n8n\ultimate-agent-workflow.json) else (echo   ❌ n8n\ultimate-agent-workflow.json (ОТСУТСТВУЕТ!))
if exist "ddg-proxy\Dockerfile" (echo   ✅ ddg-proxy\Dockerfile) else (echo   ❌ ddg-proxy\Dockerfile (ОТСУТСТВУЕТ!))
if exist "ddg-proxy\ddg_proxy.py" (echo   ✅ ddg-proxy\ddg_proxy.py) else (echo   ❌ ddg-proxy\ddg_proxy.py (ОТСУТСТВУЕТ!))

echo.
echo 3. Проверка Dockerfile:
findstr /C:"COPY.*openclaw/openclaw.json" "openclaw\Dockerfile" >nul
if %errorlevel% equ 0 (echo   ❌ OpenClaw Dockerfile: НЕПРАВИЛЬНЫЙ COPY путь) else (echo   ✅ OpenClaw Dockerfile: OK)

findstr /C:"COPY.*n8n/ultimate-agent-workflow.json" "n8n\Dockerfile" >nul
if %errorlevel% equ 0 (echo   ❌ n8n Dockerfile: НЕПРАВИЛЬНЫЙ COPY путь) else (echo   ✅ n8n Dockerfile: OK)

echo.
echo 4. Проверка render.yaml:
findstr /C:"dockerfilePath:.*openclaw/Dockerfile" "render.yaml" >nul
if %errorlevel% equ 0 (echo   ✅ render.yaml: OpenClaw путь правильный) else (echo   ❌ render.yaml: OpenClaw путь неправильный)

findstr /C:"dockerfilePath:.*n8n/Dockerfile" "render.yaml" >nul
if %errorlevel% equ 0 (echo   ✅ render.yaml: n8n путь правильный) else (echo   ❌ render.yaml: n8n путь неправильный)

echo.
echo === ПРОВЕРКА ЗАВЕРШЕНА ===
echo.
echo Создание архива...
powershell -Command "Compress-Archive -Path * -DestinationPath 'ultimate-agent-saas-fixed.zip' -Force"
if exist "ultimate-agent-saas-fixed.zip" (
    echo ✅ Архив создан: ultimate-agent-saas-fixed.zip
) else (
    echo ❌ Ошибка создания архива!
)

pause