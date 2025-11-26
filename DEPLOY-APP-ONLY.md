# 🚀 Script de Deployment Simplificado

## 📋 deploy-app-only.sh

Script para instalar **múltiples instancias** de la WhatsApp API en el mismo servidor.

### ✅ Requisitos Previos

**Debe estar instalado:**
- ✅ Node.js 20+
- ✅ pnpm
- ✅ PM2

### 🎯 Características

- ✅ Permite elegir directorio de instalación
- ✅ Permite elegir nombre de app PM2
- ✅ Permite elegir puerto
- ✅ Crea ecosystem.config.cjs personalizado
- ✅ NO modifica Node.js/pnpm/PM2 existentes
- ✅ Ideal para múltiples instancias

---

## 🚀 Uso

### Ejemplo 1: Instalar en carpeta y nombre diferentes

```bash
# Copiar script al servidor
scp deploy-app-only.sh user@servidor:~/

# Conectar al servidor
ssh user@servidor

# Dar permisos de ejecución
chmod +x deploy-app-only.sh

# Ejecutar
sudo ./deploy-app-only.sh
```

**Interacción:**
```
Directorio de instalación [/opt/whatsapp-api]: /opt/ferresolar-api
Nombre de la aplicación PM2 [whatsapp-api]: ferresolar-whatsapp
Puerto de la aplicación [3000]: 3001

[RESUMEN]
  Directorio: /opt/ferresolar-api
  Nombre PM2: ferresolar-whatsapp
  Puerto:     3001

¿Continuar? (s/n): s
```

---

## 📊 Casos de Uso

### Caso 1: Múltiples Clientes en un Servidor

```bash
# Cliente 1 - Ferresolar
sudo ./deploy-app-only.sh
  Directorio: /opt/ferresolar-api
  Nombre PM2: ferresolar-whatsapp
  Puerto:     3001

# Cliente 2 - Baylei
sudo ./deploy-app-only.sh
  Directorio: /opt/baylei-api
  Nombre PM2: baylei-whatsapp
  Puerto:     3002

# Cliente 3 - Pinturas
sudo ./deploy-app-only.sh
  Directorio: /opt/pinturas-api
  Nombre PM2: pinturas-whatsapp
  Puerto:     3003
```

**Resultado:**
```bash
pm2 list
```

```
┌────┬─────────────────────┬──────┬──────┬────────┐
│ id │ name                │ mode │ ↺    │ status │
├────┼─────────────────────┼──────┼──────┼────────┤
│ 0  │ ferresolar-whatsapp │ fork │ 0    │ online │
│ 1  │ baylei-whatsapp     │ fork │ 0    │ online │
│ 2  │ pinturas-whatsapp   │ fork │ 0    │ online │
└────┴─────────────────────┴──────┴──────┴────────┘
```

### Caso 2: Desarrollo y Producción

```bash
# Producción
sudo ./deploy-app-only.sh
  Directorio: /opt/whatsapp-api-prod
  Nombre PM2: whatsapp-prod
  Puerto:     3000

# Desarrollo/Testing
sudo ./deploy-app-only.sh
  Directorio: /opt/whatsapp-api-dev
  Nombre PM2: whatsapp-dev
  Puerto:     3001
```

---

## 🔧 Comandos por Instancia

### Ver logs de una instancia específica

```bash
# Ferresolar
pm2 logs ferresolar-whatsapp

# Baylei
pm2 logs baylei-whatsapp
```

### Reiniciar una instancia específica

```bash
pm2 restart ferresolar-whatsapp
```

### Ver QR de una instancia específica

```bash
# Puerto 3001 (Ferresolar)
curl http://localhost:3001/session/qr

# Puerto 3002 (Baylei)
curl http://localhost:3002/session/qr
```

### Resetear sesión de una instancia

```bash
# Ferresolar (puerto 3001)
curl -X POST http://localhost:3001/session/reset

# Baylei (puerto 3002)
curl -X POST http://localhost:3002/session/reset
```

---

## 📁 Estructura Resultante

```
/opt/
├── ferresolar-api/
│   ├── baileys-server.js
│   ├── package.json
│   ├── ecosystem.config.cjs
│   ├── .env
│   ├── auth_info/          # Sesión de Ferresolar
│   └── logs/
│
├── baylei-api/
│   ├── baileys-server.js
│   ├── package.json
│   ├── ecosystem.config.cjs
│   ├── .env
│   ├── auth_info/          # Sesión de Baylei
│   └── logs/
│
└── pinturas-api/
    ├── baileys-server.js
    ├── package.json
    ├── ecosystem.config.cjs
    ├── .env
    ├── auth_info/          # Sesión de Pinturas
    └── logs/
```

Cada instancia tiene **su propia sesión de WhatsApp independiente**.

---

## 🔍 Verificación

### Ver todas las instancias

```bash
pm2 list
```

### Ver puertos en uso

```bash
netstat -tulpn | grep node
# O
ss -tulpn | grep node
```

**Resultado esperado:**
```
tcp    0    0 :::3001    :::*    LISTEN    12345/node  (ferresolar)
tcp    0    0 :::3002    :::*    LISTEN    12346/node  (baylei)
tcp    0    0 :::3003    :::*    LISTEN    12347/node  (pinturas)
```

### Probar cada instancia

```bash
# Ferresolar (3001)
curl http://localhost:3001/session/status

# Baylei (3002)
curl http://localhost:3002/session/status

# Pinturas (3003)
curl http://localhost:3003/session/status
```

---

## 🌐 Nginx para Múltiples Instancias

Si quieres usar dominios diferentes:

```nginx
# /etc/nginx/sites-available/whatsapp-multi

# Ferresolar
server {
    listen 80;
    server_name ferresolar-wa.tudominio.com;
    
    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}

# Baylei
server {
    listen 80;
    server_name baylei-wa.tudominio.com;
    
    location / {
        proxy_pass http://localhost:3002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}

# Pinturas
server {
    listen 80;
    server_name pinturas-wa.tudominio.com;
    
    location / {
        proxy_pass http://localhost:3003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
    }
}
```

Activar:
```bash
ln -s /etc/nginx/sites-available/whatsapp-multi /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

---

## 📝 Actualizar una Instancia

```bash
# 1. Ir al directorio de la instancia
cd /opt/ferresolar-api

# 2. Hacer backup de .env y auth_info
cp .env .env.backup
cp -r auth_info auth_info.backup

# 3. Actualizar código (si usas Git)
git pull

# 4. Reinstalar dependencias si es necesario
pnpm install

# 5. Reiniciar PM2
pm2 restart ferresolar-whatsapp

# 6. Ver logs
pm2 logs ferresolar-whatsapp
```

---

## 🗑️ Eliminar una Instancia

```bash
# 1. Detener y eliminar de PM2
pm2 delete ferresolar-whatsapp

# 2. Guardar configuración PM2
pm2 save

# 3. Eliminar directorio (CUIDADO: esto borra la sesión)
rm -rf /opt/ferresolar-api
```

---

## ⚠️ Consideraciones Importantes

### 1. Cada Instancia = Una Sesión de WhatsApp Diferente

- Necesitas un número de WhatsApp diferente para cada instancia
- No puedes usar el mismo número en múltiples instancias

### 2. Recursos del Servidor

Cada instancia consume:
- ~200-300MB RAM
- ~5-10% CPU (variable)

**Recomendación:** Máximo 5-10 instancias por servidor con 4GB RAM.

### 3. Puertos

- Cada instancia necesita su propio puerto
- Asegúrate de que no haya conflictos
- Actualiza el firewall si es necesario:

```bash
ufw allow 3001/tcp comment 'WhatsApp Ferresolar'
ufw allow 3002/tcp comment 'WhatsApp Baylei'
ufw allow 3003/tcp comment 'WhatsApp Pinturas'
```

---

## ✅ Ventajas de Este Script

1. ✅ **Rápido** - No reinstala Node.js/PM2
2. ✅ **Flexible** - Permite personalizar todo
3. ✅ **Múltiples instancias** - En el mismo servidor
4. ✅ **Independiente** - Cada instancia totalmente separada
5. ✅ **Automatizado** - Configura todo correctamente
6. ✅ **Seguro** - No afecta instalaciones existentes

---

## 🎯 Ejemplos de Uso

### Ejemplo Completo: 3 Clientes

```bash
# Instalación
cd ~
nano deploy-app-only.sh  # Pegar contenido
chmod +x deploy-app-only.sh

# Cliente 1
sudo ./deploy-app-only.sh
# Dir: /opt/cliente1-api
# PM2: cliente1-whatsapp
# Port: 3001

# Cliente 2
sudo ./deploy-app-only.sh
# Dir: /opt/cliente2-api
# PM2: cliente2-whatsapp
# Port: 3002

# Cliente 3
sudo ./deploy-app-only.sh
# Dir: /opt/cliente3-api
# PM2: cliente3-whatsapp
# Port: 3003

# Verificar
pm2 list
```

---

**📖 Más info:** Ver `deploy-vps.sh` para instalación completa con Node.js
