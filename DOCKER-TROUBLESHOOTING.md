# 🐳 Troubleshooting Docker Build - WhatsApp API

## ❌ Error: "npm ci requires package-lock.json"

### Síntoma
```
npm error `npm ci` can only install packages when your package.json and package-lock.json or
npm error npm-shrinkwrap.json with lockfileVersion >= 1
ERROR: failed to build: exit code: 1
```

### Causa
El proyecto usa **pnpm** (tiene `pnpm-lock.yaml`) pero el Dockerfile estaba configurado para **npm** (requiere `package-lock.json`).

### ✅ Solución (Ya Aplicada)

El Dockerfile ha sido actualizado para usar **pnpm**:

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder

# Instalar pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json pnpm-lock.yaml ./

# Instalar dependencias de producción
RUN pnpm install --frozen-lockfile --prod && \
    pnpm store prune
```

### Verificar que Funciona

```bash
# Build de la imagen
docker-compose build

# Si funciona, deberías ver:
# => [builder 4/4] RUN pnpm install --frozen-lockfile --prod
# => [stage-1 8/8] COPY --from=builder --chown=whatsapp:whatsapp /app/node_modules ./node_modules
# => Successfully built
```

---

## 🔄 Opciones Alternativas

### Opción 1: Usar pnpm (Recomendado - Ya implementado)

**Ventajas:**
- ✅ Usa el lockfile existente (`pnpm-lock.yaml`)
- ✅ Más rápido
- ✅ Menos espacio en disco
- ✅ No requiere cambios en el proyecto

**Desventajas:**
- ⚠️ Requiere Node.js 16.13+ con corepack

### Opción 2: Generar package-lock.json y usar npm

Si prefieres usar npm, genera el lockfile:

```bash
# Generar package-lock.json
npm install --package-lock-only

# Agregar al repositorio
git add package-lock.json
git commit -m "Add package-lock.json for npm compatibility"
git push
```

Luego usa este Dockerfile alternativo:

```dockerfile
# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias de producción
RUN npm ci --omit=dev && \
    npm cache clean --force
```

### Opción 3: Usar yarn

```bash
# Generar yarn.lock
yarn install

# Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --production && \
    yarn cache clean
```

---

## 🐛 Otros Errores Comunes de Docker Build

### Error: "COPY failed: file not found"

**Causa:** Archivo especificado en COPY no existe

**Solución:**
```bash
# Verificar que los archivos existan
ls -la package.json pnpm-lock.yaml

# Si falta pnpm-lock.yaml
pnpm install  # Esto lo genera
```

### Error: "corepack: command not found"

**Causa:** Versión de Node.js muy antigua

**Solución:**
```dockerfile
# Usar Node.js 18 o superior
FROM node:18-alpine AS builder

# O instalar corepack manualmente
RUN npm install -g corepack
RUN corepack enable
```

### Error: "permission denied"

**Causa:** Problemas de permisos en Docker

**Solución:**
```dockerfile
# Asegurarse de usar --chown en COPY
COPY --chown=whatsapp:whatsapp . .

# O cambiar permisos después
RUN chown -R whatsapp:whatsapp /app
```

### Error: "ENOSPC: no space left on device"

**Causa:** Disco lleno en Docker

**Solución:**
```bash
# Limpiar imágenes no usadas
docker system prune -a

# Limpiar volúmenes
docker volume prune

# Ver espacio usado
docker system df
```

---

## 🔍 Debugging del Build

### Ver logs detallados

```bash
# Build con logs completos
docker-compose build --no-cache --progress=plain

# Build de una imagen específica
docker build -t whatsapp-api:debug .
```

### Entrar a una etapa intermedia

```bash
# Build hasta cierta etapa
docker build --target builder -t whatsapp-api:builder .

# Entrar al contenedor
docker run -it whatsapp-api:builder sh

# Verificar archivos
ls -la
cat package.json
```

### Verificar el contexto de build

```bash
# Ver qué archivos se envían a Docker
docker build --no-cache --progress=plain . 2>&1 | grep "COPY"

# Verificar .dockerignore
cat .dockerignore
```

---

## ✅ Checklist de Build Exitoso

- [ ] Dockerfile actualizado para usar pnpm
- [ ] `pnpm-lock.yaml` existe en el proyecto
- [ ] `.dockerignore` configurado correctamente
- [ ] Build sin errores: `docker-compose build`
- [ ] Imagen creada: `docker images | grep whatsapp`
- [ ] Contenedor inicia: `docker-compose up -d`
- [ ] Logs sin errores: `docker-compose logs whatsapp-api`
- [ ] Health check OK: `docker ps` (debe mostrar "healthy")

---

## 🚀 Comandos Útiles

```bash
# Build limpio (sin cache)
docker-compose build --no-cache

# Build y levantar
docker-compose up -d --build

# Ver logs del build
docker-compose build 2>&1 | tee build.log

# Verificar imagen creada
docker images whatsapp-api

# Ver tamaño de la imagen
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep whatsapp

# Entrar al contenedor corriendo
docker-compose exec whatsapp-api sh

# Ver estructura de la imagen
docker history whatsapp-api:latest
```

---

## 📊 Comparación de Package Managers

| Feature | npm | pnpm | yarn |
|---------|-----|------|------|
| **Lockfile** | package-lock.json | pnpm-lock.yaml | yarn.lock |
| **Velocidad** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Espacio** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Compatibilidad** | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| **Docker** | Nativo | Requiere corepack | Nativo |

**Recomendación:** Usar **pnpm** (ya configurado)

---

## 🎯 Resumen

### Problema Original
```
ERROR: npm ci requires package-lock.json
```

### Solución Aplicada
✅ Dockerfile actualizado para usar **pnpm**

### Verificar
```bash
docker-compose build
docker-compose up -d
docker-compose logs -f whatsapp-api
```

### Si aún falla
1. Ver logs: `docker-compose build --progress=plain`
2. Verificar archivos: `ls -la package.json pnpm-lock.yaml`
3. Limpiar cache: `docker system prune -a`
4. Rebuild: `docker-compose build --no-cache`

---

**📖 Más info:** Ver `DEPLOYMENT.md` para guía completa de Docker
