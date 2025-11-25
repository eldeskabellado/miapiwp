# 🔧 Troubleshooting - WhatsApp API

## ❌ Error: "Código QR no disponible aún"

### Síntoma
```json
{
  "success": false,
  "error": "Código QR no disponible aún",
  "message": "Esperando generación del QR..."
}
```

### Causas Comunes

1. **Ya existe una sesión activa**
   - La carpeta `auth_info/` contiene credenciales de una sesión anterior
   - WhatsApp no genera QR si ya está autenticado

2. **Problemas de conexión con WhatsApp**
   - Firewall bloqueando la conexión
   - Problemas de red
   - Servidores de WhatsApp temporalmente inaccesibles

3. **El servidor aún está iniciando**
   - Baileys necesita tiempo para conectarse
   - Espera 10-15 segundos después de iniciar

---

## ✅ Soluciones

### Solución 1: Resetear la Sesión (Recomendado)

**Usando el nuevo endpoint:**
```bash
curl -X POST http://localhost:3000/session/reset
```

**Respuesta esperada:**
```json
{
  "success": true,
  "message": "Sesión reseteada. Generando nuevo QR..."
}
```

**Luego espera 5-10 segundos y obtén el QR:**
```bash
curl http://localhost:3000/session/qr
```

---

### Solución 2: Eliminar Manualmente la Sesión

**Detener el servidor:**
```bash
# Presiona Ctrl+C en la terminal donde corre el servidor
```

**Eliminar carpeta de autenticación:**
```bash
# Windows
rmdir /s /q auth_info

# Linux/Mac
rm -rf auth_info
```

**Reiniciar el servidor:**
```bash
npm start
# o
pnpm start
```

---

### Solución 3: Verificar el Estado

**Verificar estado de conexión:**
```bash
curl http://localhost:3000/session/status
```

**Respuestas posibles:**

**1. Conectado (ya autenticado):**
```json
{
  "success": true,
  "connected": true,
  "state": "connected"
}
```
✅ **No necesitas QR**, ya estás autenticado.

**2. Desconectado (esperando QR):**
```json
{
  "success": true,
  "connected": false,
  "state": "disconnected"
}
```
⏳ **Espera unos segundos** y vuelve a intentar obtener el QR.

**3. Conectando:**
```json
{
  "success": true,
  "connected": false,
  "state": "connecting"
}
```
⏳ **El servidor está conectándose**, espera 10-15 segundos.

---

## 🔄 Flujo Completo de Troubleshooting

### Paso 1: Verificar estado
```bash
curl http://localhost:3000/session/status
```

### Paso 2: Si está conectado
```json
{"connected": true}
```
✅ **Ya estás autenticado**, no necesitas QR.

### Paso 3: Si no está conectado
```bash
# Resetear sesión
curl -X POST http://localhost:3000/session/reset

# Esperar 10 segundos
timeout /t 10  # Windows
# sleep 10     # Linux/Mac

# Obtener QR
curl http://localhost:3000/session/qr
```

### Paso 4: Si aún no funciona
```bash
# Detener servidor (Ctrl+C)

# Eliminar sesión manualmente
rmdir /s /q auth_info  # Windows
# rm -rf auth_info     # Linux/Mac

# Reiniciar
npm start
```

---

## 📱 Logs del Servidor

### Logs Normales (Correcto)

```
🔄 Iniciando conexión con WhatsApp...
📱 Código QR generado
✅ QR convertido a Base64
```

### Logs con Problemas

**1. Buffer timeout:**
```
{"msg":"Buffer timeout reached, auto-flushing"}
```
⚠️ **Problema de conexión** - Usa `/session/reset`

**2. Connection errored:**
```
{"msg":"connection errored"}
```
⚠️ **Error de red** - Verifica firewall/internet

**3. Logged out:**
```
❌ Conexión cerrada. Reconectar: false
```
⚠️ **Sesión cerrada** - Elimina `auth_info/` y reinicia

---

## 🐛 Errores Específicos

### Error: "ENOENT: no such file or directory"

**Causa:** Falta la carpeta `auth_info`

**Solución:**
```bash
mkdir auth_info
```

---

### Error: "Port 3000 already in use"

**Causa:** Ya hay un servidor corriendo en el puerto 3000

**Solución 1: Cambiar puerto**
```bash
PORT=8080 npm start
```

**Solución 2: Detener proceso**
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Linux/Mac
lsof -i :3000
kill -9 <PID>
```

---

### Error: "Cannot find module '@whiskeysockets/baileys'"

**Causa:** Dependencias no instaladas

**Solución:**
```bash
# Eliminar node_modules
rm -rf node_modules

# Reinstalar
npm install
# o
pnpm install
```

---

## 🔍 Debugging Avanzado

### Ver logs detallados de Baileys

**Editar `.env`:**
```env
DEBUG_BAILEYS=true
LOG_LEVEL=debug
```

**Reiniciar servidor:**
```bash
npm start
```

### Verificar conectividad con WhatsApp

```bash
# Verificar DNS
nslookup web.whatsapp.com

# Verificar conectividad
ping web.whatsapp.com

# Verificar puertos (debe estar abierto)
telnet web.whatsapp.com 443
```

---

## 📊 Checklist de Diagnóstico

- [ ] El servidor está corriendo (`npm start`)
- [ ] No hay errores en los logs
- [ ] El puerto 3000 está libre
- [ ] Internet funciona correctamente
- [ ] Firewall no bloquea la conexión
- [ ] Esperé al menos 15 segundos después de iniciar
- [ ] Probé resetear la sesión con `/session/reset`
- [ ] Eliminé la carpeta `auth_info/` manualmente
- [ ] Reinstalé las dependencias

---

## 🆘 Solución Rápida (Copy-Paste)

```bash
# 1. Detener servidor (Ctrl+C)

# 2. Limpiar todo
rmdir /s /q auth_info
rmdir /s /q node_modules
del package-lock.json

# 3. Reinstalar
npm install

# 4. Iniciar
npm start

# 5. Esperar 15 segundos

# 6. Obtener QR
curl http://localhost:3000/session/qr
```

---

## 💡 Tips

1. **Siempre espera 10-15 segundos** después de iniciar el servidor antes de pedir el QR
2. **Usa `/session/reset`** en lugar de reiniciar manualmente
3. **Verifica los logs** para ver qué está pasando
4. **Si ya estás conectado**, no necesitas QR (verifica con `/session/status`)
5. **Guarda la carpeta `auth_info/`** como backup si quieres preservar la sesión

---

## 📞 Endpoints de Diagnóstico

```bash
# Estado actual
GET http://localhost:3000/session/status

# Obtener QR
GET http://localhost:3000/session/qr

# Resetear sesión
POST http://localhost:3000/session/reset

# Cerrar sesión
POST http://localhost:3000/session/logout
```

---

## ✅ Verificación Final

**Si todo funciona correctamente, deberías ver:**

```bash
curl http://localhost:3000/session/qr
```

**Respuesta:**
```json
{
  "success": true,
  "qr": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
  "message": "Escanea este código con WhatsApp"
}
```

El campo `qr` contiene la imagen en Base64 que puedes mostrar en tu aplicación Delphi.
