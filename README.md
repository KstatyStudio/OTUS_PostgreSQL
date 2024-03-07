## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 9 "Журналы"

### Домашнее задание
Работа с журналами

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 13

### Решение

**1.** - Проверяем настройки сервера PostgreSQL:
```
devops@vmotus07:~$ sudo -u postgres psql
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.

postgres=# select setting, unit from pg_settings where name='checkpoint_timeout';
 setting | unit
---------+------
 300     | s
(1 row)
```

Изменяем период выполнения контрольных точек:
```
postgres=# alter system set checkpoint_timeout=30;
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)

postgres=# select setting, unit from pg_settings where name='checkpoint_timeout';
 setting | unit
---------+------
 30      | s
(1 row)

postgres=# \q
```

**2.** - Выполняем нагрузочное тестирование:

Cоздаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
devops@vmotus07:~$ sudo su postgres

postgres@vmotus07:/home/devops$ pgbench -i postgres
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.15 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 0.78 s (drop tables 0.00 s, create tables 0.01 s, client-side generate 0.17 s, vacuum 0.16 s, primary keys 0.44 s).
```

Запускаем тест на 10 минут:
```
postgres@vmotus07:/home/devops$ pgbench -c8 -P 6 -T 600 -U postgres postgres




```




<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
