#!/bin/bash
# web01 - Nginx reverse proxy (Ubuntu 22.04)

export DEBIAN_FRONTEND=noninteractive

# ضمان تعرّف الأسماء حتى لو hostmanager لسه ما حدّثش /etc/hosts
add_host() { grep -qw "$2" /etc/hosts || echo "$1 $2" >> /etc/hosts; }
add_host 192.168.56.15 db01
add_host 192.168.56.14 mc01
add_host 192.168.56.13 rmq01
add_host 192.168.56.12 app01

apt-get update -y
apt-get install nginx -y

cat > /etc/nginx/sites-available/vproapp <<'EOF'
upstream vproapp {
    server app01:8080;
}

server {
    listen 80;

    location / {
        proxy_pass http://vproapp;
    }
}
EOF

# إزالة الإعداد الافتراضي وتفعيل الموقع (لازم مسار كامل في ln)
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

nginx -t
systemctl enable nginx
systemctl restart nginx

echo "web01 provisioning finished."
