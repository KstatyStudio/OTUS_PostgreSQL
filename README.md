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

**3. ВМ** - создаём и запускаем контейнер pg-server (Сервер) с подключением к созданной на предыдущем шаге сети. В контейнере разворачиваем сервер PostgreSQL 15, с указанием пароля и стандартного порта. Каталог данных монтируем в каталог ВМ /var/lib/postgresql:
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

**5. ВМ** - создаём базу данных otus:
```
postgres=# create database otus;
CREATE DATABASE
```

Подключаемся к базе данных _otus_ и создаём таблицу _test_:
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".

otus=# create table test (id int, str text);
CREATE TABLE
```

Заполняем таблицу _test_ данными:
```
otus=# insert into test(id, str) values(1, 'first');
INSERT 0 1

otus=# insert into test(id, str) values(2, 'second');
INSERT 0 1
```

Выходим из _psql_:
```
postgres=# \q
```

**6. ВМ** - проверяем, что подключились через отдельный контейнер:
```
devops@vmotus:~$ sudo docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                                       NAMES
2a86e9433ee0   postgres:15   "docker-entrypoint.s…"   5 minutes ago   Up 4 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   pg-server
```

**7. ЛМ** - проверяем подключние к контейнеру pg-server из внешней сети:
```
root@test:~# psql -p 5432 -U postgres -h 158.160.104.92 -d otus -W
Пароль:
psql (15.3 (Debian 15.3-0+deb12u1), сервер 15.5 (Debian 15.5-1.pgdg120+1))
Введите "help", чтобы получить справку.
```

Выводим список таблиц базы данных _otus_ и отключаемся:
```
otus=# \d
          Список отношений
 Схема  | Имя  |   Тип   | Владелец
--------+------+---------+----------
 public | test | таблица | postgres
(1 строка)

otus=# \q
```

**8. ВМ** - останавливаем контейнер pg-server:
```
devops@vmotus:~$ sudo docker stop 2a86e9433ee0
2a86e9433ee0
```

Удаляем контейнер pg-server:
```
devops@vmotus:~$ sudo docker rm 2a86e9433ee0
2a86e9433ee0
```

Создаём контейнер с сервером заново (дублируем шаг 3):
```
devops@vmotus:~$ sudo docker run --name pg-server --network pg-net -e POSTGRES_PASSWORD=postgres -d -p 5432:5432 -v /var/lib/postgres:/var/lib/postgresql/data postgres:15

90fe28a84e9fa95923860ac9783c393ad6ed8ecad959c732561c9c58d1595e50
```

**9. ВМ** - подключаемся к контейнеру pg-server из контенера с клиентом (дублируем шаг 4):
```
devops@vmotus:~$ sudo docker run -it --rm --network pg-net --name pg-client postgres:15 psql -h pg-server -U postgres
Password for user postgres:

psql (15.5 (Debian 15.5-1.pgdg120+1))
Type "help" for help.
```

Выводим список баз данных:
```
postgres=# \l
                                                List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    | ICU Locale | Locale Provider |   Access privileges
-----------+----------+----------+------------+------------+------------+-----------------+-----------------------
 otus      | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            |
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 |            | libc            | =c/postgres          +
           |          |          |            |            |            |                 | postgres=CTc/postgres
(4 rows)
```

База данных _otus_ присутствует в списке (не удалена вместе с предыдущим контейнером с сервером PostgreSQL).

Выводим список отношений:
```

postgres=# \d
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | test | table | postgres
(1 row)
```

Таблица _test_ на месте.

Переходим в базу данных _otus_ и выводим содержимое таблицы _test_:
```

postgres=# \c otus
You are now connected to database "otus" as user "postgres".
otus=# select* from test;
 id |  str
----+--------
  1 | first
  2 | second
(2 rows)
```
Данные на месте. Есть счастье в жизни, товарищи, т.е. коллеги!
Finishing, closing, and going home.

Яндекс.Облако -17 руб. с приостановкой ВМ на 1 день :)

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
