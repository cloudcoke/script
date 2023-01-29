#!/usr/bin/env bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt install mysql-server -y
sudo systemctl start mysql

while :;do 
echo -n "Enter the password of the root account to use : "
read -s PW
echo
echo -n "Re-enter your password : " 
read -s RPW
echo

if [ "$PW" == "$RPW" ]; then
    break
else 
    echo "Passwords do not match."
fi
done

sudo mysql -u root -e "alter user 'root'@'localhost' identified with mysql_native_password by '$PW'"
sleep 1
echo 
echo "Complete root Password"
echo

read -p "Enter the create user name : " USERNAME
while :;do 
echo -n "Enter the password of the $USERNAME account to use : "
read -s USERPW
echo
echo -n "Re-enter your password : " 
read -s USERRPW
echo

if [ "$USERPW" == "$USERRPW" ]; then
    break
else 
    echo "Passwords do not match."
fi
done

read -p "Enter the create database name : " DBNAME

sudo mysql -u root -p$PW <<QUERY
create user '$USERNAME'@'%' identified with mysql_native_password by '$USERPW';
grant all privileges on *.* to '$USERNAME'@'%' with grant option;
create database $DBNAME
QUERY

sleep 2
echo
echo "Complete create user and database"
sudo sed -i '0,/bind-address/{s/bind-address.*/bind-address = 0.0.0.0/}' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3000
echo "Setup is complete"