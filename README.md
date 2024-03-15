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

Изменяем параметр _wal_level_ - переключаемся на логическую репликацию:
```
postgres=# alter system set wal_level='logical';
ALTER SYSTEM
postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
postgres=# \q
postgres@vmotus1:/home/devops$ exit

devops@vmotus1:~$ sudo pg_ctlcluster 14 main restart
```

Cоздаем базу данных _repldb_, таблицы _test_ для записи, _test2_ для запросов на чтение, создаём публикацию таблицы _test_:
```
devops@vmotus1:~$ sudo su postgres
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database repldb;
CREATE DATABASE

postgres=# \c repldb;
You are now connected to database "repldb" as user "postgres".

repldb=# create table test as select generate_series(1, 4) as id, md5(random()::text)::char(10) as str;
SELECT 4

repldb=# select* from test;
 id |    str
----+------------
  1 | daaa8dc8ea
  2 | cd0b446d41
  3 | de68204d61
  4 | e1f7fd1f6d
(4 rows)

repldb=# create table test2 (id int, str char(10));
CREATE TABLE

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 8192 bytes |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes    |
(2 rows)


```

**2. Сессия#2** - Создаём второй кластер PostgreSQL 14 _main2_:
```


```



















<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
