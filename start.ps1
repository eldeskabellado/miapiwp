# ============================================================================
# Script de Inicio Rápido - WhatsApp API
# Para Windows PowerShell
# ============================================================================

Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  WhatsApp API - Script de Inicio Rápido                 ║" -ForegroundColor Cyan
Write-Host "║  Backend Node.js con Baileys                            ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Función para verificar si un comando existe
function Test-Command {
    param($Command)
    try {
        if (Get-Command $Command -ErrorAction Stop) {
            return $true
        }
    }
    catch {
        return $false
    }
}

# Verificar Node.js
Write-Host "🔍 Verificando requisitos..." -ForegroundColor Yellow
if (-not (Test-Command "node")) {
    Write-Host "❌ Node.js no está instalado" -ForegroundColor Red
    Write-Host "   Descarga desde: https://nodejs.org" -ForegroundColor Yellow
    exit 1
}

$nodeVersion = node --version
Write-Host "✅ Node.js $nodeVersion instalado" -ForegroundColor Green

# Verificar pnpm
if (-not (Test-Command "pnpm")) {
    Write-Host "⚠️  pnpm no está instalado. Instalando..." -ForegroundColor Yellow
    npm install -g pnpm
}

$pnpmVersion = pnpm --version
Write-Host "✅ pnpm $pnpmVersion instalado" -ForegroundColor Green

Write-Host ""

# Verificar si existe .env
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creando archivo .env desde .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
    Write-Host "✅ Archivo .env creado" -ForegroundColor Green
    Write-Host "⚠️  IMPORTANTE: Edita .env y configura tus variables" -ForegroundColor Yellow
    Write-Host ""
    
    $edit = Read-Host "¿Quieres editar .env ahora? (S/N)"
    if ($edit -eq "S" -or $edit -eq "s") {
        notepad .env
        Write-Host "✅ Presiona Enter cuando termines de editar..." -ForegroundColor Yellow
        Read-Host
    }
}
else {
    Write-Host "✅ Archivo .env ya existe" -ForegroundColor Green
}

Write-Host ""

# Verificar carpeta auth_info
if (Test-Path "auth_info") {
    Write-Host "⚠️  Carpeta auth_info existe (sesión anterior)" -ForegroundColor Yellow
    $delete = Read-Host "¿Quieres eliminarla y generar nuevo QR? (S/N)"
    if ($delete -eq "S" -or $delete -eq "s") {
        Remove-Item -Path "auth_info" -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "✅ Sesión anterior eliminada" -ForegroundColor Green
    }
}

Write-Host ""

# Instalar dependencias
Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
pnpm install

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al instalar dependencias" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Dependencias instaladas" -ForegroundColor Green
Write-Host ""

# Menú de opciones
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Opciones de Inicio                                      ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Iniciar servidor (desarrollo)" -ForegroundColor White
Write-Host "2. Iniciar con Docker Compose" -ForegroundColor White
Write-Host "3. Ver documentación" -ForegroundColor White
Write-Host "4. Salir" -ForegroundColor White
Write-Host ""

$option = Read-Host "Selecciona una opción (1-4)"

switch ($option) {
    "1" {
        Write-Host ""
        Write-Host "🚀 Iniciando servidor..." -ForegroundColor Green
        Write-Host ""
        Write-Host "📋 Endpoints disponibles:" -ForegroundColor Yellow
        Write-Host "   GET  http://localhost:3000/session/qr" -ForegroundColor White
        Write-Host "   GET  http://localhost:3000/session/status" -ForegroundColor White
        Write-Host "   POST http://localhost:3000/session/reset" -ForegroundColor White
        Write-Host ""
        Write-Host "💡 Tip: Espera 15 segundos y luego accede a /session/qr" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Presiona Ctrl+C para detener el servidor" -ForegroundColor Yellow
        Write-Host ""
        
        Start-Sleep -Seconds 2
        pnpm start
    }
    
    "2" {
        if (-not (Test-Command "docker")) {
            Write-Host "❌ Docker no está instalado" -ForegroundColor Red
            Write-Host "   Descarga desde: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
            exit 1
        }
        
        Write-Host ""
        Write-Host "🐳 Iniciando con Docker Compose..." -ForegroundColor Green
        Write-Host ""
        
        docker-compose up -d
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host ""
            Write-Host "✅ Servicios iniciados correctamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "📋 Comandos útiles:" -ForegroundColor Yellow
            Write-Host "   Ver logs:      docker-compose logs -f whatsapp-api" -ForegroundColor White
            Write-Host "   Ver estado:    docker-compose ps" -ForegroundColor White
            Write-Host "   Detener:       docker-compose down" -ForegroundColor White
            Write-Host "   Reiniciar:     docker-compose restart whatsapp-api" -ForegroundColor White
            Write-Host ""
            Write-Host "🌐 API disponible en: http://localhost:3000" -ForegroundColor Cyan
        }
        else {
            Write-Host "❌ Error al iniciar Docker Compose" -ForegroundColor Red
        }
    }
    
    "3" {
        Write-Host ""
        Write-Host "📚 Documentación disponible:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "   README.md           - Documentación principal" -ForegroundColor White
        Write-Host "   RESUMEN.md          - Resumen ejecutivo" -ForegroundColor White
        Write-Host "   DOKPLOY.md          - Deployment con Dokploy" -ForegroundColor White
        Write-Host "   DEPLOYMENT.md       - Guía de deployment" -ForegroundColor White
        Write-Host "   PORTS.md            - Configuración de puertos" -ForegroundColor White
        Write-Host "   TROUBLESHOOTING.md  - Solución de problemas" -ForegroundColor White
        Write-Host ""
        
        $doc = Read-Host "¿Qué archivo quieres abrir? (README/RESUMEN/DOKPLOY/etc)"
        if ($doc) {
            $file = "$doc.md"
            if (Test-Path $file) {
                notepad $file
            }
            else {
                Write-Host "❌ Archivo no encontrado: $file" -ForegroundColor Red
            }
        }
    }
    
    "4" {
        Write-Host ""
        Write-Host "👋 ¡Hasta luego!" -ForegroundColor Cyan
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "❌ Opción inválida" -ForegroundColor Red
        exit 1
    }
}
