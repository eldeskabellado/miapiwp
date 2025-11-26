# 🚀 Uso Rápido: Deploy en Directorio Actual

## ✅ Ahora el Script Usa el Directorio Actual

El script `deploy-app-only.sh` ahora instala **por defecto** en el directorio desde donde lo ejecutas.

---

## 📋 Flujo de Trabajo

### 1. Crear carpeta para la app

```bash
# Crear directorio
mkdir -p /opt/cliente1-api

# Ir al directorio
cd /opt/cliente1-api

# Copiar el script aquí
cp ~/deploy-app-only.sh .
```

### 2. Ejecutar el script

```bash
# Ejecutar desde el directorio de la app
sudo ./deploy-app-only.sh
```

**El script preguntará:**
```
Directorio de instalación [/opt/cliente1-api]: 
```

**Solo presiona Enter** para usar el directorio actual, o escribe otra ruta si quieres.

---

## 🎯 Ejemplo Completo: 2 Apps en Diferentes Carpetas

### App 1 - Cliente Ferresolar

```bash
# Crear y entrar al directorio
mkdir -p /opt/ferresolar-api && cd /opt/ferresolar-api

# Copiar script
cp ~/deploy-app-only.sh .

# Ejecutar
sudo ./deploy-app-only.sh

# Responder:
# Directorio: [Enter] (usa /opt/ferresolar-api)
# Nombre PM2: ferresolar-whatsapp
# Puerto: 3001
```

### App 2 - Cliente Pinturas

```bash
# Crear y entrar al directorio
mkdir -p /opt/pinturas-api && cd /opt/pinturas-api

# Copiar script
cp ~/deploy-app-only.sh .

# Ejecutar
sudo ./deploy-app-only.sh

# Responder:
# Directorio: [Enter] (usa /opt/pinturas-api)
# Nombre PM2: pinturas-whatsapp
# Puerto: 3002
```

---

## 💡 Ventajas de Este Flujo

### 1. Organización Clara
```
/opt/
├── ferresolar-api/
│   ├── deploy-app-only.sh
│   ├── baileys-server.js
│   ├── package.json
│   ├── auth_info/
│   └── logs/
│
├── pinturas-api/
│   ├── deploy-app-only.sh
│   ├── baileys-server.js
│   ├── package.json
│   ├── auth_info/
│   └── logs/
│
└── baylei-api/
    ├── deploy-app-only.sh
    ├── baileys-server.js
    ├── package.json
    ├── auth_info/
    └── logs/
```

### 2. Fácil de Mantener
- Cada app en su propia carpeta
- Todo autocontenido
- Fácil de identificar

### 3. Re-deploy Sencillo
```bash
# Ir a la carpeta de la app
cd /opt/ferresolar-api

# Re-ejecutar
sudo ./deploy-app-only.sh
# Presiona Enter en directorio (usa el actual)
```

---

## 🔄 Comandos Por App

### Ferresolar (Puerto 3001)
```bash
# Ver logs
pm2 logs ferresolar-whatsapp

# Reiniciar
pm2 restart ferresolar-whatsapp

# Ver QR
curl http://localhost:3001/session/qr

# Resetear sesión
curl -X POST http://localhost:3001/session/reset
```

### Pinturas (Puerto 3002)
```bash
# Ver logs
pm2 logs pinturas-whatsapp

# Reiniciar
pm2 restart pinturas-whatsapp

# Ver QR
curl http://localhost:3002/session/qr

# Resetear sesión
curl -X POST http://localhost:3002/session/reset
```

---

## 📝 Proceso Simplificado

### Opción 1: Desde Directorio Vacío (Clonar desde Git)

```bash
# 1. Crear directorio
mkdir -p /opt/nueva-app && cd /opt/nueva-app

# 2. Ejecutar script
sudo ~/deploy-app-only.sh

# 3. Cuando pregunte "¿Dónde están los archivos?"
# Seleccionar: 2) Clonar desde Git
# URL: https://github.com/tu-usuario/backend-nodejs-baylei.git

# 4. Configurar
# Directorio: [Enter] (usa /opt/nueva-app)
# Nombre PM2: nueva-app-whatsapp
# Puerto: 3003
```

### Opción 2: Desde Directorio con Código

```bash
# 1. Ya tienes el código en /opt/mi-app
cd /opt/mi-app

# 2. Copiar script
cp ~/deploy-app-only.sh .

# 3. Ejecutar
sudo ./deploy-app-only.sh

# 4. Cuando pregunte "¿Dónde están los archivos?"
# Seleccionar: 1) En el directorio actual

# 5. Configurar
# Directorio: [Enter] (usa /opt/mi-app)
# Nombre PM2: mi-app-whatsapp
# Puerto: 3004
```

---

## ✅ Verificación

### Ver todas las apps
```bash
pm2 list
```

**Resultado esperado:**
```
┌────┬─────────────────────┬──────┬──────┬────────┐
│ id │ name                │ mode │ ↺    │ status │
├────┼─────────────────────┼──────┼──────┼────────┤
│ 0  │ ferresolar-whatsapp │ fork │ 0    │ online │
│ 1  │ pinturas-whatsapp   │ fork │ 0    │ online │
│ 2  │ baylei-whatsapp     │ fork │ 0    │ online │
└────┴─────────────────────┴──────┴──────┴────────┘
```

### Ver puertos
```bash
netstat -tulpn | grep node
```

**Resultado esperado:**
```
tcp  0  0  :::3001  :::*  LISTEN  12345/node  (ferresolar)
tcp  0  0  :::3002  :::*  LISTEN  12346/node  (pinturas)
tcp  0  0  :::3003  :::*  LISTEN  12347/node  (baylei)
```

---

## 🎯 Template de Instalación Rápida

```bash
# Variables (cambiar según necesites)
APP_NAME="cliente-nuevo"
APP_PORT="3005"

# Crear e instalar
mkdir -p /opt/$APP_NAME-api && \
cd /opt/$APP_NAME-api && \
cp ~/deploy-app-only.sh . && \
# Ahora ejecuta manualmente:
# sudo ./deploy-app-only.sh
# Y responde:
# - Directorio: [Enter]
# - Nombre PM2: $APP_NAME-whatsapp
# - Puerto: $APP_PORT
```

---

## 💡 Tips

### Tip 1: Mantén el Script en Home
```bash
# Copiar a home una vez
cp deploy-app-only.sh ~/

# Usar desde cualquier directorio
cd /opt/nueva-app
sudo ~/deploy-app-only.sh
```

### Tip 2: Nombra las Apps Consistentemente
```
Patrón: [cliente]-whatsapp
Ejemplos:
- ferresolar-whatsapp
- pinturas-whatsapp
- baylei-whatsapp
```

### Tip 3: Usa Puertos Secuenciales
```
3001 → Ferresolar
3002 → Pinturas
3003 → Baylei
3004 → ...
```

---

**🚀 ¡Ahora el script usa el directorio actual por defecto! Más fácil y rápido.**
