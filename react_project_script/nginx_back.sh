#!/usr/bin/env bash

# 기본값
DOMAIN="api.cloudcoke.site"
EMAIL="cloudcoke.dev@gmail.com"

# 입력된 인자가 있는지 확인하고 변수 변경
while getopts "d:m:" opt; do
    case $opt in
        d) # -d (도메인 주소)
            DOMAIN=$OPTARG
            ;;
        m) # -m (이메일 주소)
            EMAIL=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

# 패키지 설치
sudo apt-get update
sudo apt-get install nginx snapd -y

# 부팅 시 자동 시작
sudo systemctl enable nginx

# https를 위한 작업
sudo snap install core
sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# nginx https 인증서 적용
sudo certbot --nginx -d $DOMAIN -m $EMAIL --non-interactive --agree-tos

# 인증서 갱신 확인
sudo certbot renew --dry-run

# 인증서 갱신 cron 등록
cat <(crontab -l 2>/dev/null) <(echo '0 18 1 * * sudo certbot renew --renew-hook="sudo systemctl restart nginx"') | crontab - > /dev/null 2>&1

# nginx 설정 파일 경로
NGINX_CONF="/etc/nginx/sites-available/default"

# 리버스 프록시 적용
sudo cp $NGINX_CONF $NGINX_CONF.bak
sudo sed -i '1,92d' $NGINX_CONF
sudo sed -i 's|root /var/www/html;||g' $NGINX_CONF
sudo sed -i 's|index index.html index.htm index.nginx-debian.html;||g' $NGINX_CONF
sudo sed -i 's|location / {|location / {\n\t\tproxy_set_header HOST $host;\n\t\tproxy_pass http://127.0.0.1:3000;\n\t\tproxy_redirect off;|' $NGINX_CONF
sudo sed -i 's|try_files $uri $uri/ =404;||g' $NGINX_CONF

sudo systemctl restart nginx

# node lts 버전 설치
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
source ~/.nvm/nvm.sh
nvm install --lts

# npm 최신 버전 설치
npm install -g npm@latest

# pm2 설치
npm install pm2 -g

# 테스트 파일 다운로드 후 실행
mkdir www && cd www
curl -O https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/server.js
pm2 start server.js --watch