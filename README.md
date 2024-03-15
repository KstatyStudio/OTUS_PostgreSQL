## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 13 "Виды и устройство репликации в PostgreSQL. Практика применения"

### Домашнее задание
Репликация

### Исходные данные
ВМ# (облако): Ubuntu 22.04, PostgreSQL 14, PostgreSQL 16, SSH-сессии (4 шт.)

### Решение

**1. Сессия#1** - Устанавливаем сервер PostgreSQL 14, смотрим список кластеров:
```
devops@vmotus1:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14

devops@vmotus1:~$ sudo su postgres

postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```
Установлен один кластер - _main_ (порт 5432).

Проверяем настройки репликации по умолчанию:
```
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# select name, setting from pg_settings where name in ('wal_level', 'max_wal_senders', 'synchronous_commit');
        name        | setting
--------------------+---------
 max_wal_senders    | 10
 synchronous_commit | on
 wal_level          | replica
(3 rows)
```

Изменяем параметр _wal_level_ - переключаемся на логическую репликацию, меняем стандартный пароль пользователя _postgres_, презагружаем кластер _main_ для применения изменений:
```
postgres=# alter system set wal_level='logical';
ALTER SYSTEM

postgres=# \password
Enter new password for user "postgres":
Enter it again:
postgres=# \q
postgres@vmotus1:/home/devops$ exit

devops@vmotus1:~$ sudo pg_ctlcluster 14 main restart
```

Cоздаем базу данных _repldb_, таблицы _test_ для записи, _test2_ для запросов на чтение:
```
devops@vmotus1:~$ sudo su postgres
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database repldb;
CREATE DATABASE

postgres=# \c repldb;
You are now connected to database "repldb" as user "postgres".

repldb=# create table test (id int, str char(10));
CREATE TABLE

repldb=# create table test2 (id int, str char(10));
CREATE TABLE

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 0 bytes    |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes    |
(2 rows)
repldb=# \q
```

**2. Сессия#2** - Создаём второй кластер PostgreSQL 14 _main2_:
```
devops@vmotus1:~$ sudo su postgres
postgres@vmotus1:/home/devops$ pg_createcluster -d /var/lib/postgresql/14/main2 14 main2
Creating new PostgreSQL cluster 14/main2 ...
/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main2 --auth-local peer --auth-host scram-sha-256 --no-instructions
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /var/lib/postgresql/14/main2 ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok
Warning: systemd does not know about the new cluster yet. Operations like "service postgresql start" will not handle it. To fix, run:
  sudo systemctl daemon-reload
Ver Cluster Port Status Owner    Data directory               Log file
14  main2   5433 down   postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

Удаляем каталог кластера _main2_:
```
postgres@vmotus1:/home/devops$ rm -rf /var/lib/postgresql/14/main2

postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner     Data directory               Log file
14  main    5432 online postgres  /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
14  main2   5433 down   <unknown> /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

**3. Сессия#1** - Создаём бэкап кластера _main_ в каталоге кластера _main2_:
```
postgres@vmotus1:/home/devops$ pg_basebackup -p 5432 -D /var/lib/postgresql/14/main2

postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory               Log file
14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
14  main2   5433 down   postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

**4. Сессия#2** - Запускаем кластер _main2_ (порт 5433):
```
postgres@vmotus1:/home/devops$ pg_ctlcluster 14 main2 start
postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory               Log file
14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
14  main2   5433 online postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

Подключаемся к базе данных _repldb_ в кластере _main2_ (порт 5433), заполняем данными таблицу _test2_, создаём публикацию таблицы _test2_:
```
postgres@vmotus1:/home/devops$ psql -p 5433
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c repldb
You are now connected to database "repldb" as user "postgres".

repldb=# \conninfo
You are connected to database "repldb" as user "postgres" via socket in "/var/run/postgresql" at port "5433".

repldb=# \dt+
                                    List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |  Size   | Description
--------+-------+-------+----------+-------------+---------------+---------+-------------
 public | test  | table | postgres | permanent   | heap          | 0 bytes |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes |
(2 rows)

repldb=# insert into test2 (id, str) select generate_series(1, 4), md5(random()::text)::char(10);
INSERT 0 4

repldb=# select* from test2;
 id |    str
----+------------
  1 | f17d283e0f
  2 | 525f680929
  3 | bf0ddd856d
  4 | f55a9e7b41
(4 rows)

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 0 bytes    |
 public | test2 | table | postgres | permanent   | heap          | 8192 bytes |
(2 rows)

repldb=# \dRp+
                           Publication test2_pub
  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
----------+------------+---------+---------+---------+-----------+----------
 postgres | f          | t       | t       | t       | t         | f
Tables:
    "public.test2"
```

**5. Сессия#2** - Заполняем таблицу _test_ в кластере _main_:
```
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c repldb
You are now connected to database "repldb" as user "postgres".

repldb=# \conninfo
You are connected to database "repldb" as user "postgres" via socket in "/var/run/postgresql" at port "5432".

repldb=# insert into test (id, str) select generate_series(1, 3), md5(random()::text)::char(10);
INSERT 0 3

repldb=# select* from test;
 id |    str
----+------------
  1 | 938a3da5a4
  2 | 6d53d88e01
  3 | a9e8426663
(3 rows)

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 8192 bytes |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes    |
(2 rows)
```

Cоздаём публикацию таблицы _test_:
```
repldb=# create publication test_pub for table test;
CREATE PUBLICATION

repldb=# \dRp+
                            Publication test_pub
  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
----------+------------+---------+---------+---------+-----------+----------
 postgres | f          | t       | t       | t       | t         | f
Tables:
    "public.test"
```

Создаём подписку 








<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
