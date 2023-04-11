# Front 서버 인스턴스 생성

```shell
curl -o- https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/front.sh | bash
```

# Back 서버 인스턴스 생성

```shell
curl -o- https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/back.sh | bash
```

# DB 서버 인스턴스 생성

```shell
curl -o- https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/db.sh | bash
```

# Front 서버 Nginx 설정

```shell
curl -O https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/nginx_front.sh
```

```shell
bash nginx_front.sh -d [your_domain] -m [your_email]
```

# Back 서버 Nginx 설정

```shell
curl -O https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/nginx_back.sh
```

```shell
bash nginx_back.sh -d [your_domain] -m [your_email]
```

# DB 서버 설정

```shell
curl -O https://raw.githubusercontent.com/cloudcoke/script/main/react_project_script/mysql.sh
```

```shell
bash mysql.sh -s [root_패스워드] -u [유저_이름] -p [유저_패스워드] -i [back_서버_DNS_주소] -d [데이터_베이스_이름]
```
