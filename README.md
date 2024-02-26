## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 7 "Логический уровень PostgreSQL"

### Домашнее задание
Работа с базами данных, пользователями и правами

### Исходные данные
ВМ (облако): Ubuntu 22.04 

### Решение

**1.** - Устанавливаем PostgreSQL 13:
```
devops@vmotus07:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-13
```

**2.** - Запускаем _psql_ под пользователем _postgres_:
```
devops@vmotus07:~$ sudo su postgres
postgres@vmotus07:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.
```
Примечание: рабочий каталог - домашний каталог пользоваетля _postgres_.

Создаём базу данных _testdb_:
```
postgres=# create database testdb;
CREATE DATABASE
```

Подключаемся к базе данных _testdb_ пользователем _postgres_:
```
postgres=# \c testdb
You are now connected to database "testdb" as user "postgres".
```

Создаём схему _testnm_:
```
testdb=# create schema testnm;
CREATE SCHEMA
```

Создаём таблицу _t1_, содержащую один столбец _c1_ типа _integer_:
```
testdb=# create table t1 (c1 integer);
CREATE TABLE
```

Заполняем таблицу _t1_ данными:
```
testdb=# insert into t1 values(1);
INSERT 0 1
```

создаём новуцю роль _readonly_:
```
testdb=# create role readonly;
CREATE ROLE
```

Назаначаем роли _readonly_ право на подключение к базе данных _testdb_:
```
testdb=# grant connect on database testdb to readonly;
GRANT
```

Назаначаем роли _readonly_ право на использование схемы _testnm_:
```
testdb=# grant usage on schema testnm to readonly;
GRANT
```

Назаначаем роли _readonly_ право на _select_ всех таблиц схемы _testnm_:
```
testdb=# grant select on all tables in schema testnm to readonly;
GRANT
```

Создаём пользователя _testread_:
```
testdb=# create user testread with password 'test123';
CREATE ROLE
```

Назначаем роль _readonly_ пользователю _testread_:
```
testdb=# grant readonly to testread;
GRANT ROLE
```

**3.** - Подключаемся к базе данных _testdb_ пользователем _testread_:
```
testdb=# \c testdb testread
connection to server on socket "/var/run/postgresql/.s.PGSQL.5432" failed: FATAL:  Peer authentication failed for user "testread"
Previous connection kept
```

Выходим из _psql_:
```
testdb=# \q
postgres@vmotus07:/home/devops$ exit
```

Редактируем конфигурационный файл PostgreSQL (меняем метод аутентификации для локальных подключений с _peer_ на _md5_), перезагружаем PostgreSQL:
```
devops@vmotus07:~$ sudo nano /etc/postgresql/13/main/pg_hba.conf
devops@vmotus07:~$ sudo systemctl restart postgresql
```

Запускаем _psql_ под пользователем _postgres_:
```
devops@vmotus07:~$ sudo su postgres
postgres@vmotus07:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.
```

Подключаемся к базе данных _testdb_ пользователем _testread_, при запросе пароля вводим пароль, указанный при создании пользователя:
```
postgres=# \c testdb testread
Password for user testread:
You are now connected to database "testdb" as user "testread".
```

Выполняем выборку всех данных из таблицы _t1_:
```
testdb=> select* from t1;
ERROR:  permission denied for table t1
```
И получаем ошибку. 

Проверяем права доступа на таблицу _t1_:
```
testdb=> \z t1
                            Access privileges
 Schema | Name | Type  | Access privileges | Column privileges | Policies
--------+------+-------+-------------------+-------------------+----------
 public | t1   | table |                   |                   |
(1 row)
```
И узнаём, что прав доступа на таблицу _t1_ у пользователя _testread_ нет. А заодно видим и причину данного казуса - таблица была создана в схеме _public_.

Исправляемся. Переподключаемся к базе данных _testdb_ пользователем _postgres_:
```
testdb=> \c testdb postgres
You are now connected to database "testdb" as user "postgres".
```

Удаляем таблицу _t1_, пересоздаём её с явным указанием схемы и заполняем данными:
```
testdb=# drop table t1;
DROP TABLE

testdb=# create table testnm.t1(c1 integer);
CREATE TABLE

testdb=# insert into testnm.t1 values(1);
INSERT 0 1
```

Переподключаемся к базе данных _testdb_ пользователем _testread_ и выполняем выборку всех данных из таблицы _t1_:
```
testdb=# \c testdb testread
Password for user testread:
You are now connected to database "testdb" as user "testread".

testdb=> select * from testnm.t1;
ERROR:  permission denied for table t1
```
И опять получаем ошибку доступа.

Проверяем права: 
```
testdb=> \z testnm.t1
                            Access privileges
 Schema | Name | Type  | Access privileges | Column privileges | Policies
--------+------+-------+-------------------+-------------------+----------
 testnm | t1   | table |                   |                   |
(1 row)
```
Прав у пользователя _testread_ на таблицу _t1_ по-прежнему нет. А всё потому что права назначили на существующие объекты и на новые они не распространяются.

Исправляемся. Переподключаемся к базе данных _testdb_ пользователем _postgres_ и изменяем права по умолчанию на таблицы в схеме _testnm_ для роли _readonly_:
```
testdb=> \c testdb postgres
You are now connected to database "testdb" as user "postgres".
testdb=# alter default privileges in schema testnm grant select on tables to readonly;
ALTER DEFAULT PRIVILEGES
```

Проверяем права на таблицу _t1_:
```
testdb=# \z testnm.t1
                            Access privileges
 Schema | Name | Type  | Access privileges | Column privileges | Policies
--------+------+-------+-------------------+-------------------+----------
 testnm | t1   | table |                   |                   |
(1 row)
```
Прав нет. _default_ распространяется на новые объекты. Повторяем _grand select_ и проверяем права на таблицу _t1_ в очередной раз:
```
testdb=# grant select on all tables in schema testnm to readonly;
GRANT

testdb=# \z testnm.t1
                                Access privileges
 Schema | Name | Type  |     Access privileges     | Column privileges | Policies
--------+------+-------+---------------------------+-------------------+----------
 testnm | t1   | table | postgres=arwdDxt/postgres+|                   |
        |      |       | readonly=r/postgres       |                   |
(1 row)
```

Переподключаемся к базе данных _testdb_ пользователем _testread_ и выполняем выборку всех данных из таблицы _t1_:
```
testdb=# \c testdb testread
Password for user testread:
You are now connected to database "testdb" as user "testread".

testdb=> select * from testnm.t1;
 c1
----
  1
(1 row)
```





<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
