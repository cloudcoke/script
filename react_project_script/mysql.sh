#!/usr/bin/env bash

# 기본값
SECRET=password
DBNAME=hello
USER=admin
PASSWORD=password
BACK_DNS=api.cloudcoke.site

# 입력된 인자가 있는지 확인하고 변수 변경
while getopts "s:p:u:i:" opt; do
    case $opt in
    s)
        SECRET=$OPTARG
        ;;

    u)
        USER=$OPTARG
        ;;
    p)
        PASSWORD=$OPTARG
        ;;

    i)  
        BACK_DNS=$OPTARG
        ;;

    d)
        DBNAME=$OPTARG
        ;;

    \?)
        echo "Invalid option: -$OPTARG" > &2
        exit 1
        ;;

    :)
        echo "Option -$OPTARG requires an argument." > &2
        exit 1
        ;;
    esac
done

# 패키지 설치
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql

# root 패스워드 설정
sudo mysql -u root -e "alter user 'root'@'localhost identified with mysql_native_password by '$SECRET'"

# mysql 접속 허용 주소 설정
BACK_SERVER=$(nslookup $BACK_DNS | awk '/^Address: / { print $2 }')
sudo sed -i '0,/bind-address/{s/bind-address.*/bind-address = $BACK_DNS/}' /etc/mysql/mysql.conf.d/mysqld.cnf

# DB 생성 및 USER 생성
sudo mysql -u root -p$SECRET <<QUERY
    create database $DBNAME
    create user '$USER'@'$BACK_DNS' identified with mysql_native_password by '$PASSWORD';
    grant all privileges on $DBNAME.* to '$USER'@'$BACK_DNS' with grant option;
QUERY

# 재시작 및 등록
sudo systemctl restart mysql && sudo systemctl enable mysql