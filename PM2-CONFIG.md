# 🔄 Configuración PM2 - Auto-Restart y Persistencia

## ✅ Configuración Implementada

### 📄 Archivo: `ecosystem.config.js`

Este archivo configura PM2 para:
- ✅ **Auto-restart** en caso de caída
- ✅ **Persistencia** tras reinicio del servidor
- ✅ **Puerto 3000** fijo
- ✅ **Límite de memoria** (1GB)
- ✅ **Reintentos automáticos** (hasta 10 veces)
- ✅ **Logs organizados**
- ✅ **Reinicio diario** programado (3 AM)

---

## 🚀 Cómo Funciona

### 1. Durante el Deployment

El script `deploy-vps.sh` automáticamente:

```bash
# Detecta ecosystem.config.js
if [ -f "$APP_DIR/ecosystem.config.js" ]; then
    # Usa la configuración avanzada
    pm2 start ecosystem.config.js
else
    # Usa configuración básica
    pm2 start baileys-server.js --name whatsapp-api
fi

# Guarda la configuración
pm2 save

# Configura inicio automático
pm2 startup systemd -u whatsapp
```

### 2. Al Reiniciar el Servidor

1. **Sistema inicia** → systemd arranca PM2
2. **PM2 inicia** → Lee configuración guardada
3. **Aplicación inicia** → En puerto 3000
4. **Todo automático** → Sin intervención manual

---

## 📋 Configuración Detallada

### ecosystem.config.js

```javascript
module.exports = {
  apps: [{
    name: 'whatsapp-api',
    script: './baileys-server.js',
    
    // PUERTO FIJO
    env: {
      NODE_ENV: 'production',
      PORT: 3000  // ← Puerto fijo
    },
    
    // AUTO-RESTART
    autorestart: true,
    max_restarts: 10,        // Máximo 10 reintentos
    min_uptime: '10s',       // Debe correr al menos 10s
    restart_delay: 4000,     // Espera 4s entre reintentos
    
    // LÍMITES
    max_memory_restart: '1G', // Reinicia si usa más de 1GB
    
    // LOGS
    error_file: './logs/pm2-error.log',
    out_file: './logs/pm2-out.log',
    
    // REINICIO PROGRAMADO
    cron_restart: '0 3 * * *' // Diario a las 3 AM
  }]
};
```

---

## 🔧 Comandos PM2 Útiles

### Ver Estado

```bash
# Ver todas las aplicaciones
pm2 list

# Ver detalles de whatsapp-api
pm2 show whatsapp-api

# Ver logs en tiempo real
pm2 logs whatsapp-api

# Ver solo errores
pm2 logs whatsapp-api --err

# Ver últimas 100 líneas
pm2 logs whatsapp-api --lines 100
```

### Controlar Aplicación

```bash
# Reiniciar
pm2 restart whatsapp-api

# Detener
pm2 stop whatsapp-api

# Iniciar
pm2 start whatsapp-api

# Eliminar
pm2 delete whatsapp-api

# Recargar (sin downtime)
pm2 reload whatsapp-api
```

### Gestión de Configuración

```bash
# Guardar configuración actual
pm2 save

# Restaurar desde configuración guardada
pm2 resurrect

# Ver configuración de startup
pm2 startup

# Deshabilitar startup
pm2 unstartup systemd
```

### Monitoreo

```bash
# Monitor en tiempo real
pm2 monit

# Información del sistema
pm2 info whatsapp-api

# Métricas
pm2 describe whatsapp-api
```

---

## 🔄 Escenarios de Auto-Restart

### 1. Aplicación Crashea

```
Aplicación falla → PM2 detecta → Espera 4s → Reinicia automáticamente
```

**Límite:** Máximo 10 reintentos. Si falla 10 veces, PM2 detiene los reintentos.

### 2. Uso Excesivo de Memoria

```
Memoria > 1GB → PM2 detecta → Reinicia aplicación → Libera memoria
```

### 3. Reinicio del Servidor

```
Servidor reinicia → systemd inicia → PM2 arranca → Aplicación inicia en puerto 3000
```

### 4. Reinicio Programado (Opcional)

```
Cada día a las 3 AM → PM2 reinicia → Limpia memoria → Aplicación fresca
```

---

## 📊 Verificación de Persistencia

### Probar Auto-Restart tras Reinicio

```bash
# 1. Conectar al VPS
ssh user@servidor

# 2. Ver estado actual
sudo su - whatsapp -c "pm2 list"

# 3. Reiniciar el servidor
sudo reboot

# 4. Esperar 2 minutos

# 5. Reconectar
ssh user@servidor

# 6. Verificar que PM2 inició automáticamente
sudo su - whatsapp -c "pm2 list"

# 7. Verificar que la app está corriendo
curl http://localhost:3000/session/status
```

**Resultado esperado:**
```
┌─────┬──────────────┬─────────┬─────────┬─────────┬──────────┐
│ id  │ name         │ mode    │ status  │ ↺       │ cpu      │
├─────┼──────────────┼─────────┼─────────┼─────────┼──────────┤
│ 0   │ whatsapp-api │ fork    │ online  │ 0       │ 0%       │
└─────┴──────────────┴─────────┴─────────┴─────────┴──────────┘
```

---

## 🆘 Troubleshooting

### PM2 no inicia al reiniciar servidor

**Verificar startup:**
```bash
# Ver configuración de startup
pm2 startup

# Si no está configurado, ejecutar:
sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u whatsapp --hp /home/whatsapp
sudo systemctl enable pm2-whatsapp
```

**Verificar servicio systemd:**
```bash
# Ver estado del servicio
sudo systemctl status pm2-whatsapp

# Ver logs del servicio
sudo journalctl -u pm2-whatsapp -n 50
```

### Aplicación no reinicia automáticamente

**Verificar configuración:**
```bash
# Ver configuración actual
pm2 show whatsapp-api

# Debe mostrar:
# autorestart: true
```

**Forzar guardado:**
```bash
sudo su - whatsapp -c "pm2 save --force"
```

### Puerto 3000 no está disponible

**Verificar qué usa el puerto:**
```bash
sudo lsof -i :3000
```

**Cambiar puerto temporalmente:**
```bash
# Editar .env
sudo nano /opt/whatsapp-api/.env

# Cambiar PORT=3000 a PORT=3001

# Reiniciar
sudo su - whatsapp -c "pm2 restart whatsapp-api"
```

### Logs no se guardan

**Verificar directorio de logs:**
```bash
# Crear directorio si no existe
sudo mkdir -p /opt/whatsapp-api/logs
sudo chown whatsapp:whatsapp /opt/whatsapp-api/logs

# Reiniciar PM2
sudo su - whatsapp -c "pm2 restart whatsapp-api"
```

---

## 📝 Actualizar Configuración

### Modificar ecosystem.config.js

```bash
# Conectar al VPS
ssh user@servidor

# Editar configuración
sudo nano /opt/whatsapp-api/ecosystem.config.js

# Aplicar cambios
sudo su - whatsapp -c "cd /opt/whatsapp-api && pm2 delete whatsapp-api"
sudo su - whatsapp -c "cd /opt/whatsapp-api && pm2 start ecosystem.config.js"
sudo su - whatsapp -c "pm2 save"
```

### Cambiar Puerto

**Opción 1: Editar .env**
```bash
sudo nano /opt/whatsapp-api/.env
# Cambiar PORT=3000
sudo su - whatsapp -c "pm2 restart whatsapp-api"
```

**Opción 2: Editar ecosystem.config.js**
```bash
sudo nano /opt/whatsapp-api/ecosystem.config.js
# Cambiar env.PORT
sudo su - whatsapp -c "pm2 restart whatsapp-api"
```

---

## 🎯 Mejores Prácticas

### 1. Siempre Guardar Configuración

```bash
# Después de cualquier cambio
pm2 save
```

### 2. Verificar Logs Regularmente

```bash
# Ver logs diariamente
pm2 logs whatsapp-api --lines 50
```

### 3. Monitorear Uso de Recursos

```bash
# Ver uso de CPU y memoria
pm2 monit
```

### 4. Rotar Logs

```bash
# Instalar módulo de rotación
pm2 install pm2-logrotate

# Configurar rotación
pm2 set pm2-logrotate:max_size 10M
pm2 set pm2-logrotate:retain 7
```

### 5. Backup de Configuración

```bash
# Guardar configuración
pm2 save

# Hacer backup del archivo
sudo cp /home/whatsapp/.pm2/dump.pm2 /home/whatsapp/.pm2/dump.pm2.backup
```

---

## 📊 Monitoreo Avanzado (Opcional)

### PM2 Plus (Monitoreo en la Nube)

```bash
# Registrarse en https://pm2.io

# Conectar servidor
pm2 link <secret_key> <public_key>

# Ver en dashboard web
# https://app.pm2.io
```

**Características:**
- 📊 Métricas en tiempo real
- 🔔 Alertas por email/SMS
- 📈 Histórico de rendimiento
- 🔍 Análisis de errores

---

## ✅ Checklist de Configuración

- [ ] `ecosystem.config.js` existe en el proyecto
- [ ] Script `deploy-vps.sh` actualizado
- [ ] PM2 instalado en el VPS
- [ ] Aplicación iniciada con `pm2 start ecosystem.config.js`
- [ ] Configuración guardada con `pm2 save`
- [ ] Startup configurado con `pm2 startup`
- [ ] Servicio systemd habilitado
- [ ] Puerto 3000 configurado
- [ ] Auto-restart habilitado
- [ ] Logs configurados
- [ ] Probado reinicio del servidor
- [ ] Aplicación inicia automáticamente

---

## 🎉 Resumen

### Configuración Actual

✅ **Puerto:** 3000 (fijo)  
✅ **Auto-restart:** Habilitado  
✅ **Persistencia:** Configurada  
✅ **Límite memoria:** 1GB  
✅ **Reintentos:** Hasta 10 veces  
✅ **Logs:** Organizados en `./logs/`  
✅ **Reinicio programado:** Diario a las 3 AM  
✅ **Inicio automático:** Al reiniciar servidor  

### Comandos Rápidos

```bash
# Ver estado
pm2 list

# Ver logs
pm2 logs whatsapp-api

# Reiniciar
pm2 restart whatsapp-api

# Monitorear
pm2 monit
```

---

**📖 Más info:** Ver documentación oficial de PM2: https://pm2.keymetrics.io/docs/usage/quick-start/
