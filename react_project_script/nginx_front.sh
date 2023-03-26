#!/usr/bin/env bash
# 패키지 설치
sudo apt-get update
sudo apt-get install nginx snapd -y

# 부팅 시 자동 시작
sudo systemctl enable nginx

# nginx 파일 수정
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
sudo sed -i 's|root /var/www/html;|root /home/ubuntu/www/build;|g' /etc/nginx/sites-available/default
sudo sed -i 's|index index.html index.htm index.nginx-debian.html;|index index.html;|g' /etc/nginx/sites-available/default
sudo sed -i 's|try_files $uri $uri/ =404;|try_files $uri $uri/ index.html;|g' /etc/nginx/sites-available/default

# 테스트를 위한 작업
mkdir -p www/build
echo "front server" > www/build/index.html

# https를 위한 작업
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

sudo certbot --nginx -d www.cloudcoke.site -m cloudcoke.dev@gmail.com --non-interactive --agree-tos

# 인증서 갱신 설정
sudo certbot renew --dry-run

# nginx 재시작
sudo systemctl restart nginx