## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 8 "MVCC, vacuum и autovacuum"

### Домашнее задание
Настройка autovacuum с учетом особеностей производительности

### Исходные данные
ВМ (облако): 2 ядра, 4Гб, SSD 10Гб, Ubuntu 22.04 

### Решение

**1.** - Устанавливаем PostgreSQL 15:
```
devops@vmotus08:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-15
```

Подключаемся пользователем _postgres_, создаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
devops@vmotus08:~$ sudo su postgres

postgres@vmotus08:/home/devops$ pgbench -i postgres
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.07 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 1.21 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 0.87 s, vacuum 0.05 s, primary keys 0.29 s).
```

Запускаем тест:
```
postgres@vmotus08:/home/devops$ pgbench -c8 -P 6 -T 60 -U postgres postgres




```




postgres@vmotus08:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database otus;
CREATE DATABASE

postgres=# \q



<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
