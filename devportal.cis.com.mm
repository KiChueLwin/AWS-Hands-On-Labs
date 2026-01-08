server {
    server_name devportal.cis.com.mm;

    # Updated path to match your cloned repo
    root /home/ubuntu/projects/LMS_Parent_Student_Web/build/web;
    index index.html index.htm;
    charset utf-8;

    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Proxying to your existing dev backend
    location /api/ {
        proxy_pass https://lms.cis.com.mm/api/;
        proxy_set_header Host lms.cis.com.mm;
        proxy_ssl_verify off;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /storage/ {
        proxy_pass https://lms.cis.com.mm/storage/;
        proxy_set_header Host lms.cis.com.mm;
        proxy_ssl_verify off;
    }

    access_log /var/log/nginx/devportal_access.log;
    error_log /var/log/nginx/devportal_error.log;

    listen 443 ssl; # managed by Certbot
    listen [::]:443 ssl ipv6only=on; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/devportal.cis.com.mm/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/devportal.cis.com.mm/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

}
server {
    if ($host = devportal.cis.com.mm) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


    listen 80;
    listen [::]:80;
    server_name devportal.cis.com.mm;
    return 404; # managed by Certbot


}
