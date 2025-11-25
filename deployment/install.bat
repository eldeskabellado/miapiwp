@echo off
REM ============================================================================
REM Script de Instalacion Automatica - WhatsApp Client
REM Compatible con Windows 7/8/10/11
REM ============================================================================

setlocal EnableDelayedExpansion

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                                                                       ║
echo ║          WhatsApp Client - Instalacion Automatica                    ║
echo ║          Delphi Rio + Node.js + Baileys                              ║
echo ║                                                                       ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.

REM Verificar si Node.js esta instalado
echo [1/5] Verificando Node.js...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Node.js no esta instalado.
    echo.
    echo Por favor instala Node.js desde: https://nodejs.org/
    echo Recomendado: Version LTS (v18 o superior^)
    echo.
    pause
    exit /b 1
)

echo [OK] Node.js instalado
node --version
npm --version

REM Crear directorio del proyecto
echo.
echo [2/5] Creando estructura de directorios...
set PROJECT_DIR=%cd%\whatsapp-api
if not exist "%PROJECT_DIR%" mkdir "%PROJECT_DIR%"
echo [OK] Directorio creado: %PROJECT_DIR%

REM Verificar archivos necesarios
echo.
echo [3/5] Verificando archivos del proyecto...
if not exist "baileys-server.js" (
    echo [ERROR] Archivo baileys-server.js no encontrado
    echo Por favor asegurate de ejecutar este script en la carpeta correcta
    pause
    exit /b 1
)
if not exist "package.json" (
    echo [ERROR] Archivo package.json no encontrado
    pause
    exit /b 1
)
echo [OK] Archivos encontrados

REM Copiar archivos
echo.
echo [4/5] Copiando archivos al proyecto...
copy /Y baileys-server.js "%PROJECT_DIR%\" >nul
copy /Y package.json "%PROJECT_DIR%\" >nul
echo [OK] Archivos copiados

REM Instalar dependencias
echo.
echo [5/5] Instalando dependencias de Node.js...
echo Esto puede tomar varios minutos...
echo.
cd "%PROJECT_DIR%"
call npm install

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Fallo la instalacion de dependencias
    echo Intenta manualmente: cd whatsapp-api ^& npm install
    pause
    exit /b 1
)

echo.
echo ╔═══════════════════════════════════════════════════════════════════════╗
echo ║                                                                       ║
echo ║                    ¡INSTALACION COMPLETADA!                          ║
echo ║                                                                       ║
echo ╚═══════════════════════════════════════════════════════════════════════╝
echo.
echo Servidor instalado en: %PROJECT_DIR%
echo.
echo PROXIMOS PASOS:
echo.
echo 1. Iniciar el servidor:
echo    cd whatsapp-api
echo    npm start
echo.
echo 2. Abrir Delphi y compilar WhatsAppClientApp.dpr
echo.
echo 3. Ejecutar la aplicacion Delphi
echo.
echo 4. Hacer click en "Obtener Codigo QR"
echo.
echo 5. Escanear con WhatsApp movil
echo.
echo ¿Deseas iniciar el servidor ahora? (S/N)
set /p RESPUESTA=
if /i "%RESPUESTA%"=="S" (
    echo.
    echo Iniciando servidor...
    echo Presiona Ctrl+C para detener
    echo.
    call npm start
) else (
    echo.
    echo Para iniciar el servidor mas tarde:
    echo cd %PROJECT_DIR%
    echo npm start
    echo.
)

pause
