module.exports = {
    apps: [{
        name: 'whatsapp-api',
        script: './baileys-server.js',

        // Configuración de instancias
        instances: 1,
        exec_mode: 'fork',

        // Variables de entorno
        env: {
            NODE_ENV: 'production',
            PORT: 3000
        },

        // Auto-restart
        autorestart: true,
        watch: false,
        max_memory_restart: '1G',

        // Reintentos en caso de error
        max_restarts: 10,
        min_uptime: '10s',
        restart_delay: 4000,

        // Logs
        error_file: './logs/pm2-error.log',
        out_file: './logs/pm2-out.log',
        log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
        merge_logs: true,

        // Configuración de tiempo
        time: true,

        // Kill timeout
        kill_timeout: 5000,

        // Configuración de escucha
        listen_timeout: 10000,

        // Configuración adicional
        cron_restart: '0 3 * * *', // Reinicio diario a las 3 AM (opcional)

        // Argumentos de Node.js
        node_args: '--max-old-space-size=1024'
    }]
};
