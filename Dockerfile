# ============================================================================
# Multi-stage Dockerfile para WhatsApp API
# Optimizado para producción
# ============================================================================

# Stage 1: Builder
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias (incluyendo devDependencies para build)
RUN npm ci --only=production && \
    npm cache clean --force

# Stage 2: Producción
FROM node:18-alpine

# Metadata
LABEL maintainer="Descabellado <contacto@ecomunik2.com>"
LABEL description="WhatsApp API Server con Baileys"
LABEL version="1.0.0"

# Variables de entorno por defecto
ENV NODE_ENV=production \
    PORT=3000 \
    TZ=America/Caracas

# Instalar dependencias del sistema
RUN apk add --no-cache \
    curl \
    tzdata \
    dumb-init

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S whatsapp && \
    adduser -S -u 1001 -G whatsapp whatsapp

# Crear directorio de aplicación
WORKDIR /app

# Copiar dependencias desde builder
COPY --from=builder --chown=whatsapp:whatsapp /app/node_modules ./node_modules

# Copiar código de la aplicación
COPY --chown=whatsapp:whatsapp baileys-server.js .
COPY --chown=whatsapp:whatsapp package.json .

# Crear directorios necesarios
RUN mkdir -p auth_info logs && \
    chown -R whatsapp:whatsapp /app

# Cambiar a usuario no-root
USER whatsapp

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/session/status', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# Usar dumb-init para manejar señales correctamente
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Iniciar aplicación
CMD ["node", "baileys-server.js"]
