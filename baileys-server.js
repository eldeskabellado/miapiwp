/**
 * WhatsApp API Server con Baileys
 * Compatible con el cliente Delphi Rio
 * 
 * Instalación:
 * npm install express @whiskeysockets/baileys qrcode-terminal
 * 
 * Uso:
 * node baileys-server.js
 */

const express = require('express');
const { default: makeWASocket, useMultiFileAuthState, DisconnectReason } = require('@whiskeysockets/baileys');
const QRCode = require('qrcode');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

// Middleware
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// CORS para permitir peticiones desde Delphi
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  next();
});

// Variables globales
let sock;
let qrCode;
let isConnected = false;
let connectionState = 'disconnected';

/**
 * Inicializar conexión con WhatsApp
 */
async function connectToWhatsApp() {
  console.log('🔄 Iniciando conexión con WhatsApp...');

  try {
    // Cargar o crear sesión de autenticación
    const { state, saveCreds } = await useMultiFileAuthState('auth_info');

    // Crear socket de WhatsApp
    sock = makeWASocket({
      auth: state,
      printQRInTerminal: false, // No mostrar QR en terminal
      browser: ['Delphi Client', 'Chrome', '1.0.0'],
      connectTimeoutMs: 60000,
      defaultQueryTimeoutMs: 0,
      keepAliveIntervalMs: 10000,
      emitOwnEvents: true,
      generateHighQualityLinkPreview: true
    });

    // Evento: Actualización de conexión
    sock.ev.on('connection.update', async (update) => {
      const { connection, lastDisconnect, qr } = update;

      // Si hay código QR, generarlo en Base64
      if (qr) {
        console.log('📱 Código QR generado');
        try {
          // Generar QR en formato Base64 para Delphi
          qrCode = await QRCode.toDataURL(qr);
          console.log('✅ QR convertido a Base64');
        } catch (err) {
          console.error('❌ Error al generar QR:', err);
        }
      }

      // Estado de la conexión
      if (connection === 'close') {
        connectionState = 'disconnected';
        isConnected = false;

        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
        console.log('❌ Conexión cerrada. Reconectar:', shouldReconnect);

        if (shouldReconnect) {
          console.log('🔄 Reconectando en 5 segundos...');
          setTimeout(() => connectToWhatsApp(), 5000);
        }
      } else if (connection === 'open') {
        connectionState = 'connected';
        isConnected = true;
        qrCode = null; // Limpiar QR cuando se conecta
        console.log('✅ Conectado a WhatsApp exitosamente!');
      } else {
        connectionState = connection;
        console.log('📡 Estado de conexión:', connection);
      }
    });

    // Evento: Actualización de credenciales
    sock.ev.on('creds.update', saveCreds);

    // Evento: Mensajes recibidos (para futuras funcionalidades)
    sock.ev.on('messages.upsert', async (m) => {
      const message = m.messages[0];
      if (!message.key.fromMe && m.type === 'notify') {
        console.log('📨 Mensaje recibido:', {
          from: message.key.remoteJid,
          message: message.message?.conversation || 'Mensaje multimedia'
        });
      }
    });

  } catch (error) {
    console.error('❌ Error al conectar:', error);
    setTimeout(() => connectToWhatsApp(), 5000);
  }
}

/**
 * Formatear número de teléfono al formato de WhatsApp
 */
function formatPhoneNumber(number) {
  // Remover caracteres no numéricos
  let cleaned = number.replace(/\D/g, '');

  // Si no termina en @s.whatsapp.net, agregarlo
  if (!cleaned.includes('@')) {
    cleaned = cleaned + '@s.whatsapp.net';
  }

  return cleaned;
}

/**
 * ENDPOINT: Obtener código QR
 * GET /session/qr
 */
app.get('/session/qr', async (req, res) => {
  try {
    if (isConnected) {
      return res.status(200).json({
        success: true,
        message: 'Ya está conectado a WhatsApp',
        connected: true
      });
    }

    if (!qrCode) {
      return res.status(404).json({
        success: false,
        error: 'Código QR no disponible aún',
        message: 'Esperando generación del QR...'
      });
    }

    res.status(200).json({
      success: true,
      qr: qrCode,
      message: 'Escanea este código con WhatsApp'
    });

  } catch (error) {
    console.error('❌ Error en /session/qr:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Estado de la conexión
 * GET /session/status
 */
app.get('/session/status', (req, res) => {
  res.status(200).json({
    success: true,
    connected: isConnected,
    state: connectionState
  });
});

/**
 * ENDPOINT: Enviar mensaje de texto
 * POST /message/text
 * Body: { number, text }
 */
app.post('/message/text', async (req, res) => {
  try {
    if (!isConnected) {
      return res.status(503).json({
        success: false,
        error: 'No conectado a WhatsApp'
      });
    }

    const { number, text } = req.body;

    if (!number || !text) {
      return res.status(400).json({
        success: false,
        error: 'Número y texto son requeridos'
      });
    }

    const jid = formatPhoneNumber(number);
    console.log(`📤 Enviando texto a ${jid}`);

    const result = await sock.sendMessage(jid, { text });

    res.status(200).json({
      success: true,
      message: 'Mensaje enviado',
      messageId: result.key.id,
      timestamp: result.messageTimestamp
    });

  } catch (error) {
    console.error('❌ Error en /message/text:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Enviar imagen
 * POST /message/image
 * Body: { number, image, fileName, caption }
 */
app.post('/message/image', async (req, res) => {
  try {
    if (!isConnected) {
      return res.status(503).json({
        success: false,
        error: 'No conectado a WhatsApp'
      });
    }

    const { number, image, fileName, caption } = req.body;

    if (!number || !image) {
      return res.status(400).json({
        success: false,
        error: 'Número e imagen son requeridos'
      });
    }

    const jid = formatPhoneNumber(number);
    console.log(`📤 Enviando imagen a ${jid}: ${fileName || 'sin nombre'}`);

    // Convertir Base64 a Buffer
    const imageBuffer = Buffer.from(image, 'base64');

    const result = await sock.sendMessage(jid, {
      image: imageBuffer,
      caption: caption || '',
      fileName: fileName || 'image.jpg'
    });

    res.status(200).json({
      success: true,
      message: 'Imagen enviada',
      messageId: result.key.id,
      timestamp: result.messageTimestamp
    });

  } catch (error) {
    console.error('❌ Error en /message/image:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Enviar documento
 * POST /message/doc
 * Body: { number, document, fileName, mimetype }
 */
app.post('/message/doc', async (req, res) => {
  try {
    if (!isConnected) {
      return res.status(503).json({
        success: false,
        error: 'No conectado a WhatsApp'
      });
    }

    const { number, document, fileName, mimetype } = req.body;

    if (!number || !document) {
      return res.status(400).json({
        success: false,
        error: 'Número y documento son requeridos'
      });
    }

    const jid = formatPhoneNumber(number);
    console.log(`📤 Enviando documento a ${jid}: ${fileName || 'documento'}`);

    // Convertir Base64 a Buffer
    const docBuffer = Buffer.from(document, 'base64');

    const result = await sock.sendMessage(jid, {
      document: docBuffer,
      fileName: fileName || 'document.pdf',
      mimetype: mimetype || 'application/pdf'
    });

    res.status(200).json({
      success: true,
      message: 'Documento enviado',
      messageId: result.key.id,
      timestamp: result.messageTimestamp
    });

  } catch (error) {
    console.error('❌ Error en /message/doc:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Enviar audio
 * POST /message/audio
 * Body: { number, audio, fileName }
 */
app.post('/message/audio', async (req, res) => {
  try {
    if (!isConnected) {
      return res.status(503).json({
        success: false,
        error: 'No conectado a WhatsApp'
      });
    }

    const { number, audio, fileName } = req.body;

    if (!number || !audio) {
      return res.status(400).json({
        success: false,
        error: 'Número y audio son requeridos'
      });
    }

    const jid = formatPhoneNumber(number);
    console.log(`📤 Enviando audio a ${jid}: ${fileName || 'audio'}`);

    // Convertir Base64 a Buffer
    const audioBuffer = Buffer.from(audio, 'base64');

    const result = await sock.sendMessage(jid, {
      audio: audioBuffer,
      mimetype: 'audio/mp4',
      ptt: true // Nota de voz
    });

    res.status(200).json({
      success: true,
      message: 'Audio enviado',
      messageId: result.key.id,
      timestamp: result.messageTimestamp
    });

  } catch (error) {
    console.error('❌ Error en /message/audio:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Logout
 * POST /session/logout
 */
app.post('/session/logout', async (req, res) => {
  try {
    if (!isConnected) {
      return res.status(400).json({
        success: false,
        error: 'No hay sesión activa'
      });
    }

    await sock.logout();

    // Eliminar carpeta de autenticación
    const authPath = path.join(__dirname, 'auth_info');
    if (fs.existsSync(authPath)) {
      fs.rmSync(authPath, { recursive: true, force: true });
    }

    qrCode = null;
    isConnected = false;
    connectionState = 'disconnected';

    res.status(200).json({
      success: true,
      message: 'Sesión cerrada exitosamente'
    });

    // Reconectar después de 2 segundos
    setTimeout(() => connectToWhatsApp(), 2000);

  } catch (error) {
    console.error('❌ Error en /session/logout:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

/**
 * ENDPOINT: Reset/Forzar nuevo QR
 * POST /session/reset
 */
app.post('/session/reset', async (req, res) => {
  try {
    console.log('🔄 Reseteando sesión...');

    // Cerrar conexión actual si existe
    if (sock) {
      try {
        await sock.logout();
      } catch (err) {
        console.log('⚠️  No se pudo cerrar sesión limpiamente:', err.message);
      }
    }

    // Eliminar carpeta de autenticación
    const authPath = path.join(__dirname, 'auth_info');
    if (fs.existsSync(authPath)) {
      fs.rmSync(authPath, { recursive: true, force: true });
      console.log('🗑️  Sesión anterior eliminada');
    }

    // Resetear variables
    qrCode = null;
    isConnected = false;
    connectionState = 'disconnected';
    sock = null;

    res.status(200).json({
      success: true,
      message: 'Sesión reseteada. Generando nuevo QR...'
    });

    // Reconectar después de 1 segundo
    setTimeout(() => connectToWhatsApp(), 1000);

  } catch (error) {
    console.error('❌ Error en /session/reset:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});


/**
 * Iniciar servidor
 */
app.listen(PORT, () => {
  console.log('╔══════════════════════════════════════╗');
  console.log('║  WhatsApp API Server con Baileys     ║');
  console.log('║  Compatible con Delphi Rio Client    ║');
  console.log('╚══════════════════════════════════════╝');
  console.log('');
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
  console.log('');
  console.log('📋 Endpoints disponibles:');
  console.log(`   GET  http://localhost:${PORT}/session/qr       - Obtener código QR`);
  console.log(`   GET  http://localhost:${PORT}/session/status   - Estado de conexión`);
  console.log(`   POST http://localhost:${PORT}/message/text     - Enviar texto`);
  console.log(`   POST http://localhost:${PORT}/message/image    - Enviar imagen`);
  console.log(`   POST http://localhost:${PORT}/message/doc      - Enviar documento`);
  console.log(`   POST http://localhost:${PORT}/message/audio    - Enviar audio`);
  console.log(`   POST http://localhost:${PORT}/session/logout   - Cerrar sesión`);
  console.log(`   POST http://localhost:${PORT}/session/reset    - Resetear y generar nuevo QR`);
  console.log('');

  // Iniciar conexión con WhatsApp
  connectToWhatsApp();
});

// Manejo de señales de terminación
process.on('SIGINT', async () => {
  console.log('\n⚠️  Cerrando servidor...');

  if (isConnected && sock) {
    console.log('📴 Cerrando conexión con WhatsApp...');
    await sock.logout();
  }

  process.exit(0);
});
