#!/usr/bin/env bash

read -p "Enter a Key Pair name to use : " KEYPAIR_NAME

WD=$(pwd)

aws ec2 create-key-pair --key-name $KEYPAIR_NAME --query 'KeyMaterial' --output text >$WD/$KEYPAIR_NAME.pem
if [ $? -ne 0 ]; then
    echo "Create Key Pair command failed"
    exit 1
fi

echo "Enter a Sudo Password"
sudo chmod 400 $WD/$KEYPAIR_NAME.pem
if [ $? -ne 0 ]; then
    echo "Chmod command failed"
    exit 1
fi

echo "Create Key Pair Success"
echo ""

read -p "Enter a Security Group Name to use : " SECURITY_NAME

SG=$(aws ec2 create-security-group --group-name $SECURITY_NAME --description $SECURITY_NAME --output text --query 'GroupId')
if [ $? -ne 0 ]; then
    echo "Create Security Group command failed"
    exit 1
fi

echo "Create Security Group Success"
echo ""

aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port 22 --cidr 0.0.0.0/0 >/dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "Create Security Group Rules command failed [22]"
    exit 1
fi

echo "Create Security Group Rules Success [Protocol : tcp / Port : 22]"
echo ""

while :; do
    read -p "Do you want to create Security Group Rules : [y/n] " ANSWER
    case $ANSWER in
    [Yy]*)
        read -p "Enter a protocol to use [tcp | udp ] (Default : tcp) " PROTOCOL
        if [ -z "$PROTOCOL" ]; then
            PROTOCOL="tcp"
        fi

        while :; do
            read -p "Enter a port to use (80): " PORT

            if [ -z "$PORT" ]; then
                echo "You must enter a port"
            else
                break
            fi
        done

        aws ec2 authorize-security-group-ingress --group-id $SG --protocol $PROTOCOL --port $PORT --cidr 0.0.0.0/0 >/dev/null 2>&1

        if [ $? -ne 0 ]; then
            echo "Create Security Group Rules command failed"
            exit 1
        fi

        echo "Create Security Group Rules Success [Protocol : $PROTOCOL / Port : $PORT]"
        echo ""
        ;;
    [Nn]*)
        break
        ;;
    esac
done

echo "Ubuntu Versions 1) 22.04 LTS 2) 20.04 LTS 3) 18.04 LTS"
read -p "Choose the ubuntu version to use (Default : 22.04 LTS) " VERSION

if [ -z "$VERSION" ]; then
    VERSION=1
fi

case $VERSION in
1) UBUNTU="ami-0e38c97339cddf4bd" ;;
2) UBUNTU="ami-0e735aba742568824" ;;
3) UBUNTU="ami-030e520ec063f6467" ;;
esac

read -p "Enter the number of instances to create (Default : 1) " NUM

if [ -z "$NUM" ]; then
    NUM=1
fi

INSTANCE=$(aws ec2 run-instances --image-id $UBUNTU --count $NUM --instance-type t2.micro --key-name $KEYPAIR_NAME --security-group-ids $SG --output text --query 'Instances[0].InstanceId')
if [ $? -ne 0 ]; then
    echo "Create Instance command failed"
    exit 1
fi

echo "Create Instances Success"
echo ""

PDNS=$(aws ec2 describe-instances --instance-ids $INSTANCE --query 'Reservations[*].Instances[*].PublicDnsName' --output text)

echo "Copy and Paste it in the terminal"
echo ""
echo "ssh -i $KEYPAIR_NAME.pem ubuntu@$PDNS"
