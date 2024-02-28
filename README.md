## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 8 "MVCC, vacuum и autovacuum"

### Домашнее задание
Настройка autovacuum с учетом особеностей производительности

### Исходные данные
ВМ (облако): Ubuntu 22.04 

### Решение

**1.** - Устанавливаем PostgreSQL 15:
```
devops@vmotus08:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-15
```

Подключаемся к _psql_ пользователем _postgres_, создаём базу данных для тестов _otus_ и выходим из _psql_:
```
devops@vmotus08:~$ sudo su postgres

postgres@vmotus08:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database otus;
CREATE DATABASE

postgres=# \q
```






<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
