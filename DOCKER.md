# Docker Deployment Guide

## 🐳 WhatsApp Baileys API - Docker

Esta guía explica cómo construir, ejecutar y desplegar la API de WhatsApp usando Docker.

---

## 📋 Requisitos Previos

- Docker instalado ([Descargar Docker](https://www.docker.com/get-started))
- Docker Compose (incluido con Docker Desktop)
- (Opcional) Cuenta en [Docker Hub](https://hub.docker.com/) para publicar imágenes

---

## 🚀 Inicio Rápido

### Opción 1: Usar Docker Compose (Recomendado)

```bash
# Clonar el repositorio
git clone <tu-repositorio>
cd backend-nodejs-baylei

# Iniciar con docker-compose
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Opción 2: Docker Run Manual

```bash
# Construir la imagen
docker build -t whatsapp-baileys-api .

# Ejecutar el contenedor
docker run -d \
  --name whatsapp-api \
  -p 3000:3000 \
  -v $(pwd)/auth_info:/app/auth_info \
  whatsapp-baileys-api

# Ver logs
docker logs -f whatsapp-api
```

---

## ⚙️ Variables de Entorno

| Variable | Descripción | Valor por Defecto |
|----------|-------------|-------------------|
| `PORT` | Puerto del servidor | `3000` |
| `NODE_ENV` | Entorno de ejecución | `production` |
| `TZ` | Zona horaria | `America/Caracas` |

### Ejemplo con Puerto Personalizado

```bash
# Docker Compose
PORT=8080 docker-compose up -d

# Docker Run
docker run -d \
  --name whatsapp-api \
  -p 8080:8080 \
  -e PORT=8080 \
  -v $(pwd)/auth_info:/app/auth_info \
  whatsapp-baileys-api
```

---

## 💾 Persistencia de Datos

La sesión de WhatsApp se guarda en el directorio `auth_info`. Para mantener la sesión entre reinicios del contenedor, usa volúmenes:

```bash
# Crear volumen nombrado
docker volume create whatsapp-session

# Usar el volumen
docker run -d \
  --name whatsapp-api \
  -p 3000:3000 \
  -v whatsapp-session:/app/auth_info \
  whatsapp-baileys-api
```

---

## 🔄 Actualización de la Imagen

```bash
# Detener contenedor actual
docker-compose down

# Actualizar código
git pull

# Reconstruir y reiniciar
docker-compose up -d --build
```

---

## 🌐 Despliegue en Producción

### Usar Imagen de Docker Hub

Una vez configurado GitHub Actions, puedes usar la imagen publicada:

```bash
docker pull <tu-usuario>/whatsapp-baileys-api:latest

docker run -d \
  --name whatsapp-api \
  --restart unless-stopped \
  -p 3000:3000 \
  -v whatsapp-session:/app/auth_info \
  <tu-usuario>/whatsapp-baileys-api:latest
```

### Docker Compose con Imagen Remota

```yaml
version: '3.8'

services:
  whatsapp-api:
    image: <tu-usuario>/whatsapp-baileys-api:latest
    container_name: whatsapp-baileys-api
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - NODE_ENV=production
    volumes:
      - whatsapp-session:/app/auth_info

volumes:
  whatsapp-session:
```

---

## 🔧 GitHub Actions - CI/CD

### Configuración de Secretos

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Agrega los siguientes secretos:

| Secret | Descripción |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Tu usuario de Docker Hub |
| `DOCKERHUB_TOKEN` | Token de acceso de Docker Hub ([Crear aquí](https://hub.docker.com/settings/security)) |

### Publicación Automática

La imagen se publica automáticamente cuando:

- **Push a `main`/`master`**: Crea tag `latest`
- **Tag de versión** (ej: `v1.0.0`): Crea tags `1.0.0`, `1.0`, `1`, `latest`

```bash
# Crear y publicar una nueva versión
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions construirá y publicará automáticamente
```

---

## 🩺 Health Check

El contenedor incluye un health check que verifica el endpoint `/session/status` cada 30 segundos.

```bash
# Ver estado de salud
docker inspect --format='{{.State.Health.Status}}' whatsapp-api
```

---

## 📊 Monitoreo y Logs

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de las últimas 100 líneas
docker-compose logs --tail=100

# Ver logs de un servicio específico
docker logs -f whatsapp-api
```

---

## 🛠️ Troubleshooting

### El contenedor no inicia

```bash
# Ver logs de error
docker logs whatsapp-api

# Verificar que el puerto no esté en uso
netstat -an | grep 3000
```

### Sesión se pierde al reiniciar

Asegúrate de que el volumen esté correctamente montado:

```bash
# Verificar volúmenes
docker volume ls

# Inspeccionar contenedor
docker inspect whatsapp-api | grep -A 10 Mounts
```

### Reconstruir desde cero

```bash
# Eliminar contenedor y volúmenes
docker-compose down -v

# Reconstruir sin caché
docker-compose build --no-cache

# Iniciar
docker-compose up -d
```

---

## 📱 Endpoints Disponibles

Una vez que el contenedor esté corriendo, los endpoints estarán disponibles en:

- `GET http://localhost:3000/session/qr` - Obtener código QR
- `GET http://localhost:3000/session/status` - Estado de conexión
- `POST http://localhost:3000/message/text` - Enviar texto
- `POST http://localhost:3000/message/image` - Enviar imagen
- `POST http://localhost:3000/message/doc` - Enviar documento
- `POST http://localhost:3000/message/audio` - Enviar audio
- `POST http://localhost:3000/session/logout` - Cerrar sesión
- `GET/POST http://localhost:3000/session/reset` - Resetear sesión

---

## 🔐 Seguridad

- El contenedor ejecuta como usuario no-root (`whatsapp:whatsapp`)
- Usa `dumb-init` para manejar señales correctamente
- Imagen basada en Alpine Linux (ligera y segura)
- Multi-stage build para reducir superficie de ataque

---

## 📦 Tamaño de Imagen

La imagen optimizada tiene aproximadamente **150-200 MB** gracias a:

- Base Alpine Linux
- Multi-stage build
- Exclusión de archivos innecesarios vía `.dockerignore`

---

## 🤝 Contribuir

Para contribuir al proyecto, por favor:

1. Fork el repositorio
2. Crea una rama para tu feature
3. Haz commit de tus cambios
4. Push a la rama
5. Abre un Pull Request

---

## 📄 Licencia

[Especificar licencia del proyecto]

---

## 📞 Soporte

Para problemas o preguntas:
- Abre un issue en GitHub
- Contacto: contacto@ecomunik2.com
