## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 3 "Установка PostgreSQL"

### Домашнее задание
Установка и настройка PostgteSQL в контейнере Docker

### Исходные данные
ВМ (облако): Ubuntu 22.04
ЛМ (локальная машина): Debian 12, PostgreSQL 15

### Решение

**1. ВМ** - устанавливаем Docker:
```
devops@vmotus:~$ curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh && rm get-docker.sh && sudo usermod -aG docker $USER && newgrp docker

# Executing docker install script, commit: e5543d473431b782227f8908005543bb4389b8de
+ sh -c apt-get update -qq >/dev/null
+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null
+ sh -c install -m 0755 -d /etc/apt/keyrings
+ sh -c curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
+ sh -c chmod a+r /etc/apt/keyrings/docker.gpg
+ sh -c echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" > /etc/apt/sources.list.d/docker.list
+ sh -c apt-get update -qq >/dev/null
+ sh -c DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-ce-rootless-extras docker-buildx-plugin >/dev/null
+ sh -c docker version
Client: Docker Engine - Community
 Version:           25.0.3
 API version:       1.44
 Go version:        go1.21.6
 Git commit:        4debf41
 Built:             Tue Feb  6 21:13:09 2024
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          25.0.3
  API version:      1.44 (minimum version 1.24)
  Go version:       go1.21.6
  Git commit:       f417435
  Built:            Tue Feb  6 21:13:09 2024
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.28
  GitCommit:        ae07eda36dd25f8a1b98dfbf587313b99c0190bb
 runc:
  Version:          1.1.12
  GitCommit:        v1.1.12-0-g51d5e94
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0

================================================================================

To run Docker as a non-privileged user, consider setting up the
Docker daemon in rootless mode for your user:

    dockerd-rootless-setuptool.sh install

Visit https://docs.docker.com/go/rootless/ to learn about rootless mode.


To run the Docker daemon as a fully privileged service, but granting non-root
users access, refer to https://docs.docker.com/go/daemon-access/

WARNING: Access to the remote API on a privileged Docker daemon is equivalent
         to root access on the host. Refer to the 'Docker daemon attack surface'
         documentation for details: https://docs.docker.com/go/attack-surface/

================================================================================
```

**2. ВМ** - создаём Docker-сеть pg-net:
```
devops@vmotus:~$ sudo docker network create pg-net

ebb7bc1e85f003722202244e38052afdfeb14746296eedbe56793e28ecb24e72
```

**3. ВМ** - создаём и запускаем контейнер pg-server (Сервер1) с подключением к созданной на предыдущем шаге сети. В контейнере разворачиваем сервер PostgreSQL 15, с указанием пароля и стандартного порта. Каталог данных монтируем в каталог ВМ /var/lib/postgresql:
```
devops@vmotus:~$ sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15

Unable to find image 'postgres:15' locally
15: Pulling from library/postgres
c57ee5000d61: Pull complete
ccc627e48df5: Pull complete
e76dc11f6e28: Pull complete
c1b58123c61e: Pull complete
804645fff271: Pull complete
89f1f64907a5: Pull complete
6bc1817d5e4d: Pull complete
9797b15515c6: Pull complete
d6c17feaa5d0: Pull complete
1ea2c89ba7ad: Pull complete
0de06f40e320: Pull complete
7c8e0fdbb77d: Pull complete
0700874d1e1d: Pull complete
4030d098b2c7: Pull complete
Digest: sha256:15b7f8dd3b75bc8f86ba8e875e92e560c03fd6314fe0a4d1315e169421aace01
Status: Downloaded newer image for postgres:15
d72eb3adadfa46cfa54f787c62d76ff37da3d375a2fefcc918320e0c16b8ec6e
```

**4. ВМ** - создаем и запускаем контейнер pg-client (Клиент) с подключением к созданной на шаге 2 сети. Запускаем _psql_ с подключением к хосту _pg-server_ под пользователем _postgres_. Вводим пароль, указанный на шаге 3:
```
devops@vmotus:~$ sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres
Password for user postgres:

psql (15.5 (Debian 15.5-1.pgdg120+1))
Type "help" for help.

```

**5. ВМ** - 






<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
