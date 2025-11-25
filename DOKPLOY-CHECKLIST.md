# ✅ Checklist Rápido - Deploy en Dokploy

## 📦 Antes de Empezar

- [ ] Código en GitHub/GitLab
- [ ] Dokploy instalado y accesible
- [ ] URL del repositorio copiada

---

## 🚀 Deployment (15 minutos)

### 1. Crear Proyecto
- [ ] Abrir panel de Dokploy
- [ ] Projects → Create Project
- [ ] Nombre: `whatsapp-api`
- [ ] Create

### 2. Crear Aplicación
- [ ] Add Service → Application
- [ ] Tipo: Docker Compose
- [ ] Nombre: `whatsapp-api-server`
- [ ] Repository URL: `https://github.com/tu-usuario/backend-nodejs-baylei.git`
- [ ] Branch: `main`
- [ ] Compose File: `docker-compose.yml`
- [ ] Create

### 3. Variables de Entorno
- [ ] Ir a pestaña "Environment"
- [ ] Agregar variables:

```
EXTERNAL_PORT=3000
PORT=3000
NODE_ENV=production
API_KEY=[generar con: openssl rand -hex 32]
REDIS_HOST=redis
REDIS_PORT=6379
TZ=America/Caracas
LOG_LEVEL=info
BROWSER_NAME=Delphi Client
AUTO_RECONNECT=true
```

- [ ] Save

### 4. Volúmenes
- [ ] Ir a pestaña "Volumes"
- [ ] Agregar volumen:
  - Name: `whatsapp-sessions`
  - Mount Path: `/app/auth_info`
- [ ] Agregar volumen:
  - Name: `whatsapp-logs`
  - Mount Path: `/app/logs`
- [ ] Save

### 5. Dominio (Opcional)
- [ ] Ir a pestaña "Domains"
- [ ] Add Domain
- [ ] Domain: `whatsapp-api.tudominio.com`
- [ ] Port: `3000`
- [ ] SSL: ✅ Enabled
- [ ] Save
- [ ] Configurar DNS (A record → IP del servidor)

### 6. Deploy
- [ ] Click en "Deploy"
- [ ] Esperar 2-5 minutos
- [ ] Verificar estado: Running ✅

### 7. Verificar
- [ ] Ver logs (debe decir "Servidor corriendo")
- [ ] Probar: `curl https://whatsapp-api.tudominio.com/session/status`
- [ ] Obtener QR: `curl https://whatsapp-api.tudominio.com/session/qr`
- [ ] Escanear QR con WhatsApp

### 8. Auto-Deploy (Opcional)
- [ ] Copiar Webhook URL de Dokploy
- [ ] GitHub → Settings → Webhooks → Add webhook
- [ ] Pegar URL
- [ ] Content type: `application/json`
- [ ] Events: Push
- [ ] Save

---

## 🎯 URLs Importantes

**Panel Dokploy:**
```
https://dokploy.tudominio.com
```

**Tu API:**
```
https://whatsapp-api.tudominio.com
```

**Endpoints:**
```
GET  /session/status
GET  /session/qr
POST /session/reset
POST /message/text
```

---

## 🆘 Si algo falla

**Build failed:**
- [ ] Ver "Build Logs"
- [ ] Verificar que todas las variables estén configuradas

**Container restarting:**
- [ ] Ver "Logs"
- [ ] Verificar volúmenes configurados

**QR no disponible:**
- [ ] Esperar 15 segundos
- [ ] Usar: `POST /session/reset`
- [ ] Ver logs para errores

---

## ✅ Deployment Exitoso

Cuando veas esto, ¡está listo!:

**En Logs:**
```
🚀 Servidor corriendo en http://localhost:3000
🔄 Iniciando conexión con WhatsApp...
📱 Código QR generado
✅ QR convertido a Base64
```

**En Status:**
```json
{
  "success": true,
  "connected": false,
  "state": "disconnected"
}
```

**En QR:**
```json
{
  "success": true,
  "qr": "data:image/png;base64,...",
  "message": "Escanea este código con WhatsApp"
}
```

---

**📖 Guía completa:** Ver `DOKPLOY-PASO-A-PASO.md`
