# 🟢 Backend Node.js - WhatsApp API con Baileys

API REST para enviar mensajes de WhatsApp usando Baileys.

---

## 🚀 Quick Start

```bash
# Instalar dependencias
npm install

# Iniciar servidor
npm start

# Servidor corriendo en http://localhost:3000
```

---

## 📁 Archivos

- `baileys-server.js` - Servidor principal (~350 líneas)
- `package.json` - Dependencias
- `.env.example` - Variables de entorno
- `Dockerfile` - Imagen Docker
- `docker-compose.yml` - Stack completo
- `nginx.conf` - Reverse proxy
- `deployment/` - Scripts de deployment

---

## 🔌 Endpoints

### GET /session/qr
Obtener código QR para autenticación

### GET /session/status  
Ver estado de conexión

### POST /message/text
Enviar mensaje de texto
```json
{"number": "573001234567", "text": "Hola"}
```

### POST /message/image
Enviar imagen con caption
```json
{"number": "573001234567", "image": "base64...", "fileName": "foto.jpg", "caption": "Mira"}
```

### POST /message/doc
Enviar documento (PDF, DOC, etc.)

### POST /message/audio
Enviar nota de voz

### POST /session/logout
Cerrar sesión

---

## ⚙️ Configuración

### Variables de Entorno

```bash
# Crear .env
cp .env.example .env

# Editar
nano .env
```

```env
# Puerto interno del contenedor
PORT=3000

# Puerto externo (para Docker)
EXTERNAL_PORT=3000

# Seguridad
API_KEY=tu-clave-secreta
```

### Cambiar Puerto

**Desarrollo (sin Docker):**
```bash
PORT=8080 npm start
```

**Docker (puerto externo):**
```bash
# Editar .env
EXTERNAL_PORT=8080

# Reiniciar
docker-compose down && docker-compose up -d
```

> 📖 **Más info:** Ver `PORTS.md` para guía completa de puertos


---

## 🐳 Docker

```bash
# Stack completo con docker-compose
docker-compose up -d

# Solo API
docker run -p 3000:3000 -e PORT=3000 whatsapp-api

# Con puerto personalizado
docker run -p 8080:8080 -e PORT=8080 whatsapp-api
```

📖 **Guía completa:** Ver `DOCKER.md` para deployment, CI/CD y publicación en Docker Hub

---

## 🌐 Deployment

### Dokploy (⭐ Recomendado)
```bash
# Ver guía completa en DOKPLOY.md
# Deploy automático con SSL, monitoreo y auto-deploy desde Git
```
📖 **Guía completa:** Ver `DOKPLOY.md`

### Docker Compose
```bash
# Deploy rápido con Docker
docker-compose up -d
```

### VPS Manual
```bash
chmod +x deployment/deploy-vps.sh
sudo ./deployment/deploy-vps.sh
```

### Otras opciones
- **Heroku**: `git push heroku main`
- **Railway**: Conectar repo de GitHub
- **Render**: Deploy desde dashboard


---

## 📚 Documentación

### 🚀 Deployment
- **DOKPLOY-PASO-A-PASO.md** - 📖 Guía completa paso a paso para Dokploy
- **DOKPLOY-CHECKLIST.md** - ✅ Checklist rápido de deployment
- **DOKPLOY.md** - 📘 Guía detallada de Dokploy
- **DEPLOYMENT.md** - 🐳 Opciones de deployment con Docker

### 🔧 Configuración
- **PORTS.md** - 🔌 Configuración de puertos
- **TROUBLESHOOTING.md** - 🆘 Solución de problemas
- **RESUMEN.md** - 📋 Resumen ejecutivo del proyecto

### 📝 Referencia
- **dokploy.config.env** - Configuración de variables para Dokploy
- **.env.example** - Plantilla de variables de entorno

---

## 🔧 Testing

```bash
# Estado
curl http://localhost:3000/session/status

# Enviar mensaje
curl -X POST http://localhost:3000/message/text \
  -H "Content-Type: application/json" \
  -d '{"number":"573001234567","text":"Hola"}'
```

---

## 📊 Monitoreo con PM2

```bash
pm2 start baileys-server.js --name whatsapp-api
pm2 logs whatsapp-api
pm2 monit
```

---

## 🙏 Créditos

- **Baileys:** github.com/WhiskeySockets/Baileys
- **Express:** expressjs.com

---

**¿Dudas?** Ver `../docs/TROUBLESHOOTING.md`
