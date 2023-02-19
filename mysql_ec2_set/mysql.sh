#!/usr/bin/env bash
sudo apt update
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y
sudo DEBIAN_FRONTEND=noninteractive apt install mysql-server -y
sudo systemctl start mysql

echo "Setting MySQL Root Account"

while :; do
    echo -n "Enter the password of the MySQL root account to use : "
    read -s PW
    echo
    echo -n "Re-enter your MySQL root account password : "
    read -s RPW
    echo

    if [ $PW == $RPW ]; then
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

read -p "Do you want to create a MySQL user account : [y/n] " ANSWER
case $ANSWER in
[Yy]*)
    read -p "Enter the create user name : " USERNAME
    while :; do
        echo -n "Enter the password of the $USERNAME account to use : "
        read -s USERPW
        echo
        echo -n "Re-enter your password : "
        read -s USERRPW
        echo

        if [ $USERPW == $USERRPW ]; then
            break
        else
            echo "Passwords do not match."
        fi
    done

    read -p "Do you want to allow external access : [y/n] " ALLOWACCESS
    case $ALLOWACCESS in
    [Yy]*)
        SETIP='%'
        sudo sed -i '0,/bind-address/{s/bind-address.*/bind-address = 0.0.0.0/}' /etc/mysql/mysql.conf.d/mysqld.cnf
        ;;
    [Nn]*)
        SETIP=localhost
        ;;
    esac
    sudo mysql -u root -p$PW <<QUERY
            create user '$USERNAME'@'$SETIP' identified with mysql_native_password by '$USERPW';
            grant all privileges on *.* to '$USERNAME'@'$SETIP' with grant option;
QUERY
    ;;

[Nn]*) ;;

esac

read -p "Do you want to create database : [y/n] " DBANSWER
case $DBANSWER in
[Yy]*)
    read -p "Enter the create database name : " DBNAME
    sudo mysql -u root -p$PW <<SETTING
            create database $DBNAME
SETTING
    sleep 1
    echo
    echo "Complete create database"
    ;;
[Nn]*) ;;

esac

sudo systemctl restart mysql
echo "Setting is complete"
