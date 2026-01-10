# --- File: /etc/nginx/sites-available/ops.cis.com.mm.conf (Corrected Frontend Path) ---
server {
    listen 80;
    listen [::]:80;
    server_name ops.cis.com.mm;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    server_name ops.cis.com.mm;
    client_max_body_size 20M;
   
    add_header Content-Security-Policy "script-src 'self' blob:; worker-src blob: 'self';";

    # --- THIS IS THE CORRECTED PATH ---
    root /home/ubuntu/projects/CN_LMS_Web/build/web;
    index index.html index.htm;
    charset utf-8;

    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 5;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location = /index.html {
        add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
        expires off;
    }

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass https://api.cis.com.mm/api/;
        proxy_set_header Host api.cis.com.mm;
        proxy_ssl_verify off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        client_body_buffer_size 128k; 
        proxy_buffers 16 1m; 
        proxy_buffer_size 1m;
    }

    location /uploads/ {
        proxy_pass https://api.cis.com.mm/uploads/;
        proxy_set_header Host api.cis.com.mm;
        proxy_ssl_verify off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
    }

    location /storage/ {
        proxy_pass https://api.cis.com.mm/storage/;
        proxy_set_header Host api.cis.com.mm;
        proxy_ssl_verify off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Ssl on;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        add_header Cache-Control "no-store, no-cache, must-revalidate, max-age=0";
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_read_timeout 300;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "no-referrer-when-downgrade";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    ssl_certificate /etc/letsencrypt/live/ops.cis.com.mm/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ops.cis.com.mm/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location ~ /\.env { deny all; }

    location ~ /\.(?!well-known|env).* {
        deny all;
    }

    access_log /var/log/nginx/ops.cis.com.mm_access.log;
    error_log /var/log/nginx/ops.cis.com.mm_error.log;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt { access_log off; log_not_found off; }
}
