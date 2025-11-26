#!/bin/bash
# ============================================================================
# Script de Deployment Simplificado - WhatsApp API
# Solo instala la aplicación (Node.js y PM2 deben estar instalados)
# ============================================================================

set -e  # Salir si hay error

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                       ║"
echo "║          WhatsApp API - Deployment Simplificado                      ║"
echo "║          (Requiere Node.js 20+ y PM2 previamente instalados)         ║"
echo "║                                                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Verificar si se está ejecutando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}[ERROR]${NC} Este script debe ejecutarse como root (sudo)"
    exit 1
fi

echo -e "${BLUE}[INFO]${NC} Iniciando deployment simplificado..."

# ============================================================================
# 1. VERIFICAR REQUISITOS
# ============================================================================
echo ""
echo -e "${YELLOW}[1/5]${NC} Verificando requisitos..."

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Node.js no está instalado"
    echo -e "${YELLOW}[INFO]${NC} Por favor instala Node.js 20+ primero"
    exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 20 ]; then
    echo -e "${RED}[ERROR]${NC} Node.js v$NODE_VERSION detectado. Se requiere v20 o superior"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} Node.js $(node --version) instalado"

# Verificar pnpm
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} pnpm no está instalado"
    echo -e "${YELLOW}[INFO]${NC} Ejecuta: corepack enable && corepack prepare pnpm@latest --activate"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} pnpm $(pnpm --version) instalado"

# Verificar PM2
if ! command -v pm2 &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} PM2 no está instalado"
    echo -e "${YELLOW}[INFO]${NC} Ejecuta: npm install -g pm2"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} PM2 $(pm2 --version) instalado"

# ============================================================================
# 2. CONFIGURACIÓN
# ============================================================================
echo ""
echo -e "${YELLOW}[2/5]${NC} Configuración del deployment..."

# Solicitar directorio de instalación
echo ""
read -p "Directorio de instalación [/opt/whatsapp-api]: " APP_DIR
APP_DIR=${APP_DIR:-/opt/whatsapp-api}

# Solicitar nombre de la aplicación PM2
echo ""
read -p "Nombre de la aplicación PM2 [whatsapp-api]: " PM2_APP_NAME
PM2_APP_NAME=${PM2_APP_NAME:-whatsapp-api}

# Solicitar puerto
echo ""
read -p "Puerto de la aplicación [3000]: " APP_PORT
APP_PORT=${APP_PORT:-3000}

# Confirmar
echo ""
echo -e "${BLUE}[RESUMEN]${NC}"
echo -e "  Directorio: ${YELLOW}$APP_DIR${NC}"
echo -e "  Nombre PM2: ${YELLOW}$PM2_APP_NAME${NC}"
echo -e "  Puerto:     ${YELLOW}$APP_PORT${NC}"
echo ""
read -p "¿Continuar? (s/n): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}[INFO]${NC} Deployment cancelado"
    exit 0
fi

# ============================================================================
# 3. PREPARAR DIRECTORIO
# ============================================================================
echo ""
echo -e "${YELLOW}[3/5]${NC} Preparando directorio de instalación..."

# Crear directorio si no existe
if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
    echo -e "${GREEN}[OK]${NC} Directorio $APP_DIR creado"
else
    echo -e "${YELLOW}[WARNING]${NC} El directorio $APP_DIR ya existe"
    read -p "¿Sobrescribir archivos? (s/n): " OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Ss]$ ]]; then
        echo -e "${YELLOW}[INFO]${NC} Deployment cancelado"
        exit 0
    fi
fi

# Solicitar archivos
echo ""
echo -e "${BLUE}[INFO]${NC} ¿Dónde están los archivos del proyecto?"
echo "1) En el directorio actual"
echo "2) Clonar desde Git"
read -p "Selecciona opción (1 o 2): " SOURCE_OPTION

if [ "$SOURCE_OPTION" == "1" ]; then
    # Copiar desde directorio actual
    if [ -f "./baileys-server.js" ] && [ -f "./package.json" ]; then
        echo -e "${BLUE}[INFO]${NC} Copiando archivos..."
        cp -r ./* "$APP_DIR/"
        echo -e "${GREEN}[OK]${NC} Archivos copiados"
    else
        echo -e "${RED}[ERROR]${NC} Archivos no encontrados en el directorio actual"
        exit 1
    fi
elif [ "$SOURCE_OPTION" == "2" ]; then
    # Clonar desde Git
    read -p "URL del repositorio Git: " GIT_URL
    
    if [ ! command -v git &> /dev/null ]; then
        echo -e "${YELLOW}[INFO]${NC} Instalando Git..."
        apt install -y git
    fi
    
    # Si el directorio existe y no está vacío, limpiarlo
    if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
        rm -rf "$APP_DIR"/*
    fi
    
    echo -e "${BLUE}[INFO]${NC} Clonando repositorio..."
    git clone "$GIT_URL" "$APP_DIR"
    echo -e "${GREEN}[OK]${NC} Repositorio clonado"
else
    echo -e "${RED}[ERROR]${NC} Opción inválida"
    exit 1
fi

# Eliminar sesión anterior de WhatsApp (para empezar limpio)
if [ -d "$APP_DIR/auth_info" ]; then
    echo -e "${YELLOW}[INFO]${NC} Eliminando sesión anterior de WhatsApp..."
    rm -rf "$APP_DIR/auth_info"
    echo -e "${GREEN}[OK]${NC} Sesión anterior eliminada"
fi

# ============================================================================
# 4. INSTALAR DEPENDENCIAS
# ============================================================================
echo ""
echo -e "${YELLOW}[4/5]${NC} Instalando dependencias..."

cd "$APP_DIR"

# Verificar lockfile
if [ -f "pnpm-lock.yaml" ]; then
    echo -e "${BLUE}[INFO]${NC} Usando pnpm"
    pnpm install --frozen-lockfile
elif [ -f "package-lock.json" ]; then
    echo -e "${BLUE}[INFO]${NC} Usando npm"
    npm ci
else
    echo -e "${BLUE}[INFO]${NC} Instalando con pnpm"
    pnpm install
fi

echo -e "${GREEN}[OK]${NC} Dependencias instaladas"

# Crear directorios necesarios
mkdir -p logs
mkdir -p auth_info

# Configurar .env
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        # Actualizar puerto en .env
        sed -i "s/PORT=.*/PORT=$APP_PORT/" .env
        echo -e "${GREEN}[OK]${NC} Archivo .env creado"
        echo -e "${YELLOW}[IMPORTANTE]${NC} Edita $APP_DIR/.env con tus valores"
    fi
fi

# ============================================================================
# 5. CONFIGURAR PM2
# ============================================================================
echo ""
echo -e "${YELLOW}[5/5]${NC} Configurando PM2..."

# Crear ecosystem.config.cjs personalizado
cat > "$APP_DIR/ecosystem.config.cjs" << EOF
module.exports = {
  apps: [{
    name: '$PM2_APP_NAME',
    script: './baileys-server.js',
    cwd: '$APP_DIR',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: $APP_PORT
    },
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    max_restarts: 10,
    min_uptime: '10s',
    restart_delay: 4000,
    error_file: '$APP_DIR/logs/pm2-error.log',
    out_file: '$APP_DIR/logs/pm2-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true,
    time: true,
    kill_timeout: 5000,
    listen_timeout: 10000,
    cron_restart: '0 3 * * *',
    node_args: '--max-old-space-size=1024 --experimental-global-webcrypto'
  }]
};
EOF

echo -e "${GREEN}[OK]${NC} Archivo ecosystem.config.cjs creado"

# Detener proceso anterior si existe
pm2 delete "$PM2_APP_NAME" 2>/dev/null || true

# Iniciar aplicación
echo -e "${BLUE}[INFO]${NC} Iniciando aplicación..."
pm2 start "$APP_DIR/ecosystem.config.cjs"

# Guardar configuración
pm2 save

echo -e "${GREEN}[OK]${NC} Aplicación iniciada"

# ============================================================================
# VERIFICACIÓN
# ============================================================================
echo ""
echo -e "${YELLOW}[VERIFICACIÓN]${NC} Verificando instalación..."

sleep 3

# Verificar PM2
if pm2 list | grep -q "$PM2_APP_NAME"; then
    echo -e "${GREEN}[OK]${NC} Aplicación PM2 activa"
else
    echo -e "${RED}[ERROR]${NC} Aplicación PM2 no está activa"
    exit 1
fi

# Verificar endpoint
if curl -s http://localhost:$APP_PORT/session/status > /dev/null; then
    echo -e "${GREEN}[OK]${NC} API respondiendo en puerto $APP_PORT"
else
    echo -e "${YELLOW}[WARNING]${NC} API no responde aún (puede tomar unos segundos)"
fi

# ============================================================================
# RESUMEN
# ============================================================================
echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                       ║"
echo "║                    ¡DEPLOYMENT COMPLETADO!                           ║"
echo "║                                                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""
echo -e "${GREEN}✓ Aplicación instalada en: $APP_DIR${NC}"
echo -e "${GREEN}✓ Nombre PM2: $PM2_APP_NAME${NC}"
echo -e "${GREEN}✓ Puerto: $APP_PORT${NC}"
echo -e "${GREEN}✓ Configuración guardada${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Comandos útiles:${NC}"
echo ""
echo "  Ver logs:"
echo -e "    ${YELLOW}pm2 logs $PM2_APP_NAME${NC}"
echo ""
echo "  Ver estado:"
echo -e "    ${YELLOW}pm2 status${NC}"
echo ""
echo "  Reiniciar:"
echo -e "    ${YELLOW}pm2 restart $PM2_APP_NAME${NC}"
echo ""
echo "  Detener:"
echo -e "    ${YELLOW}pm2 stop $PM2_APP_NAME${NC}"
echo ""
echo "  Eliminar:"
echo -e "    ${YELLOW}pm2 delete $PM2_APP_NAME${NC}"
echo ""
echo "  Ver código QR:"
echo -e "    ${YELLOW}curl http://localhost:$APP_PORT/session/qr${NC}"
echo ""
echo "  Resetear sesión:"
echo -e "    ${YELLOW}curl -X POST http://localhost:$APP_PORT/session/reset${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${YELLOW}[RECUERDA]${NC} Editar variables de entorno en:"
echo -e "  ${BLUE}$APP_DIR/.env${NC}"
echo ""
echo -e "${GREEN}¡Deployment completado exitosamente!${NC}"
echo ""
