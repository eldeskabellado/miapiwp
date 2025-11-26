# 🚀 Solución Completa - VPS con Node.js 20 + Web Crypto API

## ✅ Cambios Realizados

1. **Script de Deployment (`deploy-vps.sh`)**
   - Detecta y elimina Node.js 18 o anterior
   - Instala Node.js 20 LTS limpiamente
   - Configura PM2 con flag Web Crypto API

2. **Archivo PM2 (`ecosystem.config.js`)**
   - Flag `--experimental-global-webcrypto` agregado
   - Configuración optimizada para Baileys 7.x

---

## 🔧 Solución Inmediata para tu VPS Actual

### Ejecuta estos comandos en tu VPS:

```bash
# 1. Conectar al VPS
ssh user@servidor

# 2. Ir al directorio
cd /root/ferresolar-pintura

# 3. ELIMINAR Node.js 18 (si existe)
echo "Eliminando Node.js 18..."
apt remove -y nodejs npm
apt purge -y nodejs npm
apt autoremove -y
rm -f /etc/apt/sources.list.d/nodesource.list
rm -f /usr/share/keyrings/nodesource.gpg

# 4. INSTALAR Node.js 20 LTS
echo "Instalando Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# 5. Verificar instalación
node --version  # Debe mostrar v20.x.x
npm --version

# 6. Reinstalar dependencias
echo "Reinstalando dependencias..."
rm -rf node_modules
pnpm install

# 7. Actualizar ecosystem.config.js
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'whatsapp-api',
    script: './baileys-server.js',
    instances: 1,
    exec_mode: 'fork',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    max_restarts: 10,
    min_uptime: '10s',
    restart_delay: 4000,
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
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

# 8. Crear directorio de logs
mkdir -p logs

# 9. Reiniciar PM2
pm2 delete myapp 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

# 10. Ver logs
pm2 logs myapp --lines 50
```

---

## 📋 Comando Todo-en-Uno (Copy-Paste)

```bash
cd /root/ferresolar-pintura && \
apt remove -y nodejs npm && apt purge -y nodejs npm && apt autoremove -y && \
rm -f /etc/apt/sources.list.d/nodesource.list && rm -f /usr/share/keyrings/nodesource.gpg && \
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt install -y nodejs && \
node --version && \
rm -rf node_modules && pnpm install && \
mkdir -p logs && \
pm2 delete myapp 2>/dev/null || true && \
pm2 start ecosystem.config.js && \
pm2 save && \
sleep 5 && \
pm2 logs myapp --lines 20
```

---

## 🔍 Verificación

### 1. Ver versión de Node.js

```bash
node --version
```

**Debe mostrar:** `v20.x.x`

### 2. Ver estado de PM2

```bash
pm2 list
```

**Debe mostrar:**
```
┌─────┬──────────────┬─────────┬─────────┬─────────┬──────────┐
│ id  │ name         │ mode    │ status  │ ↺       │ cpu      │
├─────┼──────────────┼─────────┼─────────┼─────────┼──────────┤
│ 0   │ myapp        │ fork    │ online  │ 0       │ 0%       │
└─────┴──────────────┴─────────┴─────────┴─────────┴──────────┘
```

### 3. Ver logs sin errores

```bash
pm2 logs myapp --lines 50
```

**Debe mostrar:**
```
╔══════════════════════════════════════╗
║  WhatsApp API Server con Baileys     ║
║  Compatible con Delphi Rio Client    ║
╚══════════════════════════════════════╝

🚀 Servidor corriendo en http://localhost:3000
🔄 Iniciando conexión con WhatsApp...
📱 Código QR generado
```

### 4. Verificar flag de Web Crypto

```bash
pm2 show myapp | grep node_args
```

**Debe mostrar:**
```
node_args: --max-old-space-size=1024 --experimental-global-webcrypto
```

### 5. Probar endpoint

```bash
curl http://localhost:3000/session/status
```

**Respuesta esperada:**
```json
{
  "success": true,
  "connected": false,
  "state": "disconnected"
}
```

---

## 🎯 Errores que se Solucionan

### ✅ Error 1: Cannot find package 'express'
**Solución:** Reinstalación completa de dependencias con `pnpm install`

### ✅ Error 2: Cannot destructure property 'subtle' of 'globalThis.crypto'
**Solución:** Flag `--experimental-global-webcrypto` en PM2

### ✅ Error 3: Incompatibilidad con Node.js 18
**Solución:** Eliminación de Node.js 18 e instalación de Node.js 20

---

## 📊 Antes vs Después

| Aspecto | Antes | Después |
|---------|-------|---------|
| **Node.js** | v18.x ❌ | v20.x ✅ |
| **Web Crypto API** | Undefined ❌ | Habilitada ✅ |
| **Dependencias** | --prod ❌ | Completas ✅ |
| **PM2 Flags** | Ninguno ❌ | --experimental-global-webcrypto ✅ |
| **Baileys 7.x** | No funciona ❌ | Funciona ✅ |
| **Auto-restart** | Manual ❌ | Automático ✅ |

---

## 🆘 Si Algo Sale Mal

### Error: "apt remove nodejs failed"

```bash
# Forzar eliminación
dpkg --remove --force-remove-reinstreq nodejs
dpkg --remove --force-remove-reinstreq npm
apt autoremove -y
```

### Error: "pnpm not found"

```bash
# Instalar pnpm
corepack enable
corepack prepare pnpm@latest --activate
pnpm --version
```

### Error: "pm2 not found"

```bash
# Reinstalar PM2
npm install -g pm2
pm2 --version
```

### Logs muestran error

```bash
# Ver error completo
pm2 logs myapp --err --lines 100

# Ver información del proceso
pm2 show myapp

# Reiniciar con debug
pm2 delete myapp
pm2 start ecosystem.config.js
pm2 logs myapp
```

---

## 🔄 Para Futuros Deployments

Ya no necesitas hacer esto manualmente. El script `deploy-vps.sh` actualizado hará todo automáticamente:

```bash
# En futuros servidores
sudo bash deploy-vps.sh
```

El script ahora:
- ✅ Detecta Node.js 18 y lo elimina
- ✅ Instala Node.js 20 automáticamente
- ✅ Configura PM2 con Web Crypto API
- ✅ Instala todas las dependencias
- ✅ Configura auto-restart

---

## ✅ Checklist Final

- [ ] Conectado al VPS
- [ ] Node.js 18 eliminado
- [ ] Node.js 20 instalado y verificado
- [ ] pnpm funcionando
- [ ] `node_modules` reinstalado completamente
- [ ] `ecosystem.config.js` actualizado con flag
- [ ] Directorio `logs/` creado
- [ ] PM2 reiniciado con nueva configuración
- [ ] PM2 save ejecutado
- [ ] Logs sin errores
- [ ] Servidor respondiendo en puerto 3000
- [ ] Endpoint `/session/status` funciona

---

## 🎉 Resultado Final

Después de ejecutar estos pasos tendrás:

✅ **Node.js 20 LTS** instalado  
✅ **Web Crypto API** habilitada  
✅ **Baileys 7.x** funcionando  
✅ **Todas las dependencias** instaladas  
✅ **PM2** configurado correctamente  
✅ **Auto-restart** en caso de falla  
✅ **Persistencia** tras reinicio  
✅ **Puerto 3000** fijo  

---

**📖 Documentación Relacionada:**
- `WEBCRYPTO-FIX.md` - Detalles del fix de Web Crypto
- `VPS-FIX.md` - Solución de dependencias
- `PM2-CONFIG.md` - Configuración de PM2
- `NODE-UPGRADE.md` - Upgrade de Node.js
