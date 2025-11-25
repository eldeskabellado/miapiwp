# 🚀 Despliegue con Dokploy - WhatsApp API

## 📋 ¿Qué es Dokploy?

**Dokploy** es una plataforma de deployment open-source que te permite desplegar aplicaciones con Docker de forma sencilla, similar a Vercel o Netlify pero con soporte completo para Docker y bases de datos.

**Características:**
- ✅ Deploy desde GitHub/GitLab
- ✅ Soporte completo para Docker y Docker Compose
- ✅ SSL automático con Let's Encrypt
- ✅ Gestión de variables de entorno
- ✅ Logs en tiempo real
- ✅ Auto-deploy en cada push
- ✅ Rollback fácil

---

## 🎯 Requisitos Previos

### 1. Servidor VPS

Necesitas un servidor con:
- **OS**: Ubuntu 20.04+ / Debian 11+
- **RAM**: Mínimo 2GB (recomendado 4GB)
- **CPU**: 1 vCPU mínimo (recomendado 2 vCPUs)
- **Disco**: 20GB mínimo
- **Proveedores recomendados**: DigitalOcean, Hetzner, Vultr, Linode, AWS EC2

### 2. Dominio (Opcional pero recomendado)

- Un dominio apuntando a tu servidor
- Ejemplo: `whatsapp-api.tudominio.com`

### 3. Repositorio Git

- Tu código debe estar en GitHub, GitLab o Bitbucket
- Asegúrate de que `.env` esté en `.gitignore`

---

## 📦 Paso 1: Instalar Dokploy en tu VPS

### Conectarse al servidor

```bash
ssh root@tu-servidor-ip
```

### Instalar Dokploy (Un solo comando)

```bash
curl -sSL https://dokploy.com/install.sh | sh
```

Este script instalará automáticamente:
- Docker
- Docker Compose
- Dokploy
- Traefik (reverse proxy)
- Configuración SSL

**Tiempo estimado:** 5-10 minutos

### Verificar instalación

```bash
docker ps
```

Deberías ver contenedores de Dokploy corriendo.

### Acceder al panel de Dokploy

Abre tu navegador en:
```
http://tu-servidor-ip:3000
```

O si configuraste un dominio:
```
https://dokploy.tudominio.com
```

**Crear cuenta de administrador** en el primer acceso.

---

## 🔧 Paso 2: Preparar tu Repositorio

### Verificar archivos necesarios

Tu repositorio debe tener:

```
backend-nodejs-baylei/
├── Dockerfile              ✅ Ya lo tienes
├── docker-compose.yml      ✅ Ya lo tienes
├── .dockerignore          ✅ Ya lo tienes
├── .gitignore             ✅ Ya lo tienes
├── package.json           ✅ Ya lo tienes
├── baileys-server.js      ✅ Ya lo tienes
├── .env.example           ✅ Ya lo tienes
└── README.md              ✅ Ya lo tienes
```

### Asegúrate de que .env NO esté en Git

```bash
# Verificar
git status

# Si .env aparece, eliminarlo del tracking
git rm --cached .env
git commit -m "Remove .env from tracking"
git push
```

### Push a tu repositorio

```bash
git add .
git commit -m "Ready for Dokploy deployment"
git push origin main
```

---

## 🚀 Paso 3: Crear Aplicación en Dokploy

### 1. Crear Nuevo Proyecto

1. En el panel de Dokploy, click en **"New Project"**
2. Nombre: `whatsapp-api`
3. Click **"Create"**

### 2. Agregar Aplicación

1. Dentro del proyecto, click **"Add Application"**
2. Selecciona **"Docker Compose"**
3. Configuración:
   - **Name**: `whatsapp-api-server`
   - **Repository**: URL de tu repo Git
     ```
     https://github.com/tu-usuario/backend-nodejs-baylei
     ```
   - **Branch**: `main` (o la rama que uses)
   - **Compose File Path**: `docker-compose.yml`

### 3. Configurar Variables de Entorno

En la sección **"Environment Variables"**, agrega:

```env
# Puerto externo
EXTERNAL_PORT=3000

# Seguridad
API_KEY=tu-clave-super-secreta-aqui

# Redis
REDIS_HOST=redis
REDIS_PORT=6379

# Configuración
NODE_ENV=production
TZ=America/Caracas

# Logs
LOG_LEVEL=info
FILE_LOGGING=true

# WhatsApp
BROWSER_NAME=Delphi Client
BROWSER_VERSION=1.0.0
AUTO_RECONNECT=true
```

**💡 Tip:** Genera un API_KEY seguro:
```bash
openssl rand -hex 32
```

### 4. Configurar Dominio (Opcional)

Si tienes un dominio:

1. En la sección **"Domains"**
2. Click **"Add Domain"**
3. Ingresa: `whatsapp-api.tudominio.com`
4. Habilita **"SSL/HTTPS"** (automático con Let's Encrypt)

### 5. Configurar Volúmenes (Importante!)

Para persistir las sesiones de WhatsApp:

1. En **"Volumes"**, agregar:
   ```
   ./auth_info:/app/auth_info
   ./logs:/app/logs
   ```

---

## 🎬 Paso 4: Desplegar

### Deploy Manual

1. Click en **"Deploy"**
2. Dokploy hará:
   - ✅ Clonar el repositorio
   - ✅ Build de la imagen Docker
   - ✅ Levantar los servicios
   - ✅ Configurar SSL (si tienes dominio)

### Ver Logs en Tiempo Real

1. Click en **"Logs"**
2. Verás el output del servidor:
   ```
   🚀 Servidor corriendo en http://localhost:3000
   🔄 Iniciando conexión con WhatsApp...
   📱 Código QR generado
   ```

### Verificar Estado

1. En **"Overview"** verás:
   - Estado: Running ✅
   - CPU/RAM usage
   - Uptime

---

## 🔗 Paso 5: Acceder a tu API

### Con Dominio

```bash
# Obtener QR
curl https://whatsapp-api.tudominio.com/session/qr

# Ver estado
curl https://whatsapp-api.tudominio.com/session/status

# Enviar mensaje
curl -X POST https://whatsapp-api.tudominio.com/message/text \
  -H "Content-Type: application/json" \
  -d '{"number":"573001234567","text":"Hola desde Dokploy!"}'
```

### Sin Dominio (Solo IP)

```bash
# Obtener QR
curl http://tu-servidor-ip:3000/session/qr

# Ver estado
curl http://tu-servidor-ip:3000/session/status
```

---

## 🔄 Auto-Deploy (CI/CD)

### Configurar Webhook de GitHub

1. En Dokploy, ve a tu aplicación
2. Copia el **"Webhook URL"**
3. En GitHub:
   - Ve a tu repositorio
   - Settings → Webhooks → Add webhook
   - Pega la URL de Dokploy
   - Content type: `application/json`
   - Events: `Just the push event`
   - Save

**Ahora cada vez que hagas `git push`, Dokploy desplegará automáticamente!**

---

## 📊 Monitoreo y Mantenimiento

### Ver Logs

```bash
# Desde Dokploy panel
Logs → Real-time logs

# Desde SSH
ssh root@tu-servidor-ip
docker logs -f whatsapp-api --tail 100
```

### Reiniciar Aplicación

En Dokploy:
1. Click en **"Restart"**

Desde SSH:
```bash
docker-compose restart whatsapp-api
```

### Ver Recursos

En el panel de Dokploy verás:
- CPU usage
- RAM usage
- Network I/O
- Disk usage

---

## 🔒 Seguridad

### 1. Firewall

```bash
# Permitir solo puertos necesarios
ufw allow 22/tcp    # SSH
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw enable
```

### 2. Cambiar Puerto SSH (Recomendado)

```bash
nano /etc/ssh/sshd_config
# Cambiar Port 22 a Port 2222
systemctl restart sshd

# Actualizar firewall
ufw allow 2222/tcp
ufw delete allow 22/tcp
```

### 3. Configurar API Key

Asegúrate de usar un API_KEY fuerte en las variables de entorno.

---

## 🆘 Troubleshooting

### Error: "Build failed"

**Ver logs de build:**
```bash
# En Dokploy panel → Build Logs
```

**Solución común:**
```bash
# Verificar que Dockerfile y docker-compose.yml sean válidos
docker-compose config
```

### Error: "Container keeps restarting"

**Ver logs:**
```bash
docker logs whatsapp-api
```

**Soluciones:**
1. Verificar variables de entorno
2. Verificar que el puerto no esté en uso
3. Revisar permisos de volúmenes

### Error: "Cannot connect to API"

**Verificar que el contenedor esté corriendo:**
```bash
docker ps | grep whatsapp
```

**Verificar puertos:**
```bash
netstat -tlnp | grep 3000
```

**Verificar firewall:**
```bash
ufw status
```

---

## 📱 Obtener el QR Code

### Método 1: Desde tu aplicación Delphi

```pascal
// En Delphi
var
  Response: string;
begin
  Response := HTTPClient.Get('https://whatsapp-api.tudominio.com/session/qr');
  // Parsear JSON y mostrar QR
end;
```

### Método 2: Desde navegador

Abre en tu navegador:
```
https://whatsapp-api.tudominio.com/session/qr
```

Verás el JSON con el QR en Base64.

### Método 3: Crear página HTML simple

Crea un archivo `qr-viewer.html`:

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
    </style>
</head>
<body>
    <div class="container">
        <h1>📱 WhatsApp QR Code</h1>
        <div id="qr-container">
            <p>Cargando QR...</p>
        </div>
        <button onclick="loadQR()">🔄 Actualizar QR</button>
    </div>

    <script>
        const API_URL = 'https://whatsapp-api.tudominio.com';
        
        async function loadQR() {
            try {
                const response = await fetch(`${API_URL}/session/qr`);
                const data = await response.json();
                
                if (data.success && data.qr) {
                    document.getElementById('qr-container').innerHTML = 
                        `<img src="${data.qr}" alt="QR Code">
                         <p>Escanea con WhatsApp</p>`;
                } else if (data.connected) {
                    document.getElementById('qr-container').innerHTML = 
                        '<p>✅ Ya estás conectado!</p>';
                } else {
                    document.getElementById('qr-container').innerHTML = 
                        `<p>⏳ ${data.message}</p>`;
                }
            } catch (error) {
                document.getElementById('qr-container').innerHTML = 
                    `<p>❌ Error: ${error.message}</p>`;
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

Sube este archivo a tu servidor y accede desde el navegador.

---

## 🎯 Checklist de Deployment

- [ ] VPS configurado con Ubuntu/Debian
- [ ] Dokploy instalado
- [ ] Dominio apuntando al servidor (opcional)
- [ ] Repositorio Git con el código
- [ ] `.env` en `.gitignore`
- [ ] Proyecto creado en Dokploy
- [ ] Variables de entorno configuradas
- [ ] Volúmenes configurados para `auth_info`
- [ ] Deploy exitoso
- [ ] SSL configurado (si tienes dominio)
- [ ] Webhook de GitHub configurado
- [ ] Firewall configurado
- [ ] API funcionando correctamente

---

## 💰 Costos Estimados

### VPS Recomendados

| Proveedor | Plan | RAM | CPU | Precio/mes |
|-----------|------|-----|-----|------------|
| **Hetzner** | CX21 | 4GB | 2 vCPU | ~€5 (~$5.50) |
| **DigitalOcean** | Basic | 2GB | 1 vCPU | $12 |
| **Vultr** | Regular | 2GB | 1 vCPU | $12 |
| **Linode** | Nanode | 1GB | 1 vCPU | $5 |

**Recomendación:** Hetzner CX21 (mejor relación precio/rendimiento)

### Dominio

- **Namecheap**: ~$10/año
- **Cloudflare**: ~$10/año
- **Google Domains**: ~$12/año

---

## 🚀 Comandos Útiles

```bash
# Ver todos los contenedores
docker ps -a

# Ver logs en tiempo real
docker logs -f whatsapp-api

# Reiniciar aplicación
docker-compose restart whatsapp-api

# Ver uso de recursos
docker stats

# Entrar al contenedor
docker exec -it whatsapp-api sh

# Backup de auth_info
tar -czf auth_info_backup.tar.gz auth_info/

# Restaurar backup
tar -xzf auth_info_backup.tar.gz
```

---

## 📚 Recursos Adicionales

- **Dokploy Docs**: https://docs.dokploy.com
- **Dokploy GitHub**: https://github.com/Dokploy/dokploy
- **Community**: https://discord.gg/dokploy

---

## ✅ Resultado Final

Después de seguir esta guía tendrás:

✅ WhatsApp API desplegada en producción  
✅ SSL/HTTPS automático  
✅ Auto-deploy en cada push a GitHub  
✅ Logs en tiempo real  
✅ Monitoreo de recursos  
✅ Backups automáticos  
✅ Escalabilidad fácil  

**URL de tu API:**
```
https://whatsapp-api.tudominio.com
```

¡Listo para usar desde tu aplicación Delphi! 🎉
