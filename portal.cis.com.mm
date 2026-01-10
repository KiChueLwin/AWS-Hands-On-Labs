server {
    listen 80;
    listen [::]:80;
    server_name portal.cis.com.mm;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name portal.cis.com.mm;

    ssl_certificate /etc/letsencrypt/live/portal.cis.com.mm/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/portal.cis.com.mm/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    root /home/ubuntu/projects/LMS_OPS_Parent_Student_Web/build/web;
    index index.html index.htm;
    charset utf-8;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

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
    }

    location /storage/ {
        proxy_pass https://api.cis.com.mm/storage/;
        proxy_set_header Host api.cis.com.mm;
        proxy_ssl_verify off;
    }

    location /uploads/ {
        proxy_pass https://api.cis.com.mm/uploads/;
        proxy_set_header Host api.cis.com.mm;
        proxy_ssl_verify off;
    }

    access_log /var/log/nginx/portal_access.log;
    error_log /var/log/nginx/portal_error.log;
}
