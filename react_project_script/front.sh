#!/usr/bin/env bash

KEYPAIR_NAME=front

# front 키페어 생성
aws ec2 create-key-pair --key-name $KEYPAIR_NAME --query 'KeyMaterial' --output text > $KEYPAIR_NAME.pem

if [ $? -ne 0 ]; then
    echo "Create Key Pair command failed"
    exit 1
fi

## 최소 권한 주기
chmod 400 $KEYPAIR_NAME.pem
if [ $? -ne 0 ]; then
    echo "chmod command failed"
    exit 1
fi

echo "키페어 생성 완료"
echo ""

SECURITY_NAME='front-sg'

# 보안 그룹 생성
SG=$(aws ec2 create-security-group --group-name $SECURITY_NAME --description $SECURITY_NAME --output text --query 'GroupId')
if [ $? -ne 0 ]; then
    echo "Create Security Group command failed"
    exit 1
fi

echo "보안 그룹 생성 완료"
echo ""

# 보안 그룹 인바운드 규칙 설정"

## 포트를 배열로 선언
declare -a PORTS=("22" "80" "443")

for PORT in "${PORTS[@]}"
do
    aws ec2 authorize-security-group-ingress --group-id $SG --protocol tcp --port $PORT --cidr 0.0.0.0/0 >/dev/null 2>&1
done
if [ $? -ne 0 ]; then
    echo "Create Security Group Rules command failed"
    exit 1
fi

# 인스턴스 생성
UBUNTU="ami-0e735aba742568824"
NUM=1

INSTANCE=$(aws ec2 run-instances --image-id $UBUNTU --count $NUM --instance-type t2.micro --key-name $KEYPAIR_NAME --security-group-ids $SG --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=frontend}]' --output text --query 'Instances[0].InstanceId')
if [ $? -ne 0 ]; then
    echo "Create Instance command failed"
    exit 1
fi
echo "인스턴스 생성 완료"
echo ""

echo "인스턴스가 실행 될 때까지 대기중입니다."
aws ec2 wait instance-running --instance-ids $INSTANCE
echo "인스턴스 실행 완료"
echo ""

while :; do
    
    # 인스턴스의 상태를 조회하여 상태 코드를 추출
    STATUS_CODE=$(aws ec2 describe-instances --instance-ids $INSTANCE --query 'Reservations[*].Instances[*].State.Code' --output text)

    # 인스턴스가 실행 중이면 탄력적 IP를 할당
    if [ $STATUS_CODE -eq 16 ]; then

        # 탄력적 IP 생성
        STATIC_IP=$(aws ec2 allocate-address --query "PublicIp" --output text)
        if [ $? -ne 0 ]; then
            echo "Create static IP command failed"
        exit 1
        fi

        ## 탄력적 IP 태그 지정
        ALLOCATION_ID=$(aws ec2 describe-addresses --public-ips $STATIC_IP --query 'Addresses[0].AllocationId' --output text)
        aws ec2 create-tags --resources $ALLOCATION_ID --tags Key=Name,Value=backend
         if [ $? -ne 0 ]; then
            echo "Set static IP tag command failed"
        exit 1
        fi

        ## 탄력적 IP 할당
        aws ec2 associate-address --instance-id $INSTANCE --public-ip $STATIC_IP > /dev/null
        if [ $? -ne 0 ]; then
            echo "Set static IP command failed"
        exit 1
        fi

        # 접속 주소 출력
        PDNS=$(aws ec2 describe-instances --instance-ids $INSTANCE --query 'Reservations[*].Instances[*].PublicDnsName' --output text)

        echo "아래 주소를 복사해서 접속하세요."
        echo ""
        echo "ssh -i $KEYPAIR_NAME.pem ubuntu@$PDNS"
        break
    
    else
        sleep 5
        continue
    fi
done


