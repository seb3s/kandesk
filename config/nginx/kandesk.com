server {
    listen 443 ssl;
    server_name kandesk.com;
    access_log /var/log/nginx/kandesk.log;
    error_log /var/log/nginx/kandesk_error.log;

    add_header Strict-Transport-Security "max-age=15552000";
    ssl_certificate /etc/letsencrypt/live/kandesk.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/kandesk.com/privkey.pem;

    add_header Referrer-Policy strict-origin-when-cross-origin;
    #add_header Content-Security-Policy "default-src 'self' https://*.typekit.net https://cdnjs.cloudflare.com 'unsafe-inline' 'unsafe-eval'; img-src 'self' data:";

    location / {
        proxy_pass http://127.0.0.1:4001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}