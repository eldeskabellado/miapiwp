# 🚀 Upgrade a Node.js 20 LTS

## ✅ Cambios Realizados

### 📦 Versión Actualizada

**Antes:** Node.js 18 LTS  
**Ahora:** Node.js 20 LTS (Iron)

### 🎯 Beneficios de Node.js 20

1. **Mejor Rendimiento**
   - Motor V8 11.3 (más rápido)
   - Mejor gestión de memoria
   - Optimizaciones en async/await

2. **Nuevas Características**
   - Test runner nativo mejorado
   - Mejor soporte para ES Modules
   - Fetch API estable
   - WebStreams API

3. **Seguridad**
   - Actualizaciones de seguridad más recientes
   - Mejor manejo de vulnerabilidades
   - Soporte hasta Abril 2026

4. **Compatibilidad**
   - Totalmente compatible con Baileys 7.x
   - Mejor soporte para pnpm
   - Corepack incluido por defecto

---

## 📋 Archivos Actualizados

### 1. **Dockerfile**
```dockerfile
# ANTES
FROM node:18-alpine AS builder
FROM node:18-alpine

# AHORA
FROM node:20-alpine AS builder
FROM node:20-alpine
```

### 2. **package.json**
```json
// ANTES
"engines": {
  "node": ">=16.0.0",
  "npm": ">=8.0.0"
}

// AHORA
"engines": {
  "node": ">=18.0.0",
  "npm": ">=9.0.0"
}
```

### 3. **deploy-vps.sh**
```bash
# ANTES
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

# AHORA
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
```

**Bonus:** El script ahora detecta si tienes una versión antigua y la actualiza automáticamente.

---

## 🔄 Cómo Actualizar

### Desarrollo Local (Windows)

#### Opción 1: Usando nvm-windows (Recomendado)

```powershell
# Instalar nvm-windows si no lo tienes
# Descargar de: https://github.com/coreybutler/nvm-windows/releases

# Instalar Node.js 20
nvm install 20

# Usar Node.js 20
nvm use 20

# Verificar
node --version  # Debe mostrar v20.x.x
```

#### Opción 2: Instalador Oficial

1. Descargar de: https://nodejs.org/en/download/
2. Seleccionar "20.x.x LTS"
3. Instalar
4. Verificar: `node --version`

#### Después de actualizar Node.js:

```powershell
# Reinstalar dependencias
Remove-Item -Path "node_modules" -Recurse -Force
pnpm install

# Verificar que funciona
pnpm start
```

---

### Docker

```bash
# Rebuild de la imagen con Node.js 20
docker-compose build --no-cache

# Levantar servicios
docker-compose up -d

# Verificar versión
docker-compose exec whatsapp-api node --version
```

---

### VPS / Servidor Linux

#### Usando el script de deployment:

```bash
# El script detecta automáticamente y actualiza
sudo bash deploy-vps.sh
```

#### Manualmente:

```bash
# Actualizar repositorio de NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -

# Instalar/Actualizar Node.js
sudo apt install -y nodejs

# Verificar
node --version  # Debe mostrar v20.x.x

# Reinstalar dependencias
cd /opt/whatsapp-api
pnpm install

# Reiniciar servicio
sudo su - whatsapp -c 'pm2 restart whatsapp-api'
```

---

### Dokploy

**No requiere acción manual.** Dokploy usará automáticamente Node.js 20 en el próximo deployment porque el Dockerfile ya está actualizado.

Simplemente:
```bash
git add .
git commit -m "Upgrade to Node.js 20 LTS"
git push origin main
```

Dokploy detectará el cambio y hará rebuild automático con Node.js 20.

---

## 🔍 Verificación

### Verificar versión de Node.js

```bash
# Local
node --version

# Docker
docker-compose exec whatsapp-api node --version

# VPS
ssh user@servidor
node --version
```

**Debe mostrar:** `v20.x.x`

### Verificar que la aplicación funciona

```bash
# Ver logs
docker-compose logs -f whatsapp-api

# Probar endpoint
curl http://localhost:3000/session/status
```

---

## 📊 Comparación de Versiones

| Feature | Node.js 16 | Node.js 18 | Node.js 20 |
|---------|-----------|-----------|-----------|
| **V8 Engine** | 9.4 | 10.2 | 11.3 |
| **Fetch API** | ❌ | Experimental | ✅ Estable |
| **Test Runner** | ❌ | Experimental | ✅ Estable |
| **Corepack** | Experimental | ✅ | ✅ |
| **ES Modules** | ✅ | ✅ | ✅ Mejorado |
| **Soporte hasta** | Sep 2023 ❌ | Abr 2025 | Abr 2026 ✅ |
| **Performance** | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🆘 Troubleshooting

### Error: "node: command not found" después de actualizar

**Solución:**
```bash
# Cerrar y abrir nueva terminal
# O recargar PATH
source ~/.bashrc  # Linux
# Reiniciar PowerShell en Windows
```

### Error: "Unsupported engine" en pnpm install

**Causa:** package.json requiere Node.js 18+

**Solución:**
```bash
# Verificar versión
node --version

# Si es menor a 18, actualizar Node.js
```

### Módulos nativos no funcionan

**Solución:**
```bash
# Rebuild de módulos nativos
pnpm rebuild

# O reinstalar todo
rm -rf node_modules
pnpm install
```

### Docker build falla

**Solución:**
```bash
# Limpiar cache de Docker
docker system prune -a

# Rebuild sin cache
docker-compose build --no-cache
```

---

## 🎯 Checklist de Actualización

### Desarrollo Local
- [ ] Actualizar Node.js a v20.x.x
- [ ] Verificar versión: `node --version`
- [ ] Eliminar `node_modules`
- [ ] Reinstalar: `pnpm install`
- [ ] Probar: `pnpm start`
- [ ] Verificar endpoints funcionan

### Docker
- [ ] Dockerfile actualizado (ya hecho)
- [ ] Rebuild: `docker-compose build --no-cache`
- [ ] Levantar: `docker-compose up -d`
- [ ] Verificar logs sin errores
- [ ] Probar endpoints

### VPS
- [ ] Actualizar Node.js en servidor
- [ ] Reinstalar dependencias
- [ ] Reiniciar PM2
- [ ] Verificar servicio activo
- [ ] Probar endpoints

### Dokploy
- [ ] Commit cambios
- [ ] Push a repositorio
- [ ] Esperar auto-deploy
- [ ] Verificar logs en Dokploy
- [ ] Probar endpoints

---

## 📚 Recursos

- [Node.js 20 Release Notes](https://nodejs.org/en/blog/release/v20.0.0)
- [Node.js 20 Documentation](https://nodejs.org/docs/latest-v20.x/api/)
- [NodeSource Distributions](https://github.com/nodesource/distributions)
- [nvm-windows](https://github.com/coreybutler/nvm-windows)

---

## ✅ Resumen

### Cambios
1. ✅ Dockerfile: Node.js 18 → 20
2. ✅ package.json: Engines actualizados
3. ✅ deploy-vps.sh: Instala Node.js 20
4. ✅ Auto-detección de versión antigua

### Beneficios
- 🚀 Mejor rendimiento
- 🔒 Más seguro
- 🆕 Nuevas características
- ⏰ Soporte hasta 2026

### Compatibilidad
- ✅ Baileys 7.x
- ✅ pnpm
- ✅ ES Modules
- ✅ Docker
- ✅ Dokploy

---

**🎉 ¡Upgrade completado! Ahora estás usando Node.js 20 LTS.**
