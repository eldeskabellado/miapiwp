#!/bin/bash
# ============================================================================
# Script de Instalacion Automatica - WhatsApp Client
# Compatible con Linux y macOS
# ============================================================================

set -e  # Salir si hay error

echo ""
echo "╔═══════════════════════════════════════════════════════════════════════╗"
echo "║                                                                       ║"
echo "║          WhatsApp Client - Instalacion Automatica                    ║"
echo "║          Delphi Rio + Node.js + Baileys                              ║"
echo "║                                                                       ║"
echo "╚═══════════════════════════════════════════════════════════════════════╝"
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar Node.js
echo "[1/5] Verificando Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}[ERROR]${NC} Node.js no esta instalado"
    echo ""
    echo "Por favor instala Node.js:"
    echo ""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "  macOS: brew install node"
    else
        echo "  Ubuntu/Debian: sudo apt install nodejs npm"
        echo "  CentOS/RHEL: sudo yum install nodejs npm"
        echo "  Arch: sudo pacman -S nodejs npm"
    fi
    echo ""
    echo "O descarga desde: https://nodejs.org/"
    exit 1
fi

echo -e "${GREEN}[OK]${NC} Node.js instalado"
node --version
npm --version

# Verificar version de Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 16 ]; then
    echo -e "${YELLOW}[WARNING]${NC} Version de Node.js es muy antigua ($NODE_VERSION)"
    echo "Se recomienda Node.js v16 o superior"
fi

# Crear directorio del proyecto
echo ""
echo "[2/5] Creando estructura de directorios..."
PROJECT_DIR="./whatsapp-api"
mkdir -p "$PROJECT_DIR"
echo -e "${GREEN}[OK]${NC} Directorio creado: $PROJECT_DIR"

# Verificar archivos necesarios
echo ""
echo "[3/5] Verificando archivos del proyecto..."
if [ ! -f "baileys-server.js" ]; then
    echo -e "${RED}[ERROR]${NC} Archivo baileys-server.js no encontrado"
    echo "Por favor asegurate de ejecutar este script en la carpeta correcta"
    exit 1
fi
if [ ! -f "package.json" ]; then
    echo -e "${RED}[ERROR]${NC} Archivo package.json no encontrado"
    exit 1
fi
echo -e "${GREEN}[OK]${NC} Archivos encontrados"

# Copiar archivos
echo ""
echo "[4/5] Copiando archivos al proyecto..."
cp baileys-server.js "$PROJECT_DIR/"
cp package.json "$PROJECT_DIR/"
echo -e "${GREEN}[OK]${NC} Archivos copiados"

# Instalar dependencias
echo ""
echo "[5/5] Instalando dependencias de Node.js..."
echo "Esto puede tomar varios minutos..."
echo ""
cd "$PROJECT_DIR"

if npm install; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                       ║"
    echo "║                    ¡INSTALACION COMPLETADA!                          ║"
    echo "║                                                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "Servidor instalado en: ${GREEN}$PROJECT_DIR${NC}"
    echo ""
    echo "PROXIMOS PASOS:"
    echo ""
    echo "1. Iniciar el servidor:"
    echo -e "   ${YELLOW}cd $PROJECT_DIR${NC}"
    echo -e "   ${YELLOW}npm start${NC}"
    echo ""
    echo "2. En otra terminal, compilar la aplicacion Delphi"
    echo "   (Si estas en Linux con Wine + Delphi)"
    echo ""
    echo "3. Ejecutar la aplicacion Delphi"
    echo ""
    echo "4. Hacer click en 'Obtener Codigo QR'"
    echo ""
    echo "5. Escanear con WhatsApp movil"
    echo ""
    
    # Preguntar si desea iniciar ahora
    read -p "¿Deseas iniciar el servidor ahora? (s/n): " respuesta
    if [[ "$respuesta" =~ ^[Ss]$ ]]; then
        echo ""
        echo "Iniciando servidor..."
        echo "Presiona Ctrl+C para detener"
        echo ""
        npm start
    else
        echo ""
        echo "Para iniciar el servidor mas tarde:"
        echo -e "${YELLOW}cd $PROJECT_DIR${NC}"
        echo -e "${YELLOW}npm start${NC}"
        echo ""
    fi
else
    echo ""
    echo -e "${RED}[ERROR]${NC} Fallo la instalacion de dependencias"
    echo "Intenta manualmente:"
    echo "  cd $PROJECT_DIR"
    echo "  npm install"
    exit 1
fi
