# 🚀 Deployment en Dokploy - Paso a Paso

## ✅ Pre-requisitos (Ya los tienes)
- ✅ Dokploy instalado y funcionando
- ✅ Acceso al panel de Dokploy
- ✅ Código en repositorio Git (GitHub/GitLab)

---

## 📋 Paso 1: Preparar el Repositorio

### 1.1 Verificar que el código esté en Git

```bash
# Verificar estado
git status

# Si hay cambios, commitear
git add .
git commit -m "Ready for Dokploy deployment"
git push origin main
```

### 1.2 Verificar archivos necesarios

Asegúrate de que tu repositorio tenga:
- ✅ `Dockerfile`
- ✅ `docker-compose.yml`
- ✅ `.dockerignore`
- ✅ `.env.example` (NO `.env`)
- ✅ `package.json`
- ✅ `baileys-server.js`

### 1.3 Obtener URL del repositorio

**GitHub:**
```
https://github.com/tu-usuario/backend-nodejs-baylei.git
```

**GitLab:**
```
https://gitlab.com/tu-usuario/backend-nodejs-baylei.git
```

---

## 📋 Paso 2: Crear Proyecto en Dokploy

### 2.1 Acceder al Panel

1. Abre tu navegador
2. Ve a: `https://tu-dominio-dokploy.com` o `http://tu-ip:3000`
3. Inicia sesión

### 2.2 Crear Nuevo Proyecto

1. Click en **"Projects"** en el menú lateral
2. Click en **"Create Project"** (botón azul arriba a la derecha)
3. Configuración:
   ```
   Project Name: whatsapp-api
   Description: WhatsApp API Backend con Baileys
   ```
4. Click en **"Create"**

---

## 📋 Paso 3: Crear Aplicación

### 3.1 Agregar Nueva Aplicación

1. Dentro del proyecto `whatsapp-api`, click en **"Add Service"**
2. Selecciona **"Application"**
3. Selecciona **"Docker Compose"**

### 3.2 Configuración Básica

**General Settings:**
```
Application Name: whatsapp-api-server
Description: WhatsApp API con Baileys para Delphi
```

### 3.3 Configuración de Git

**Source:**
```
Repository Type: Git
Repository URL: https://github.com/tu-usuario/backend-nodejs-baylei.git
Branch: main
```

**Build Settings:**
```
Build Type: Docker Compose
Compose File Path: docker-compose.yml
```

### 3.4 Click en **"Create"**

---

## 📋 Paso 4: Configurar Variables de Entorno

### 4.1 Ir a Variables de Entorno

1. En tu aplicación, click en la pestaña **"Environment"**
2. Click en **"Add Variable"**

### 4.2 Agregar Variables (una por una)

**Variables Mínimas Requeridas:**

| Key | Value | Descripción |
|-----|-------|-------------|
| `EXTERNAL_PORT` | `3000` | Puerto externo |
| `PORT` | `3000` | Puerto interno |
| `NODE_ENV` | `production` | Entorno |
| `API_KEY` | `[genera-uno-seguro]` | Clave de API |
| `REDIS_HOST` | `redis` | Host de Redis |
| `REDIS_PORT` | `6379` | Puerto de Redis |

**Variables Recomendadas Adicionales:**

| Key | Value |
|-----|-------|
| `TZ` | `America/Caracas` |
| `LOG_LEVEL` | `info` |
| `FILE_LOGGING` | `true` |
| `BROWSER_NAME` | `Delphi Client` |
| `BROWSER_VERSION` | `1.0.0` |
| `AUTO_RECONNECT` | `true` |
| `KEEP_ALIVE_INTERVAL` | `10000` |

### 4.3 Generar API_KEY Seguro

**Opción 1: En tu terminal local**
```bash
openssl rand -hex 32
```

**Opción 2: PowerShell**
```powershell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
```

**Opción 3: Online**
- Ve a: https://generate-random.org/api-key-generator
- Copia la clave generada

### 4.4 Guardar Variables

Click en **"Save"** después de agregar cada variable.

---

## 📋 Paso 5: Configurar Volúmenes (IMPORTANTE)

### 5.1 Ir a Volúmenes

1. En tu aplicación, click en la pestaña **"Volumes"** o **"Mounts"**

### 5.2 Agregar Volúmenes

**Volumen 1: Sesiones de WhatsApp (CRÍTICO)**
```
Name: whatsapp-sessions
Mount Path: /app/auth_info
Type: Volume
```

**Volumen 2: Logs (Opcional)**
```
Name: whatsapp-logs
Mount Path: /app/logs
Type: Volume
```

### 5.3 Guardar

Click en **"Save"** o **"Add Volume"**

---

## 📋 Paso 6: Configurar Dominio (Opcional pero Recomendado)

### 6.1 Si tienes un dominio

1. En tu aplicación, click en la pestaña **"Domains"**
2. Click en **"Add Domain"**
3. Configuración:
   ```
   Domain: whatsapp-api.tudominio.com
   Path: /
   Port: 3000
   ```
4. **Habilitar SSL**: ✅ (automático con Let's Encrypt)
5. Click en **"Save"**

### 6.2 Configurar DNS

En tu proveedor de dominio (Namecheap, Cloudflare, etc.):
```
Type: A
Name: whatsapp-api
Value: [IP de tu servidor Dokploy]
TTL: 300
```

Espera 5-10 minutos para que se propague.

### 6.3 Si NO tienes dominio

Puedes acceder directamente por IP:
```
http://tu-ip-servidor:3000
```

---

## 📋 Paso 7: Desplegar (Deploy)

### 7.1 Iniciar Deployment

1. En tu aplicación, ve a la pestaña **"Deployments"** o **"Overview"**
2. Click en el botón **"Deploy"** (botón verde/azul)
3. Confirma el deployment

### 7.2 Monitorear el Build

1. Ve a la pestaña **"Logs"** o **"Build Logs"**
2. Verás el proceso en tiempo real:
   ```
   Cloning repository...
   Building Docker image...
   Starting services...
   ```

**Tiempo estimado:** 2-5 minutos

### 7.3 Verificar Estado

En la pestaña **"Overview"** deberías ver:
```
Status: ✅ Running
Health: ✅ Healthy
Uptime: XX seconds
```

---

## 📋 Paso 8: Verificar que Funciona

### 8.1 Ver Logs en Tiempo Real

1. Ve a la pestaña **"Logs"**
2. Deberías ver:
   ```
   🚀 Servidor corriendo en http://localhost:3000
   🔄 Iniciando conexión con WhatsApp...
   📱 Código QR generado
   ✅ QR convertido a Base64
   ```

### 8.2 Probar Endpoints

**Con dominio:**
```bash
# Ver estado
curl https://whatsapp-api.tudominio.com/session/status

# Obtener QR
curl https://whatsapp-api.tudominio.com/session/qr
```

**Sin dominio (solo IP):**
```bash
# Ver estado
curl http://tu-ip:3000/session/status

# Obtener QR
curl http://tu-ip:3000/session/qr
```

### 8.3 Respuesta Esperada

**Estado:**
```json
{
  "success": true,
  "connected": false,
  "state": "disconnected"
}
```

**QR (primera vez):**
```json
{
  "success": true,
  "qr": "data:image/png;base64,iVBORw0KGgo...",
  "message": "Escanea este código con WhatsApp"
}
```

---

## 📋 Paso 9: Obtener y Escanear el QR

### 9.1 Opción 1: Desde el Navegador

1. Abre en tu navegador:
   ```
   https://whatsapp-api.tudominio.com/session/qr
   ```
2. Verás el JSON con el QR en Base64
3. Copia el valor del campo `qr`
4. Usa un visualizador de Base64 o tu app Delphi

### 9.2 Opción 2: Crear Página HTML

Crea un archivo `qr-viewer.html` en tu computadora:

```html
<!DOCTYPE html>
<html>
<head>
    <title>WhatsApp QR</title>
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            font-family: Arial;
            background: #0a0a0a;
            color: white;
        }
        .container {
            text-align: center;
            padding: 2rem;
            background: #1a1a1a;
            border-radius: 1rem;
        }
        img {
            max-width: 400px;
            border: 4px solid #25D366;
            border-radius: 1rem;
        }
        button {
            margin-top: 1rem;
            padding: 1rem 2rem;
            background: #25D366;
            color: white;
            border: none;
            border-radius: 0.5rem;
            cursor: pointer;
            font-size: 1rem;
        }
        .status {
            margin-top: 1rem;
            padding: 1rem;
            background: #2a2a2a;
            border-radius: 0.5rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 WhatsApp QR Code</h1>
        <div id="qr-container">
            <p>Cargando QR...</p>
        </div>
        <button onclick="loadQR()">🔄 Actualizar QR</button>
        <div id="status" class="status"></div>
    </div>

    <script>
        // CAMBIA ESTA URL POR LA TUYA
        const API_URL = 'https://whatsapp-api.tudominio.com';
        // O si usas IP: const API_URL = 'http://tu-ip:3000';
        
        async function loadQR() {
            try {
                document.getElementById('status').innerHTML = '⏳ Cargando...';
                
                const response = await fetch(`${API_URL}/session/qr`);
                const data = await response.json();
                
                if (data.success && data.qr) {
                    document.getElementById('qr-container').innerHTML = 
                        `<img src="${data.qr}" alt="QR Code">
                         <p>✅ Escanea con WhatsApp</p>`;
                    document.getElementById('status').innerHTML = 
                        '✅ QR cargado correctamente';
                } else if (data.connected) {
                    document.getElementById('qr-container').innerHTML = 
                        '<p style="font-size: 3rem;">✅</p><p>Ya estás conectado!</p>';
                    document.getElementById('status').innerHTML = 
                        '✅ WhatsApp conectado';
                } else {
                    document.getElementById('qr-container').innerHTML = 
                        `<p>⏳ ${data.message || 'Esperando QR...'}</p>`;
                    document.getElementById('status').innerHTML = 
                        '⏳ Esperando generación del QR...';
                }
            } catch (error) {
                document.getElementById('qr-container').innerHTML = 
                    `<p>❌ Error: ${error.message}</p>`;
                document.getElementById('status').innerHTML = 
                    `❌ Error de conexión: ${error.message}`;
            }
        }
        
        // Cargar al inicio
        loadQR();
        
        // Auto-refresh cada 5 segundos
        setInterval(loadQR, 5000);
    </script>
</body>
</html>
```

**Uso:**
1. Guarda el archivo
2. Cambia `API_URL` por tu URL real
3. Abre en el navegador
4. Escanea el QR con WhatsApp

### 9.3 Opción 3: Desde tu App Delphi

```pascal
// En Delphi
var
  HTTP: TNetHTTPClient;
  Response: IHTTPResponse;
  JSONValue: TJSONValue;
  QRBase64: string;
begin
  HTTP := TNetHTTPClient.Create(nil);
  try
    Response := HTTP.Get('https://whatsapp-api.tudominio.com/session/qr');
    
    if Response.StatusCode = 200 then
    begin
      JSONValue := TJSONObject.ParseJSONValue(Response.ContentAsString);
      try
        if JSONValue.GetValue<Boolean>('success') then
        begin
          QRBase64 := JSONValue.GetValue<string>('qr');
          // Mostrar QR en TImage
          DisplayBase64Image(QRBase64, Image1);
        end;
      finally
        JSONValue.Free;
      end;
    end;
  finally
    HTTP.Free;
  end;
end;
```

---

## 📋 Paso 10: Configurar Auto-Deploy (Opcional)

### 10.1 Obtener Webhook URL

1. En Dokploy, ve a tu aplicación
2. Ve a la pestaña **"Settings"** o **"General"**
3. Busca **"Webhook URL"** o **"Deploy Webhook"**
4. Copia la URL (algo como):
   ```
   https://dokploy.tudominio.com/api/deploy/webhook/abc123xyz
   ```

### 10.2 Configurar en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **"Settings"**
3. Click en **"Webhooks"** (menú lateral)
4. Click en **"Add webhook"**
5. Configuración:
   ```
   Payload URL: [URL del webhook de Dokploy]
   Content type: application/json
   Secret: [dejar vacío o usar el de Dokploy]
   Events: Just the push event
   Active: ✅
   ```
6. Click en **"Add webhook"**

### 10.3 Probar Auto-Deploy

```bash
# Hacer un cambio
echo "# Test" >> README.md

# Commit y push
git add .
git commit -m "Test auto-deploy"
git push origin main

# Dokploy desplegará automáticamente
```

---

## 📋 Paso 11: Monitoreo y Mantenimiento

### 11.1 Ver Logs en Tiempo Real

1. En Dokploy, ve a tu aplicación
2. Click en **"Logs"**
3. Verás los logs en tiempo real

### 11.2 Ver Métricas

1. Click en **"Metrics"** o **"Monitoring"**
2. Verás:
   - CPU usage
   - RAM usage
   - Network I/O
   - Disk usage

### 11.3 Reiniciar Aplicación

1. Click en **"Actions"** o el botón **"Restart"**
2. Confirma

### 11.4 Ver Estado de Contenedores

1. En **"Overview"** verás todos los servicios:
   ```
   whatsapp-api: ✅ Running
   redis: ✅ Running
   ```

---

## 🆘 Troubleshooting

### Error: "Build Failed"

**Solución:**
1. Ve a **"Build Logs"**
2. Busca el error específico
3. Verifica que `Dockerfile` y `docker-compose.yml` sean válidos
4. Asegúrate de que todas las variables de entorno estén configuradas

### Error: "Container keeps restarting"

**Solución:**
1. Ve a **"Logs"**
2. Busca errores en los logs
3. Verifica variables de entorno
4. Verifica que los volúmenes estén configurados

### Error: "Cannot access API"

**Solución:**
1. Verifica que el contenedor esté **Running**
2. Verifica el dominio/DNS
3. Verifica el firewall del servidor
4. Prueba acceder por IP directamente

### QR no se genera

**Solución:**
1. Ve a **"Logs"** y busca:
   ```
   📱 Código QR generado
   ```
2. Si no aparece, usa el endpoint `/session/reset`:
   ```bash
   curl -X POST https://whatsapp-api.tudominio.com/session/reset
   ```
3. Espera 10 segundos y vuelve a intentar

---

## ✅ Checklist de Deployment

- [ ] Código pusheado a Git
- [ ] Proyecto creado en Dokploy
- [ ] Aplicación creada (Docker Compose)
- [ ] Repositorio Git conectado
- [ ] Variables de entorno configuradas
- [ ] `API_KEY` generado y configurado
- [ ] Volúmenes configurados (`auth_info`, `logs`)
- [ ] Dominio configurado (opcional)
- [ ] DNS apuntando al servidor (si usas dominio)
- [ ] SSL habilitado (si usas dominio)
- [ ] Deploy ejecutado
- [ ] Logs verificados (sin errores)
- [ ] Estado: Running ✅
- [ ] Endpoint `/session/status` responde
- [ ] QR obtenido y escaneado
- [ ] WhatsApp conectado
- [ ] Webhook de GitHub configurado (opcional)
- [ ] Backup de `auth_info` configurado

---

## 🎯 Resumen de URLs

**Panel de Dokploy:**
```
https://dokploy.tudominio.com
```

**Tu API (con dominio):**
```
https://whatsapp-api.tudominio.com
```

**Endpoints principales:**
```
GET  /session/status   - Ver estado
GET  /session/qr       - Obtener QR
POST /session/reset    - Resetear sesión
POST /message/text     - Enviar mensaje
```

---

## 📞 Comandos Útiles

```bash
# Ver estado
curl https://whatsapp-api.tudominio.com/session/status

# Obtener QR
curl https://whatsapp-api.tudominio.com/session/qr

# Resetear sesión
curl -X POST https://whatsapp-api.tudominio.com/session/reset

# Enviar mensaje de prueba
curl -X POST https://whatsapp-api.tudominio.com/message/text \
  -H "Content-Type: application/json" \
  -d '{"number":"573001234567","text":"Hola desde Dokploy!"}'
```

---

**¡Listo! Tu WhatsApp API está desplegada en producción con Dokploy! 🎉**

Si tienes algún problema, revisa la sección de Troubleshooting o los logs en Dokploy.
