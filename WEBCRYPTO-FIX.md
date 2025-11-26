# 🔧 Fix: Web Crypto API Undefined (Baileys 7.x)

## ❌ El Error

```
TypeError: Cannot destructure property 'subtle' of 'globalThis.crypto' as it is undefined.
at file:///root/.../baileys/lib/Utils/crypto.js:5:9
```

## 🎯 La Causa

**Baileys 7.x** requiere la **Web Crypto API** que está disponible en Node.js 19+, pero necesita ser habilitada explícitamente con un flag.

## ✅ Solución Inmediata (VPS)

### Opción 1: Actualizar ecosystem.config.js en el VPS

```bash
# 1. Conectar al VPS
ssh user@servidor

# 2. Ir al directorio
cd /root/ferresolar-pintura

# 3. Editar ecosystem.config.js
nano ecosystem.config.js

# 4. Buscar la línea node_args y cambiarla a:
node_args: '--max-old-space-size=1024 --experimental-global-webcrypto'

# 5. Guardar (Ctrl+O, Enter, Ctrl+X)

# 6. Reiniciar PM2 con nueva configuración
pm2 delete myapp
pm2 start ecosystem.config.js

# 7. Ver logs
pm2 logs myapp
```

### Opción 2: Comando Directo (Sin ecosystem.config.js)

```bash
# Detener aplicación actual
pm2 delete myapp

# Iniciar con el flag correcto
pm2 start baileys-server.js \
  --name myapp \
  --node-args="--experimental-global-webcrypto" \
  --time \
  --max-memory-restart 1G

# Guardar configuración
pm2 save

# Ver logs
pm2 logs myapp
```

### Opción 3: Script Completo (Copy-Paste)

```bash
cd /root/ferresolar-pintura && \
pm2 delete myapp 2>/dev/null || true && \
pm2 start baileys-server.js \
  --name myapp \
  --node-args="--experimental-global-webcrypto --max-old-space-size=1024" \
  --time \
  --max-memory-restart 1G && \
pm2 save && \
sleep 5 && \
pm2 logs myapp --lines 20
```

---

## 📋 Verificación

### 1. Ver que PM2 usa el flag correcto

```bash
pm2 show myapp | grep node_args
```

**Debe mostrar:**
```
node_args: --experimental-global-webcrypto
```

### 2. Ver logs sin errores

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
```

### 3. Probar endpoint

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

## 🔍 Explicación Técnica

### Por qué sucede este error

Baileys 7.x usa el módulo crypto moderno de Node.js que incluye `globalThis.crypto.subtle`, pero:

1. **Node.js < 19**: No tiene `globalThis.crypto`
2. **Node.js 19-20**: Tiene la API pero es experimental
3. **Node.js 21+**: Es estable por defecto

### El flag --experimental-global-webcrypto

Este flag habilita la Web Crypto API globalmente en Node.js 19 y 20.

```javascript
// Sin flag
globalThis.crypto // undefined ❌

// Con flag
globalThis.crypto // {subtle: {...}} ✅
```

---

## 🆘 Si Aún No Funciona

### Verificar versión de Node.js

```bash
node --version
```

**Debe ser v20.x.x o superior**

Si es menor:

```bash
# Actualizar a Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Verificar
node --version

# Reiniciar PM2
pm2 restart myapp
```

### Reinstalar Baileys

```bash
cd /root/ferresolar-pintura

# Eliminar node_modules
rm -rf node_modules

# Reinstalar
pnpm install

# O con npm
npm install

# Reiniciar
pm2 restart myapp
```

### Ver información detallada del proceso

```bash
pm2 show myapp
```

Busca la sección `interpreter args` - debe mostrar el flag.

---

## 📝 Actualizar Proyecto Local

Ya actualicé `ecosystem.config.js` en el proyecto local. Para deployment futuro:

```bash
# En tu máquina local
git add ecosystem.config.js
git commit -m "Fix: Add Web Crypto API flag for Baileys 7.x"
git push origin main

# En el VPS (si usas Git)
cd /root/ferresolar-pintura
git pull
pm2 delete myapp
pm2 start ecosystem.config.js
pm2 save
```

---

## 🎯 Script de Deployment Actualizado

El script `deploy-vps.sh` ya está configurado para usar `ecosystem.config.js` automáticamente, así que en futuros deployments no necesitarás hacer nada manual.

```bash
# En futuras instalaciones, simplemente:
sudo bash deploy-vps.sh
```

---

## ✅ Checklist de Solución

- [ ] Conectado al VPS
- [ ] Navegado a `/root/ferresolar-pintura`
- [ ] Verificado Node.js v20+
- [ ] Dependencias instaladas (`node_modules` existe)
- [ ] PM2 reiniciado con flag `--experimental-global-webcrypto`
- [ ] Logs sin error de crypto
- [ ] Servidor iniciando correctamente
- [ ] Endpoint `/session/status` responde

---

## 💡 Alternativa: Docker

Si prefieres evitar estos problemas, usa Docker donde todo está configurado:

```bash
# En el VPS
git clone tu-repositorio
cd backend-nodejs-baylei
cp .env.example .env
nano .env  # Editar

docker-compose up -d
docker-compose logs -f whatsapp-api
```

Docker ya tiene todo configurado correctamente.

---

## 🎉 Resumen

### Problema
```
TypeError: Cannot destructure property 'subtle' of 'globalThis.crypto'
```

### Causa
Baileys 7.x necesita Web Crypto API que requiere flag especial en Node.js 20

### Solución
```bash
pm2 start baileys-server.js \
  --node-args="--experimental-global-webcrypto"
```

### Resultado
✅ Web Crypto API disponible  
✅ Baileys 7.x funciona  
✅ Servidor inicia correctamente  

---

**📖 Más info:** Ver `PM2-CONFIG.md` para configuración completa de PM2
