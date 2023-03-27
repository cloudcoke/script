#!/ulslr/bin/env bash

# 기본값
SECRET=password
DBNAME=hello
USER=admin
PASSWORD=password
BACK_DNS="api.cloudcoke.site"

# 입력된 인자가 있는지 확인하고 변수 변경
while getopts "s:u:p:i:d:" opt; do
    case $opt in
    s)
        SECRET="$OPTARG"
        ;;

    u)
        USER="$OPTARG"
        ;;
    p)
        PASSWORD="$OPTARG"
        ;;

    i)  
        BACK_DNS="$OPTARG"
        ;;

    d)
        DBNAME="$OPTARG"
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
sudo apt update
sudo apt install mysql-server -y
sudo systemctl start mysql

# root 패스워드 설정
sudo mysql -u root -e "alter user 'root'@'localhost' identified with mysql_native_password by '${SECRET}'"
if [ $? -ne 0 ]; then
    echo "root password setting failed"
    exit 1
fi

echo "root 패스워드 설정 완료"

# mysql 접속 허용 주소 설정
BACK_SERVER=$(nslookup $BACK_DNS | awk '/^Address: / { print $2 }')
MYSQL_CONF="/etc/mysql/mysql.conf.d/mysqld.cnf"
sudo cp $MYSQL_CONF $MYSQL_CONF.bak
sudo sed -i "0,/bind-address/{s/bind-address.*/bind-address = $BACK_SERVER/}" $MYSQL_CONF


# DB 생성 및 USER 생성
sudo mysql -u root -p"${SECRET}" <<QUERY
    create database $DBNAME;
    grant all privileges on $DBNAME.* to '$USER'@'"${BACK_DNS}"' identified by "${PASSWORD}" with grant option;
    grant all privileges on $DBNAME.* to '$USER'@'"${BACK_SERVER}"' identified by "${PASSWORD}" with grant option;
QUERY
if [ $? -ne 0 ]; then
    echo "DB Create & User Create failed"
    exit 1
fi

echo "DB 생성 및 USER 생성 완료"

# 재시작 및 등록
sudo systemctl restart mysql 
sudo systemctl enable mysql