# ✅ Script Simplificado - Solo Nombre PM2

## 🎯 ¿Qué Pregunta Ahora?

El script `deploy-app-only.sh` ahora es **MÁS SIMPLE**:

### Solo 2 Preguntas:

1. **Directorio** (presiona Enter para usar el actual)
2. **Nombre PM2** (único que necesitas escribir)

El **puerto** se configura en el archivo `.env` (3000 por defecto).

---

## 🚀 Ejemplo de Uso

```bash
# Ejecutar
sudo ./deploy-app-only.sh
```

**Interacción:**
```
Directorio de instalación [/opt/mi-app]: 
[Presiona Enter]

Nombre de la aplicación PM2 [whatsapp-api]: mi-cliente-whatsapp
[Escribe el nombre]

[RESUMEN]
  Directorio: /opt/mi-app
  Nombre PM2: mi-cliente-whatsapp
  Puerto:     Se configurará en .env (por defecto 3000)

¿Continuar? (s/n): s
```

**¡Y listo!** Solo escribiste el nombre de PM2.

---

## 📋 Proceso Completo

### Paso 1: Ir al directorio
```bash
cd /opt/mi-app
```

### Paso 2: Ejecutar script
```bash
sudo ~/deploy-app-only.sh
```

### Paso 3: Responder
```
Directorio: [Enter]
Nombre PM2: mi-app-whatsapp
```

### Paso 4: Configurar puerto (si no es 3000)
```bash
# Editar .env
nano .env

# Cambiar línea:
PORT=3005

# Guardar (Ctrl+O, Enter, Ctrl+X)

# Reiniciar PM2
pm2 restart mi-app-whatsapp
```

---

## 🎯 Múltiples Apps - Flujo Rápido

### App 1
```bash
cd /opt/app1 && sudo ~/deploy-app-only.sh
# Directorio: [Enter]
# Nombre: app1-whatsapp
# Puerto: 3000 (por defecto en .env)
```

### App 2
```bash
cd /opt/app2 && sudo ~/deploy-app-only.sh
# Directorio: [Enter]
# Nombre: app2-whatsapp
# Puerto: 3001 (editar .env después)
```

### App 3
```bash
cd /opt/app3 && sudo ~/deploy-app-only.sh
# Directorio: [Enter]
# Nombre: app3-whatsapp
# Puerto: 3002 (editar .env después)
```

---

## 🔧 Cambiar Puerto Después del Deploy

```bash
# Opción 1: Editar .env manualmente
nano /opt/mi-app/.env
# Cambiar PORT=3000 a PORT=3005
pm2 restart mi-app-whatsapp

# Opción 2: Usar sed
cd /opt/mi-app
sed -i 's/PORT=.*/PORT=3005/' .env
pm2 restart mi-app-whatsapp

# Opción 3: Echo directo
cd /opt/mi-app
echo "PORT=3005" >> .env
pm2 restart mi-app-whatsapp
```

---

## 💡 Ventajas

### 1. Más Rápido
- Solo escribes el nombre de PM2
- El resto son defaults

### 2. Flexible
- Puerto se configura en .env
- Puedes cambiarlo después sin re-deployar

### 3. Consistente
- Todos usan puerto 3000 por defecto
- Cambias solo los que necesites

### 4. Simple
- Menos preguntas = menos errores
- Más intuitivo

---

## 📊 Comparación

| Pregunta | Antes | Ahora |
|----------|-------|-------|
| Directorio | ✅ Pregunta | ✅ Pregunta (default actual) |
| Nombre PM2 | ✅ Pregunta | ✅ Pregunta |
| Puerto | ✅ Pregunta | ❌ Se configura en .env |

---

## 🎯 Casos de Uso

### Caso 1: Todas las Apps en Puerto 3000 (Default)

```bash
# No necesitas configurar nada
# Solo los nombres de PM2 deben ser únicos
pm2 list
```

```
┌────┬────────────────────┬──────┬──────┬────────┐
│ id │ name               │ port │ ↺    │ status │
├────┼────────────────────┼──────┼──────┼────────┤
│ 0  │ cliente1-whatsapp  │ 3000 │ 0    │ online │
└────┴────────────────────┴──────┴──────┴────────┘
```

### Caso 2: Cada App en Puerto Diferente

```bash
# App 1
cd /opt/app1 && sudo ~/deploy-app-only.sh
# Nombre: app1-whatsapp
# Puerto se queda en 3000

# App 2
cd /opt/app2 && sudo ~/deploy-app-only.sh
# Nombre: app2-whatsapp
# Cambiar puerto:
sed -i 's/PORT=3000/PORT=3001/' /opt/app2/.env
pm2 restart app2-whatsapp

# App 3
cd /opt/app3 && sudo ~/deploy-app-only.sh
# Nombre: app3-whatsapp
# Cambiar puerto:
sed -i 's/PORT=3000/PORT=3002/' /opt/app3/.env
pm2 restart app3-whatsapp
```

---

## ✅ Script Actualizado

### Antes
```bash
sudo ./deploy-app-only.sh

Directorio: /opt/app1    ← escribir
Nombre PM2: app1         ← escribir  
Puerto: 3001             ← escribir ❌
```

### Ahora
```bash
sudo ./deploy-app-only.sh

Directorio: [Enter]      ← solo Enter
Nombre PM2: app1         ← escribir ✅
Puerto: en .env          ← configurar después si necesitas
```

---

## 📝 Template Rápido

```bash
# Variables
APP_NAME="cliente-nuevo"

# Deploy
cd /opt/$APP_NAME-api && \
sudo ~/deploy-app-only.sh
# Presiona Enter en directorio
# Escribe: $APP_NAME-whatsapp en nombre

# Si necesitas puerto diferente:
# sed -i 's/PORT=3000/PORT=3005/' .env
# pm2 restart $APP_NAME-whatsapp
```

---

**🚀 ¡Ahora el script solo pide el nombre de PM2! Más rápido y  simple.**
