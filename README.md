## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 12 "Резервное копирование и восстановление"

### Домашнее задание
Бэкапы

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 14

### Решение

**1.** - Создаём базу данных _otusdb_, схему _otusch_, таблицу _students_ и заполняем её тестовыми данными:
```
devops@vmotus:~$ sudo su postgres

postgres@vmotus:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database otusdb;
CREATE DATABASE

postgres=# \c otusdb
You are now connected to database "otusdb" as user "postgres".

otusdb=# create schema otusch;
CREATE SCHEMA

otusdb=# create table otusch.students as select generate_series(1, 100) as id, md5(random()::text)::char(10) as fio;
SELECT 100

otusdb=# select* from otusch.students order by id limit 10;
 id |    fio
----+------------
  1 | e7e89cd037
  2 | f1f6635468
  3 | aadb53855f
  4 | 6cca0a15a4
  5 | 292c839ac9
  6 | 9c1e1dc951
  7 | adbee51f86
  8 | 3edb5634aa
  9 | dc7a9a09e1
 10 | 8c668255a7
(10 rows)

otusdb=# \q
```

**2.** - Создаём каталог для бэкапов и делаем логический бэкап таблицы _students_ утилитой _copy_:
```
postgres@vmotus:/home/devops$ mkdir /tmp/backups/

postgres@vmotus:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c otusdb

otusdb=# \copy otusch.students to '/tmp/backups/sudetnts.sql';
COPY 100
```


Восстановим данные из бэкапа во вторую таблицу - _students_copy_. Эту таблицу необходимо создать перед восстановлением данных, т.к. логическое резервное копирование предусматривает только копирование данных.
```
otusdb=# create table otusch.students_copy (id int, fio char(10));
CREATE TABLE

otusdb=# \copy otusch.students_copy from '/tmp/backups/sudetnts.sql';
COPY 100

otusdb=# select* from otusch.students_copy order by id limit 10;
 id |    fio
----+------------
  1 | e7e89cd037
  2 | f1f6635468
  3 | aadb53855f
  4 | 6cca0a15a4
  5 | 292c839ac9
  6 | 9c1e1dc951
  7 | adbee51f86
  8 | 3edb5634aa
  9 | dc7a9a09e1
 10 | 8c668255a7
(10 rows)
```

**3.** - Делаем бэкап полученных двух таблиц утилитой pg_dump в кастомном сжатом формате:






<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
