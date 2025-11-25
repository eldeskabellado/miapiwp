# 🚀 Guía de Despliegue con Docker

## Cambios Realizados

### ✅ Dockerfile Actualizado
- **Antes**: Copiaba solo archivos específicos (`baileys-server.js`, `package.json`)
- **Ahora**: Copia todo el código fuente con `COPY . .`
- **Beneficio**: Compatible con despliegue desde repositorio Git

### ✅ Nuevo archivo `.dockerignore`
Excluye archivos innecesarios del build:
- `node_modules` (se instalan durante el build)
- Archivos `.env` (sensibles)
- Logs y datos temporales
- Archivos de Git y documentación
- Reduce el tamaño del contexto y mejora la velocidad de build

### ✅ `.gitignore` Mejorado
Ahora ignora:
- Carpeta `auth_info/` (sesiones de WhatsApp)
- Logs
- Archivos de sistema
- Configuraciones de IDEs

---

## 📦 Despliegue desde Repositorio

### Opción 1: Build Local
```bash
# Clonar el repositorio
git clone <tu-repositorio-url>
cd backend-nodejs-baylei

# Crear archivo .env (copiar desde .env.example)
cp .env.example .env
# Editar .env con tus credenciales

# Build de la imagen
docker build -t whatsapp-api:latest .

# Ejecutar con docker-compose
docker-compose up -d
```

### Opción 2: Docker Compose Directo
```bash
# Clonar y configurar
git clone <tu-repositorio-url>
cd backend-nodejs-baylei
cp .env.example .env

# Editar .env con tus valores
nano .env  # o usa tu editor preferido

# Levantar servicios (build automático)
docker-compose up -d --build
```

### Opción 3: Servidor de Producción
```bash
# En el servidor
git clone <tu-repositorio-url>
cd backend-nodejs-baylei

# Configurar variables de entorno
cp .env.example .env
nano .env

# Build y deploy
docker-compose -f docker-compose.yml up -d --build

# Ver logs
docker-compose logs -f whatsapp-api
```

---

## 🔧 Variables de Entorno Importantes

Asegúrate de configurar en tu `.env`:

```env
# ============================================================================
# PUERTOS
# ============================================================================

# Puerto interno del contenedor (NO CAMBIAR)
PORT=3000

# Puerto externo expuesto en el host
# Cambia este valor si el puerto 3000 ya está en uso
EXTERNAL_PORT=3000

# Puertos de Nginx (solo si usas: docker-compose --profile with-nginx up)
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443

# ============================================================================
# SEGURIDAD
# ============================================================================

# API Key para autenticación (genera una clave segura)
# Genera con: openssl rand -hex 32
API_KEY=changeme-generate-a-secure-random-key-here

# ============================================================================
# REDIS
# ============================================================================

REDIS_HOST=redis
REDIS_PORT=6379
```

### 📌 Ejemplos de Configuración de Puertos

**Ejemplo 1: Puerto 3000 ya está en uso**
```env
EXTERNAL_PORT=8080
```
Accede a la API en: `http://localhost:8080`

**Ejemplo 2: Múltiples instancias en el mismo servidor**
```env
# Instancia 1
EXTERNAL_PORT=3001

# Instancia 2 (en otro directorio)
EXTERNAL_PORT=3002
```

**Ejemplo 3: Con Nginx en puertos alternativos**
```env
EXTERNAL_PORT=3000
NGINX_HTTP_PORT=8080
NGINX_HTTPS_PORT=8443
```


---

## 🐳 Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f

# Reiniciar servicio
docker-compose restart whatsapp-api

# Detener servicios
docker-compose down

# Detener y eliminar volúmenes (⚠️ borra datos)
docker-compose down -v

# Rebuild forzado
docker-compose build --no-cache
docker-compose up -d

# Ver estado de contenedores
docker-compose ps

# Ejecutar comandos dentro del contenedor
docker-compose exec whatsapp-api sh
```

---

## 📊 Verificación del Despliegue

1. **Health Check**:
   ```bash
   curl http://localhost:3000/session/status
   ```

2. **Ver logs**:
   ```bash
   docker-compose logs whatsapp-api
   ```

3. **Verificar base de datos**:
   ```bash
   docker-compose exec postgres psql -U baylei_user -d baylei_db
   ```

---

## 🔒 Seguridad

- ✅ El contenedor corre con usuario no-root (`whatsapp:1001`)
- ✅ `.env` está en `.gitignore` (no se sube al repo)
- ✅ `.dockerignore` excluye archivos sensibles
- ✅ Health check configurado
- ✅ Multi-stage build para imagen optimizada

---

## 📝 Notas Importantes

1. **Nunca subas el archivo `.env` al repositorio**
2. **La carpeta `auth_info/` contiene sesiones de WhatsApp** - no la subas al repo
3. **Usa volúmenes de Docker** para persistir datos importantes
4. **Configura backups** para la base de datos en producción

---

## 🆘 Troubleshooting

### Error: "Cannot find module"
```bash
# Rebuild sin cache
docker-compose build --no-cache
docker-compose up -d
```

### Error: "Port already in use"
```bash
# Opción 1: Cambiar puerto externo en .env
echo "EXTERNAL_PORT=8080" >> .env
docker-compose up -d

# Opción 2: Cambiar puerto temporalmente
EXTERNAL_PORT=8080 docker-compose up -d

# Opción 3: Detener el servicio que usa el puerto
# En Windows
netstat -ano | findstr :3000
# Luego terminar el proceso con: taskkill /PID <PID> /F

# En Linux/Mac
lsof -i :3000
# Luego terminar con: kill -9 <PID>
```

### Error de conexión a base de datos
```bash
# Verificar que postgres esté corriendo
docker-compose ps

# Ver logs de postgres
docker-compose logs postgres

# Verificar variables de entorno
docker-compose exec whatsapp-api env | grep DB_
```

---

## 🎯 Resumen

**Sí, era necesario adecuar el Dockerfile** para despliegue desde repositorio. Los cambios realizados:

1. ✅ `COPY . .` en lugar de copiar archivos específicos
2. ✅ `.dockerignore` para optimizar el build
3. ✅ `.gitignore` mejorado para proteger datos sensibles
4. ✅ Mantiene todas las buenas prácticas de seguridad

Ahora puedes clonar el repositorio en cualquier servidor y hacer deploy directamente con `docker-compose up -d --build`.
