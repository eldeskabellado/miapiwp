# 📋 Resumen de Configuración - WhatsApp API Backend

## ✅ Archivos Creados/Actualizados

### 📄 Documentación
- ✅ **DOKPLOY.md** - Guía completa de deployment con Dokploy
- ✅ **DEPLOYMENT.md** - Guía general de deployment con Docker
- ✅ **PORTS.md** - Configuración de puertos (interno vs externo)
- ✅ **TROUBLESHOOTING.md** - Solución de problemas comunes
- ✅ **dokploy.config.env** - Configuración de referencia para Dokploy

### 🔧 Configuración
- ✅ **Dockerfile** - Actualizado para copiar todo el código fuente
- ✅ **docker-compose.yml** - Puertos externos variables
- ✅ **.dockerignore** - Optimización del build
- ✅ **.gitignore** - Protección de datos sensibles
- ✅ **.env.example** - Variables de entorno documentadas

### 💻 Código
- ✅ **baileys-server.js** - Nuevo endpoint `/session/reset`

---

## 🎯 Características Implementadas

### 🔌 Puertos Configurables
```env
# Puerto interno (fijo)
PORT=3000

# Puerto externo (variable)
EXTERNAL_PORT=3000  # Cambia según necesites
```

**Mapeo:** `EXTERNAL_PORT:3000`

### 🔄 Nuevo Endpoint: Reset de Sesión
```bash
POST /session/reset
```
Elimina la sesión actual y genera un nuevo QR.

### 📦 Deployment Optimizado
- Multi-stage Docker build
- Usuario no-root (seguridad)
- Health checks configurados
- Volúmenes persistentes para sesiones
- SSL automático con Dokploy

---

## 🚀 Opciones de Deployment

### 1️⃣ Dokploy (⭐ Recomendado)
**Ventajas:**
- ✅ Deploy automático desde Git
- ✅ SSL gratis con Let's Encrypt
- ✅ Panel de control visual
- ✅ Logs en tiempo real
- ✅ Monitoreo de recursos
- ✅ Rollback fácil

**Guía:** Ver `DOKPLOY.md`

**Costo:** ~$5-12/mes (VPS)

### 2️⃣ Docker Compose Local
```bash
cp .env.example .env
# Editar .env
docker-compose up -d
```

### 3️⃣ VPS Manual
```bash
git clone <repo>
cd backend-nodejs-baylei
cp .env.example .env
docker-compose up -d
```

---

## 🔑 Variables de Entorno Importantes

### Mínimas Requeridas
```env
PORT=3000
EXTERNAL_PORT=3000
API_KEY=tu-clave-secreta
NODE_ENV=production
```

### Completas (Recomendado)
```env
# Puertos
PORT=3000
EXTERNAL_PORT=3000

# Seguridad
API_KEY=genera-con-openssl-rand-hex-32

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Configuración
NODE_ENV=production
TZ=America/Caracas

# WhatsApp
BROWSER_NAME=Delphi Client
BROWSER_VERSION=1.0.0
AUTO_RECONNECT=true

# Logs
LOG_LEVEL=info
FILE_LOGGING=true
```

---

## 📱 Endpoints Disponibles

### Sesión
```bash
GET  /session/qr      # Obtener código QR
GET  /session/status  # Estado de conexión
POST /session/logout  # Cerrar sesión
POST /session/reset   # 🆕 Resetear y generar nuevo QR
```

### Mensajes
```bash
POST /message/text    # Enviar texto
POST /message/image   # Enviar imagen
POST /message/doc     # Enviar documento
POST /message/audio   # Enviar audio
```

---

## 🔧 Solución al Error "QR no disponible"

### Problema
```json
{
  "success": false,
  "error": "Código QR no disponible aún"
}
```

### Solución Rápida
```bash
# Opción 1: Usar el nuevo endpoint
curl -X POST http://localhost:3000/session/reset

# Opción 2: Manual
# 1. Detener servidor (Ctrl+C)
# 2. Eliminar carpeta auth_info
# 3. Reiniciar servidor
```

### En PowerShell
```powershell
# Resetear sesión
Invoke-WebRequest -Uri http://localhost:3000/session/reset -Method POST

# Esperar 10 segundos

# Obtener QR
Invoke-WebRequest -Uri http://localhost:3000/session/qr
```

---

## 📊 Flujo de Trabajo Recomendado

### Desarrollo Local
```bash
# 1. Clonar repo
git clone <repo>
cd backend-nodejs-baylei

# 2. Instalar dependencias
pnpm install

# 3. Configurar entorno
cp .env.example .env
# Editar .env

# 4. Iniciar
pnpm start

# 5. Obtener QR
curl http://localhost:3000/session/qr
```

### Producción con Dokploy
```bash
# 1. Instalar Dokploy en VPS
curl -sSL https://dokploy.com/install.sh | sh

# 2. Acceder al panel
https://tu-servidor-ip:3000

# 3. Crear proyecto y aplicación
# - Conectar repositorio Git
# - Configurar variables de entorno
# - Configurar dominio (opcional)

# 4. Deploy
# Click en "Deploy"

# 5. Acceder
https://whatsapp-api.tudominio.com/session/qr
```

---

## 🔒 Seguridad

### ✅ Implementado
- Usuario no-root en Docker
- `.env` en `.gitignore`
- `.dockerignore` para excluir sensibles
- Health checks
- Multi-stage build

### 📝 Recomendaciones Adicionales
1. **Generar API_KEY fuerte**
   ```bash
   openssl rand -hex 32
   ```

2. **Configurar firewall**
   ```bash
   ufw allow 22,80,443/tcp
   ufw enable
   ```

3. **Usar HTTPS** (automático con Dokploy)

4. **Backups regulares** de `auth_info/`

5. **Monitorear logs** regularmente

---

## 📁 Estructura del Proyecto

```
backend-nodejs-baylei/
├── 📄 baileys-server.js       # Servidor principal
├── 📦 package.json            # Dependencias
├── 🐳 Dockerfile              # Imagen Docker optimizada
├── 🐳 docker-compose.yml      # Stack completo
├── 🔧 .dockerignore           # Optimización build
├── 🔒 .gitignore              # Protección datos
├── 📝 .env.example            # Variables de entorno
├── 📚 README.md               # Documentación principal
├── 📚 DOKPLOY.md              # Guía Dokploy
├── 📚 DEPLOYMENT.md           # Guía deployment
├── 📚 PORTS.md                # Guía puertos
├── 📚 TROUBLESHOOTING.md      # Solución problemas
├── 🔧 dokploy.config.env      # Config Dokploy
├── 🌐 nginx.conf              # Reverse proxy
└── 📁 deployment/             # Scripts deployment
```

---

## 🎓 Próximos Pasos

### Para Desarrollo
1. ✅ Eliminar carpeta `auth_info` si existe
2. ✅ Reiniciar servidor
3. ✅ Obtener QR con `/session/qr`
4. ✅ Escanear con WhatsApp
5. ✅ Probar endpoints

### Para Producción
1. ✅ Leer `DOKPLOY.md`
2. ✅ Contratar VPS (Hetzner recomendado)
3. ✅ Instalar Dokploy
4. ✅ Configurar dominio (opcional)
5. ✅ Deploy desde Git
6. ✅ Configurar variables de entorno
7. ✅ Configurar volúmenes persistentes
8. ✅ Habilitar SSL
9. ✅ Configurar webhook de GitHub
10. ✅ Monitorear y mantener

---

## 💡 Tips Importantes

### 1. Sesiones de WhatsApp
- La carpeta `auth_info/` contiene las credenciales
- **Debe ser persistente** (volumen Docker)
- **Hacer backups** regularmente
- **No subir al repositorio** (ya en `.gitignore`)

### 2. Puertos
- **Puerto interno**: Siempre 3000 (no cambiar)
- **Puerto externo**: Variable con `EXTERNAL_PORT`
- Si 3000 está ocupado: `EXTERNAL_PORT=8080`

### 3. QR Code
- Se genera al iniciar si no hay sesión
- Expira después de ~30 segundos
- Usar `/session/reset` si hay problemas
- Una vez escaneado, no se necesita más

### 4. Logs
- Ver en tiempo real: `docker logs -f whatsapp-api`
- Guardar en archivo: `FILE_LOGGING=true`
- Nivel de detalle: `LOG_LEVEL=info`

### 5. Monitoreo
- Endpoint de health: `/session/status`
- Verificar estado: `connected: true/false`
- Monitorear recursos en Dokploy

---

## 🆘 Soporte

### Documentación
- **General**: `README.md`
- **Deployment**: `DEPLOYMENT.md`
- **Dokploy**: `DOKPLOY.md`
- **Puertos**: `PORTS.md`
- **Problemas**: `TROUBLESHOOTING.md`

### Comandos Rápidos
```bash
# Ver estado
curl http://localhost:3000/session/status

# Resetear sesión
curl -X POST http://localhost:3000/session/reset

# Ver logs
docker logs -f whatsapp-api

# Reiniciar
docker-compose restart whatsapp-api
```

---

## ✅ Checklist Final

### Desarrollo
- [ ] Dependencias instaladas (`pnpm install`)
- [ ] `.env` configurado
- [ ] Servidor corriendo (`pnpm start`)
- [ ] QR obtenido y escaneado
- [ ] Mensajes de prueba enviados

### Producción
- [ ] VPS configurado
- [ ] Dokploy instalado
- [ ] Dominio configurado (opcional)
- [ ] Variables de entorno configuradas
- [ ] Volúmenes persistentes configurados
- [ ] SSL habilitado
- [ ] Webhook de GitHub configurado
- [ ] Backups configurados
- [ ] Monitoreo activo

---

**¡Todo listo para desplegar tu WhatsApp API! 🚀**

Para deployment con Dokploy, consulta la guía completa en `DOKPLOY.md`.
