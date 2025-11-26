# 🔧 Fix: Cannot find package 'express' (VPS)

## ❌ El Error

```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'express' imported from /root/ferresolar-pintura/baileys-server.js
code: 'ERR_MODULE_NOT_FOUND'
```

## 🎯 La Causa

El script de deployment estaba instalando solo dependencias de producción (`--prod`), pero con **ES Modules** y **Baileys 7.x** se necesitan TODAS las dependencias para resolver correctamente los módulos.

## ✅ La Solución (Ya Aplicada)

### Actualizado `deploy-vps.sh`

**ANTES (causaba error):**
```bash
pnpm install --frozen-lockfile --prod  # Solo producción
npm ci --omit=dev                       # Solo producción
```

**AHORA (funciona):**
```bash
pnpm install --frozen-lockfile  # TODAS las dependencias
npm ci                          # TODAS las dependencias
```

---

## 🚀 Cómo Arreglar en tu VPS

### Si ya desplegaste y tienes el error:

```bash
# Conectar al VPS
ssh user@tu-servidor

# Ir al directorio de la aplicación
cd /opt/whatsapp-api

# Reinstalar TODAS las dependencias
sudo su - whatsapp -c "cd /opt/whatsapp-api && pnpm install"

# Reiniciar el servicio
sudo su - whatsapp -c "pm2 restart whatsapp-api"

# Ver logs
sudo su - whatsapp -c "pm2 logs whatsapp-api"
```

### Si vas a desplegar de nuevo:

```bash
# El script ya está corregido, solo ejecuta:
sudo bash deploy-vps.sh
```

---

## 📋 Verificación

### 1. Ver que las dependencias están instaladas

```bash
# Conectar al VPS
ssh user@tu-servidor

# Verificar node_modules
ls -la /opt/whatsapp-api/node_modules | grep express

# Deberías ver:
# drwxr-xr-x  express
```

### 2. Ver logs del servicio

```bash
sudo su - whatsapp -c "pm2 logs whatsapp-api --lines 50"
```

**Deberías ver:**
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

## 🔍 Por Qué Necesitamos Todas las Dependencias

### Con CommonJS (antes):
```javascript
const express = require('express');
// Node.js busca en node_modules/express
// Funciona solo con dependencias de producción
```

### Con ES Modules (ahora):
```javascript
import express from 'express';
// Node.js usa resolución de módulos ESM
// Necesita TODAS las dependencias para resolver correctamente
// Especialmente con paquetes como Baileys que tienen dependencias complejas
```

### Baileys 7.x específicamente:
- Es un módulo ESM puro
- Tiene dependencias que se resuelven dinámicamente
- Requiere que todas las dependencias estén disponibles
- `--prod` puede omitir dependencias necesarias para la resolución

---

## 💡 Alternativa: Usar Docker

Si prefieres no instalar todas las dependencias en el VPS, usa Docker:

```bash
# En el VPS
git clone tu-repositorio
cd backend-nodejs-baylei

# Copiar .env
cp .env.example .env
nano .env  # Editar con tus valores

# Levantar con Docker
docker-compose up -d

# Ver logs
docker-compose logs -f whatsapp-api
```

**Ventajas de Docker:**
- ✅ Ambiente aislado
- ✅ Mismas dependencias que en desarrollo
- ✅ Más fácil de mantener
- ✅ No contamina el sistema

---

## 🆘 Troubleshooting

### Error persiste después de reinstalar

```bash
# Eliminar completamente node_modules
sudo su - whatsapp -c "cd /opt/whatsapp-api && rm -rf node_modules"

# Limpiar cache de pnpm
sudo su - whatsapp -c "pnpm store prune"

# Reinstalar
sudo su - whatsapp -c "cd /opt/whatsapp-api && pnpm install"

# Reiniciar
sudo su - whatsapp -c "pm2 restart whatsapp-api"
```

### Verificar permisos

```bash
# Asegurar que el usuario whatsapp tenga permisos
sudo chown -R whatsapp:whatsapp /opt/whatsapp-api

# Verificar
ls -la /opt/whatsapp-api
```

### Ver logs detallados de PM2

```bash
# Ver logs con errores
sudo su - whatsapp -c "pm2 logs whatsapp-api --err --lines 100"

# Ver información del proceso
sudo su - whatsapp -c "pm2 info whatsapp-api"
```

### Reinstalar Node.js y pnpm

```bash
# Actualizar Node.js a 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Reinstalar pnpm
sudo corepack enable
sudo corepack prepare pnpm@latest --activate

# Verificar versiones
node --version  # Debe ser v20.x.x
pnpm --version
```

---

## 📊 Comparación: --prod vs Todas

| Aspecto | --prod | Todas las dependencias |
|---------|--------|------------------------|
| **Tamaño** | Menor (~50MB) | Mayor (~80MB) |
| **Velocidad install** | Más rápido | Un poco más lento |
| **Compatibilidad ESM** | ❌ Problemas | ✅ Funciona |
| **Baileys 7.x** | ❌ Falla | ✅ Funciona |
| **Producción** | Tradicional | Recomendado para ESM |

---

## ✅ Checklist de Solución

- [ ] Script `deploy-vps.sh` actualizado
- [ ] Conectado al VPS
- [ ] Navegado a `/opt/whatsapp-api`
- [ ] Eliminado `node_modules` (opcional pero recomendado)
- [ ] Ejecutado `pnpm install` (sin --prod)
- [ ] Reiniciado PM2: `pm2 restart whatsapp-api`
- [ ] Verificado logs sin errores
- [ ] Probado endpoint `/session/status`
- [ ] API respondiendo correctamente

---

## 🎯 Resumen

### Problema
```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'express'
```

### Causa
Instalación con `--prod` (solo producción) no incluye todas las dependencias necesarias para ES Modules.

### Solución
```bash
# Instalar TODAS las dependencias
pnpm install  # Sin --prod
```

### Resultado
✅ Todos los módulos se resuelven correctamente  
✅ Baileys 7.x funciona  
✅ ES Modules funcionan  
✅ API inicia sin errores  

---

**📖 Más info:** Ver `ESM-FIX.md` para detalles sobre ES Modules
