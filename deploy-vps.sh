#!/bin/bash
# ============================================================================
# Script de Deployment Automatico para VPS Ubuntu
# WhatsApp API Server con Baileys
# ============================================================================

set -e  # Salir si hay error

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                       ║"
echo "║          WhatsApp API - Deployment Automatico para VPS               ║"
echo "║          Ubuntu 20.04/22.04 LTS                                      ║"
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

echo -e "${BLUE}[INFO]${NC} Iniciando deployment..."

# ============================================================================
# 1. ACTUALIZAR SISTEMA
# ============================================================================
echo ""
echo -e "${YELLOW}[1/11]${NC} Actualizando sistema..."
apt update -y
apt upgrade -y

# ============================================================================
# 2. INSTALAR NODE.JS 20 LTS
# ============================================================================
echo ""
echo -e "${YELLOW}[2/11]${NC} Verificando Node.js..."

# Verificar si Node.js está instalado
if command -v node &> /dev/null; then
    CURRENT_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    echo -e "${BLUE}[INFO]${NC} Node.js v$CURRENT_VERSION detectado"
    
    # Si es versión 18 o menor, eliminarla
    if [ "$CURRENT_VERSION" -le 18 ]; then
        echo -e "${YELLOW}[INFO]${NC} Eliminando Node.js v$CURRENT_VERSION (incompatible con Baileys 7.x)..."
        
        # Eliminar Node.js y npm
        apt remove -y nodejs npm
        apt purge -y nodejs npm
        apt autoremove -y
        
        # Limpiar repositorios antiguos de NodeSource
        rm -f /etc/apt/sources.list.d/nodesource.list
        rm -f /usr/share/keyrings/nodesource.gpg
        
        echo -e "${GREEN}[OK]${NC} Node.js v$CURRENT_VERSION eliminado"
        
        # Instalar Node.js 20
        echo -e "${YELLOW}[INFO]${NC} Instalando Node.js 20 LTS..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs
        echo -e "${GREEN}[OK]${NC} Node.js 20 LTS instalado"
    elif [ "$CURRENT_VERSION" -ge 20 ]; then
        echo -e "${GREEN}[OK]${NC} Node.js v$CURRENT_VERSION ya instalado (compatible)"
    else
        # Versión 19 - actualizar a 20
        echo -e "${YELLOW}[INFO]${NC} Actualizando Node.js v$CURRENT_VERSION a v20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
        apt install -y nodejs
        echo -e "${GREEN}[OK]${NC} Node.js actualizado a v20"
    fi
else
    # Node.js no está instalado
    echo -e "${YELLOW}[INFO]${NC} Node.js no encontrado. Instalando Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
    echo -e "${GREEN}[OK]${NC} Node.js 20 LTS instalado"
fi

# Verificar instalación
echo -e "${BLUE}[INFO]${NC} Verificando instalación..."
node --version
npm --version

# ============================================================================
# 3. INSTALAR PNPM
# ============================================================================
echo ""
echo -e "${YELLOW}[3/11]${NC} Instalando pnpm..."
if ! command -v pnpm &> /dev/null; then
    # Habilitar corepack (viene con Node.js 16+)
    corepack enable
    corepack prepare pnpm@latest --activate
    echo -e "${GREEN}[OK]${NC} pnpm instalado"
else
    echo -e "${GREEN}[OK]${NC} pnpm ya está instalado"
fi
pnpm --version

# ============================================================================
# 4. INSTALAR PM2
# ============================================================================
echo ""
echo -e "${YELLOW}[4/11]${NC} Instalando PM2..."
if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
    echo -e "${GREEN}[OK]${NC} PM2 instalado"
else
    echo -e "${GREEN}[OK]${NC} PM2 ya está instalado"
fi
pm2 --version

# ============================================================================
# 5. CREAR USUARIO DEDICADO
# ============================================================================
echo ""
echo -e "${YELLOW}[5/11]${NC} Configurando usuario dedicado..."
if ! id "whatsapp" &>/dev/null; then
    useradd -m -s /bin/bash whatsapp
    echo -e "${GREEN}[OK]${NC} Usuario 'whatsapp' creado"
else
    echo -e "${GREEN}[OK]${NC} Usuario 'whatsapp' ya existe"
fi

# ============================================================================
# 6. CONFIGURAR DIRECTORIO DE APLICACIÓN
# ============================================================================
echo ""
echo -e "${YELLOW}[6/11]${NC} Configurando directorio de aplicación..."
APP_DIR="/opt/whatsapp-api"

if [ ! -d "$APP_DIR" ]; then
    mkdir -p "$APP_DIR"
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
        cp -r ./* "$APP_DIR/"
        echo -e "${GREEN}[OK]${NC} Archivos copiados"
    else
        echo -e "${RED}[ERROR]${NC} Archivos no encontrados en el directorio actual"
        exit 1
    fi
elif [ "$SOURCE_OPTION" == "2" ]; then
    # Clonar desde Git
    read -p "URL del repositorio Git: " GIT_URL
    apt install -y git
    
    # Si el directorio existe y no está vacío, eliminarlo
    if [ -d "$APP_DIR" ] && [ "$(ls -A $APP_DIR)" ]; then
        rm -rf "$APP_DIR"
    fi
    
    git clone "$GIT_URL" "$APP_DIR"
    echo -e "${GREEN}[OK]${NC} Repositorio clonado"
else
    echo -e "${RED}[ERROR]${NC} Opción inválida"
    exit 1
fi

# Dar permisos
chown -R whatsapp:whatsapp "$APP_DIR"

# ============================================================================
# 7. INSTALAR DEPENDENCIAS
# ============================================================================
echo ""
echo -e "${YELLOW}[7/11]${NC} Instalando dependencias con pnpm..."
cd "$APP_DIR"

# Verificar si existe pnpm-lock.yaml
if [ -f "pnpm-lock.yaml" ]; then
    echo -e "${BLUE}[INFO]${NC} Usando pnpm (detectado pnpm-lock.yaml)"
    # Instalar TODAS las dependencias (necesario para ES Modules)
    su - whatsapp -c "cd $APP_DIR && pnpm install --frozen-lockfile"
elif [ -f "package-lock.json" ]; then
    echo -e "${BLUE}[INFO]${NC} Usando npm (detectado package-lock.json)"
    # Instalar TODAS las dependencias
    su - whatsapp -c "cd $APP_DIR && npm ci"
else
    echo -e "${BLUE}[INFO]${NC} Usando pnpm (por defecto)"
    # Instalar TODAS las dependencias
    su - whatsapp -c "cd $APP_DIR && pnpm install"
fi

echo -e "${GREEN}[OK]${NC} Dependencias instaladas"

# ============================================================================
# 8. CONFIGURAR VARIABLES DE ENTORNO
# ============================================================================
echo ""
echo -e "${YELLOW}[8/11]${NC} Configurando variables de entorno..."

if [ ! -f "$APP_DIR/.env" ]; then
    if [ -f "$APP_DIR/.env.example" ]; then
        cp "$APP_DIR/.env.example" "$APP_DIR/.env"
        echo -e "${YELLOW}[INFO]${NC} Archivo .env creado desde .env.example"
        echo -e "${YELLOW}[WARNING]${NC} Recuerda editar $APP_DIR/.env con tus valores"
    else
        echo -e "${YELLOW}[WARNING]${NC} No se encontró .env.example"
    fi
fi

chown whatsapp:whatsapp "$APP_DIR/.env" 2>/dev/null || true

# ============================================================================
# 9. CONFIGURAR PM2
# ============================================================================
echo ""
echo -e "${YELLOW}[9/11]${NC} Configurando PM2..."

# Detener proceso anterior si existe
su - whatsapp -c "pm2 delete whatsapp-api" 2>/dev/null || true

# Verificar si existe ecosystem.config.cjs
if [ -f "$APP_DIR/ecosystem.config.cjs" ]; then
    echo -e "${BLUE}[INFO]${NC} Usando ecosystem.config.cjs"
    # Iniciar con archivo de configuración
    su - whatsapp -c "cd $APP_DIR && pm2 start ecosystem.config.cjs"
else
    echo -e "${BLUE}[INFO]${NC} Usando configuración manual"
    # Iniciar manualmente con configuración básica + flag Web Crypto API
    su - whatsapp -c "cd $APP_DIR && pm2 start baileys-server.js --name whatsapp-api --time --max-memory-restart 1G --node-args='--experimental-global-webcrypto --max-old-space-size=1024'"
fi

# Guardar configuración de PM2
su - whatsapp -c "pm2 save"

# Configurar inicio automático en boot del sistema
env PATH=$PATH:/usr/bin pm2 startup systemd -u whatsapp --hp /home/whatsapp
systemctl enable pm2-whatsapp

echo -e "${GREEN}[OK]${NC} PM2 configurado para inicio automático"
echo -e "${GREEN}[OK]${NC} Aplicación configurada en puerto 3000"

# ============================================================================
# 10. CONFIGURAR FIREWALL
# ============================================================================
echo ""
echo -e "${YELLOW}[10/11]${NC} Configurando firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp comment 'SSH'
    ufw allow 3000/tcp comment 'WhatsApp API'
    ufw --force enable
    echo -e "${GREEN}[OK]${NC} Firewall configurado"
else
    echo -e "${YELLOW}[WARNING]${NC} UFW no está instalado, omitiendo configuración de firewall"
fi

# ============================================================================
# 11. INSTALAR Y CONFIGURAR NGINX
# ============================================================================
echo ""
echo -e "${YELLOW}[11/11]${NC} ¿Deseas instalar Nginx como reverse proxy? (s/n)"
read -p "Respuesta: " INSTALL_NGINX

if [[ "$INSTALL_NGINX" =~ ^[Ss]$ ]]; then
    # Instalar Nginx
    apt install -y nginx
    
    # Solicitar dominio
    echo ""
    read -p "Ingresa tu dominio (ej: api.tuempresa.com) o IP: " DOMAIN
    
    # Crear configuración de Nginx
    cat > /etc/nginx/sites-available/whatsapp-api << EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    # Activar sitio
    ln -sf /etc/nginx/sites-available/whatsapp-api /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    
    # Probar configuración
    nginx -t
    systemctl restart nginx
    systemctl enable nginx
    
    # Abrir puerto 80
    ufw allow 80/tcp comment 'HTTP'
    
    echo -e "${GREEN}[OK]${NC} Nginx instalado y configurado"
    
    # Preguntar por SSL
    echo ""
    echo -e "${YELLOW}[INFO]${NC} ¿Deseas instalar certificado SSL (HTTPS) con Let's Encrypt? (s/n)"
    read -p "Respuesta: " INSTALL_SSL
    
    if [[ "$INSTALL_SSL" =~ ^[Ss]$ ]]; then
        apt install -y certbot python3-certbot-nginx
        
        echo ""
        read -p "Email para notificaciones SSL: " SSL_EMAIL
        
        certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos -m "$SSL_EMAIL"
        
        # Abrir puerto 443
        ufw allow 443/tcp comment 'HTTPS'
        
        echo -e "${GREEN}[OK]${NC} SSL instalado"
        FINAL_URL="https://$DOMAIN"
    else
        FINAL_URL="http://$DOMAIN"
    fi
else
    FINAL_URL="http://$(curl -s ifconfig.me):3000"
fi

# ============================================================================
# VERIFICAR INSTALACIÓN
# ============================================================================
echo ""
echo -e "${YELLOW}[VERIFICACIÓN]${NC} Verificando instalación..."

# Esperar a que el servicio inicie
sleep 5

# Verificar PM2
if su - whatsapp -c "pm2 list" | grep -q "whatsapp-api"; then
    echo -e "${GREEN}[OK]${NC} Servicio PM2 activo"
else
    echo -e "${RED}[ERROR]${NC} Servicio PM2 no está activo"
    exit 1
fi

# Verificar endpoint
if curl -s http://localhost:3000/session/status > /dev/null; then
    echo -e "${GREEN}[OK]${NC} API respondiendo correctamente"
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
echo -e "${GREEN}✓ Sistema actualizado${NC}"
echo -e "${GREEN}✓ Node.js $(node --version) instalado${NC}"
echo -e "${GREEN}✓ pnpm $(pnpm --version) instalado${NC}"
echo -e "${GREEN}✓ PM2 instalado y configurado${NC}"
echo -e "${GREEN}✓ Aplicación desplegada en $APP_DIR${NC}"
echo -e "${GREEN}✓ Servicio configurado para inicio automático${NC}"
if [[ "$INSTALL_NGINX" =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}✓ Nginx configurado como reverse proxy${NC}"
    if [[ "$INSTALL_SSL" =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}✓ SSL/HTTPS habilitado${NC}"
    fi
fi
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}URL de tu API:${NC}"
echo -e "  ${GREEN}$FINAL_URL${NC}"
echo ""
echo -e "${BLUE}Configuración en Delphi:${NC}"
echo -e "  ${YELLOW}edtAPIUrl.Text := '$FINAL_URL';${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}Comandos útiles:${NC}"
echo ""
echo "  Ver logs:"
echo -e "    ${YELLOW}sudo su - whatsapp -c 'pm2 logs whatsapp-api'${NC}"
echo ""
echo "  Ver estado:"
echo -e "    ${YELLOW}sudo su - whatsapp -c 'pm2 status'${NC}"
echo ""
echo "  Reiniciar servicio:"
echo -e "    ${YELLOW}sudo su - whatsapp -c 'pm2 restart whatsapp-api'${NC}"
echo ""
echo "  Detener servicio:"
echo -e "    ${YELLOW}sudo su - whatsapp -c 'pm2 stop whatsapp-api'${NC}"
echo ""
echo "  Actualizar código:"
echo -e "    ${YELLOW}cd $APP_DIR && git pull && pnpm install${NC}"
echo -e "    ${YELLOW}sudo su - whatsapp -c 'pm2 restart whatsapp-api'${NC}"
echo ""
echo "  Resetear sesión de WhatsApp:"
echo -e "    ${YELLOW}curl -X POST http://localhost:3000/session/reset${NC}"
echo ""
echo "  Obtener código QR:"
echo -e "    ${YELLOW}curl http://localhost:3000/session/qr${NC}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${GREEN}¡Deployment completado exitosamente!${NC}"
echo ""
echo "Siguiente paso:"
echo "1. Edita las variables de entorno: nano $APP_DIR/.env"
echo "2. Reinicia el servicio: sudo su - whatsapp -c 'pm2 restart whatsapp-api'"
echo "3. Abre tu aplicación Delphi"
echo "4. Configura la URL de la API: $FINAL_URL"
echo "5. Click en 'Obtener Código QR'"
echo "6. Escanea con WhatsApp móvil"
echo ""
echo -e "${YELLOW}[IMPORTANTE]${NC} Recuerda configurar las variables de entorno en:"
echo -e "  ${BLUE}$APP_DIR/.env${NC}"
echo ""
