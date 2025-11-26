# 🔧 Fix URGENTE - ecosystem.config.js Error

## ❌ El Error

```
File ecosystem.config.js malformated
ReferenceError: module is not defined in ES module scope
```

## 🎯 La Causa

El archivo `ecosystem.config.js` usa **CommonJS** (`module.exports`) pero como `package.json` tiene `"type": "module"`, Node.js lo trata como **ES Module** y falla.

## ✅ Solución INMEDIATA (VPS)

### Ejecuta estos comandos en tu VPS:

```bash
# 1. Conectar al VPS
ssh user@servidor

# 2. Ir al directorio
cd /root/ferresolar-pintura

# 3. Renombrar ecosystem.config.js a .cjs
mv ecosystem.config.js ecosystem.config.cjs

# 4. Detener PM2
pm2 delete myapp

# 5. Iniciar con el archivo .cjs
pm2 start ecosystem.config.cjs

# 6. Guardar configuración
pm2 save

# 7. Ver logs
pm2 logs myapp --lines 30
```

---

## 📋 Comando Todo-en-Uno (Copy-Paste)

```bash
cd /root/ferresolar-pintura && \
mv ecosystem.config.js ecosystem.config.cjs 2>/dev/null || true && \
pm2 delete myapp 2>/dev/null || true && \
pm2 start ecosystem.config.cjs && \
pm2 save && \
sleep 5 && \
echo "✅ Configuración aplicada. Verificando logs..." && \
pm2 logs myapp --lines 20
```

---

## 🔍 Verificación

### 1. El archivo debe ser .cjs

```bash
ls -la ecosystem.config.cjs
# Debe existir
```

### 2. PM2 debe estar usando el archivo correcto

```bash
pm2 show myapp | grep script
# Debe mostrar: script path: /root/ferresolar-pintura/ecosystem.config.cjs
```

### 3. Flag Web Crypto debe estar activo

```bash
pm2 show myapp | grep node_args
# Debe mostrar: --experimental-global-webcrypto
```

### 4. Logs sin errores

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

### 5. Endpoint funciona

```bash
curl http://localhost:3000/session/status
```

---

## 🆘 Si el archivo ecosystem.config no existe

Si no tienes el archivo, créalo:

```bash
cd /root/ferresolar-pintura

cat > ecosystem.config.cjs << 'EOF'
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

# Crear directorio de logs
mkdir -p logs

# Iniciar
pm2 delete myapp 2>/dev/null || true
pm2 start ecosystem.config.cjs
pm2 save
pm2 logs myapp
```

---

## 📖 Explicación Técnica

### CommonJS vs ES Modules

**CommonJS (necesita .cjs):**
```javascript
module.exports = { ... }  // ← Sintaxis CommonJS
```

**ES Modules (.js con "type": "module"):**
```javascript
export default { ... }  // ← Sintaxis ES Modules
```

### El Conflicto

```json
// package.json
{
  "type": "module"  // ← Todos los .js son ES Modules
}
```

```javascript
// ecosystem.config.js (NO FUNCIONA)
module.exports = { ... }  // ← CommonJS en archivo .js
```

### La Solución

```javascript
// ecosystem.config.cjs (SÍ FUNCIONA)
module.exports = { ... }  // ← CommonJS en archivo .cjs
```

Node.js trata `.cjs` siempre como CommonJS, sin importar el `package.json`.

---

## 🎯 Alternativa: Sin ecosystem.config

Si prefieres no usar archivo de configuración:

```bash
cd /root/ferresolar-pintura

pm2 delete myapp 2>/dev/null || true

pm2 start baileys-server.js \
  --name myapp \
  --node-args="--experimental-global-webcrypto --max-old-space-size=1024" \
  --time \
  --max-memory-restart 1G \
  --autorestart \
  --max-restarts 10

pm2 save
pm2 logs myapp
```

---

## ✅ Checklist de Solución

- [ ] Conectado al VPS
- [ ] Navegado a `/root/ferresolar-pintura`
- [ ] Renombrado `ecosystem.config.js` a `.cjs`
- [ ] PM2 detenido
- [ ] PM2 iniciado con `ecosystem.config.cjs`
- [ ] Configuración guardada con `pm2 save`
- [ ] Logs sin error de "module is not defined"
- [ ] Logs sin error de "crypto is undefined"
- [ ] Servidor iniciando correctamente
- [ ] Endpoint `/session/status` responde

---

## 🎉 Resultado Esperado

Después de ejecutar estos pasos, deberías ver en los logs:

```
PM2      | App [whatsapp-api] starting...
PM2      | App [whatsapp-api] online

╔══════════════════════════════════════╗
║  WhatsApp API Server con Baileys     ║
║  Compatible con Delphi Rio Client    ║
╚══════════════════════════════════════╝

🚀 Servidor corriendo en http://localhost:3000

📋 Endpoints disponibles:
  GET  /session/qr
  GET  /session/status
  POST /session/reset
  POST /message/text

🔄 Iniciando conexión con WhatsApp...
📱 Código QR generado
✅ QR convertido a Base64
```

---

**📞 Archivos Actualizados:**
- ✅ `ecosystem.config.cjs` (renombrado)
- ✅ `deploy-vps.sh` (actualizado para usar .cjs)
