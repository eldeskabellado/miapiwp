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
PORT=3000
NODE_ENV=production
API_KEY=tu-clave-secreta
```

### Cambiar Puerto

```bash
PORT=8080 npm start
```

---

## 🐳 Docker

```bash
# Stack completo
docker-compose up -d

# Solo API
docker run -p 3000:3000 whatsapp-api
```

---

## 🌐 Deployment

### VPS Automático
```bash
chmod +x deployment/deploy-vps.sh
sudo ./deployment/deploy-vps.sh
```

### Dokploy (Recomendado)
Ver: `../docs/DOKPLOY.md`

### Heroku
```bash
heroku create
git push heroku main
```

---

## 📚 Documentación

**Ver carpeta `../docs/`:**
- QUICKSTART.md - Setup rápido
- DEPLOYMENT.md - Opciones de hosting
- DOKPLOY.md - Deploy con Dokploy ⭐
- DOCKER.md - Contenedores
- CAMBIAR-PUERTO.md - Puertos
- TROUBLESHOOTING.md - Problemas

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
