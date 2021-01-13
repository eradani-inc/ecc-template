module.exports = {
    apps: [
        {
            name: 'ecc-template',
            script: 'dist/src/app.js',

            // Options reference: https://pm2.keymetrics.io/docs/usage/application-declaration/
            instances: 'max',
            exec_mode: 'cluster',
            autorestart: true,
            restart_delay: 2000,
            cron_restart: '0 0 * * *',
            env: {
                APP_ENV: 'development'
            },
            env_production: {
                APP_ENV: 'production'
            }
        }
    ]
};
