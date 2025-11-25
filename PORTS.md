# 🔌 Configuración de Puertos - Guía Rápida

## 📋 Resumen

El sistema usa **dos tipos de puertos**:

| Tipo | Puerto | Descripción | ¿Se puede cambiar? |
|------|--------|-------------|-------------------|
| **Interno** | `3000` | Puerto dentro del contenedor Docker | ❌ No (hardcoded) |
| **Externo** | `3000` (default) | Puerto expuesto en tu máquina host | ✅ Sí (variable) |

---

## 🎯 Configuración Básica

### Archivo `.env`

```env
# Puerto interno del contenedor (NO CAMBIAR)
PORT=3000

# Puerto externo - CAMBIA ESTE si 3000 está ocupado
EXTERNAL_PORT=3000
```

### Mapeo de Puertos

El mapeo en `docker-compose.yml` es:
```yaml
ports:
  - "${EXTERNAL_PORT:-3000}:3000"
```

Esto significa: `PUERTO_EXTERNO:PUERTO_INTERNO`

---

## 💡 Casos de Uso Comunes

### Caso 1: Puerto 3000 ya está en uso

**Síntoma:**
```
Error: bind: address already in use
```

**Solución:**
```bash
# Editar .env
nano .env

# Cambiar EXTERNAL_PORT
EXTERNAL_PORT=8080

# Reiniciar
docker-compose down
docker-compose up -d
```

**Acceso:**
- Antes: `http://localhost:3000`
- Ahora: `http://localhost:8080`

---

### Caso 2: Múltiples instancias en el mismo servidor

**Escenario:** Quieres correr 2 instancias de WhatsApp API

**Instancia 1:**
```bash
cd /app/whatsapp-instance-1
# .env
EXTERNAL_PORT=3001
docker-compose up -d
```

**Instancia 2:**
```bash
cd /app/whatsapp-instance-2
# .env
EXTERNAL_PORT=3002
docker-compose up -d
```

**Acceso:**
- Instancia 1: `http://localhost:3001`
- Instancia 2: `http://localhost:3002`

---

### Caso 3: Servidor de producción con Nginx

**Configuración:**
```env
# WhatsApp API (no expuesto públicamente)
EXTERNAL_PORT=3000

# Nginx (expuesto públicamente)
NGINX_HTTP_PORT=80
NGINX_HTTPS_PORT=443
```

**Levantar con Nginx:**
```bash
docker-compose --profile with-nginx up -d
```

**Acceso:**
- Directo a API: `http://localhost:3000` (solo desde el servidor)
- A través de Nginx: `https://tu-dominio.com` (público)

---

### Caso 4: Desarrollo local con puerto personalizado

**Configuración:**
```env
EXTERNAL_PORT=5000
```

**Acceso desde Postman/Insomnia:**
```
http://localhost:5000/session/status
```

---

## 🔍 Verificar qué puerto está usando

### Ver configuración actual:
```bash
# Ver variables de entorno
cat .env | grep PORT

# Ver puertos mapeados
docker-compose ps
```

### Ver qué proceso usa un puerto:

**Windows:**
```powershell
netstat -ano | findstr :3000
```

**Linux/Mac:**
```bash
lsof -i :3000
```

---

## 🚨 Errores Comunes

### Error 1: "Cannot assign requested address"

**Causa:** Puerto externo ya está en uso

**Solución:**
```bash
# Cambiar EXTERNAL_PORT en .env
EXTERNAL_PORT=8080
docker-compose up -d
```

---

### Error 2: "Connection refused"

**Causa:** Intentas acceder al puerto interno desde fuera del contenedor

**Incorrecto:**
```bash
# Esto NO funciona desde tu máquina
curl http://localhost:3000  # Si EXTERNAL_PORT=8080
```

**Correcto:**
```bash
# Usa el puerto externo configurado
curl http://localhost:8080  # Si EXTERNAL_PORT=8080
```

---

### Error 3: Health check falla

**Causa:** El health check usa el puerto interno (3000)

**Nota:** El health check SIEMPRE usa el puerto 3000 interno. Esto es correcto y no debe cambiarse.

```yaml
# En docker-compose.yml (NO CAMBIAR)
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:3000/session/status"]
```

---

## 📝 Resumen de Comandos

```bash
# Ver puerto actual
docker-compose ps

# Cambiar puerto y reiniciar
echo "EXTERNAL_PORT=8080" >> .env
docker-compose down
docker-compose up -d

# Cambiar puerto temporalmente (sin editar .env)
EXTERNAL_PORT=8080 docker-compose up -d

# Verificar que funciona
curl http://localhost:8080/session/status
```

---

## 🎓 Conceptos Importantes

### ¿Por qué dos puertos?

1. **Puerto Interno (3000):**
   - Es el puerto donde Node.js escucha DENTRO del contenedor
   - Es un entorno aislado (red de Docker)
   - No necesita cambiar

2. **Puerto Externo (variable):**
   - Es el puerto que expones en tu máquina HOST
   - Es el que usas para acceder desde fuera
   - Puede cambiar según necesites

### Analogía

Piensa en Docker como un edificio:
- **Puerto Interno (3000)**: Número de apartamento (siempre el mismo)
- **Puerto Externo (variable)**: Puerta de entrada al edificio (puede cambiar)

---

## ✅ Checklist de Configuración

- [ ] Copié `.env.example` a `.env`
- [ ] Configuré `EXTERNAL_PORT` según mi necesidad
- [ ] Verifiqué que el puerto no esté en uso: `netstat -ano | findstr :PUERTO`
- [ ] Levanté los servicios: `docker-compose up -d`
- [ ] Verifiqué el acceso: `curl http://localhost:EXTERNAL_PORT/session/status`
- [ ] Actualicé mi documentación/código con el puerto correcto

---

## 🔗 Referencias

- [Documentación de Docker Compose - Ports](https://docs.docker.com/compose/compose-file/compose-file-v3/#ports)
- [Variables de entorno en Docker Compose](https://docs.docker.com/compose/environment-variables/)
- Ver también: `DEPLOYMENT.md` para guía completa de despliegue
