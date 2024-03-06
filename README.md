## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 10 "Блокировки"

### Домашнее задание
Механизм блокировок

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 13

SSH-сессии: 3 подключения

### Решение

**1. Сессия #1** - Проверяем настройки сервера PostgreSQL:
```
devops@vmotus07:~$ sudo -u postgres psql
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.

postgres=# show log_min_duration_statement;
 log_min_duration_statement
----------------------------
 -1
(1 row)
```
Логирование длительных блокировок отключено.

Изменяем параметр _log_min_duration_statement_ для отображения в журнале сообщений информации о блокировках, удерживаемых более 200 миллисекунд:
```
postgres=# alter system set log_min_duration_statement=200;
ALTER SYSTEM
```

Перечитываем конфигурацию для применения изменений без перезагрузки сервиса PostgreSQL.
```
postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
```

Создаём базу данных _locks_, таблицу _accounts_, заполняем тестовыми данными:
```
postgres=# create database locks;
CREATE DATABASE

postgres=# \c locks
You are now connected to database "locks" as user "postgres".

locks=# create table accounts (acc_no serial primary key, amount numeric);
CREATE TABLE

locks=# insert into accounts (amount) select generate_series (1000, 100999);
INSERT 0 100000
```

Подключаем расширения _pageinspect_ и _pgrowlocks_:
```
locks=# create extension pageinspect;
CREATE EXTENSION

locks=# create extension pgrowlocks;
CREATE EXTENSION
```

Создаём представление _accounts_v_ для просмотра информации о блокировках таблицы _accounts_:
```
locks=# CREATE VIEW accounts_v AS
SELECT '(0,'||lp||')' AS ctid,
       t_xmax as xmax,
       CASE WHEN (t_infomask & 128) > 0   THEN 't' END AS lock_only,
       CASE WHEN (t_infomask & 4096) > 0  THEN 't' END AS is_multi,
       CASE WHEN (t_infomask2 & 8192) > 0 THEN 't' END AS keys_upd,
       CASE WHEN (t_infomask & 16) > 0 THEN 't' END AS keyshr_lock,
       CASE WHEN (t_infomask & 16+64) = 16+64 THEN 't' END AS shr_lock
FROM heap_page_items(get_raw_page('accounts',0))
ORDER BY lp;
```

Создаём представление __ для просмотра информации о блокировках строк:
```
locks=# CREATE VIEW locks_v AS
SELECT pid,
       locktype,
       CASE locktype
         WHEN 'relation' THEN relation::regclass::text
         WHEN 'transactionid' THEN transactionid::text
         WHEN 'tuple' THEN relation::regclass::text||':'||tuple::text
       END AS lockid,
       mode,
       granted
FROM pg_locks
WHERE locktype in ('relation','transactionid','tuple')
AND (locktype != 'relation' OR relation = 'accounts'::regclass);
```

**2.** - Смоделируем длительные блокировки:

**Сессия #1** - Определяем номер процесса:
```
locks=*# select pg_backend_pid();
 pg_backend_pid
----------------
          89117
(1 row)
```

Начнём транзакцию и заблокируем таблицу _accounts_:
```
locks=# begin;
BEGIN

locks=*# select* from accounts limit 3;
 acc_no | amount
--------+--------
      1 |   1000
      2 |   1001
      3 |   1002
(3 rows)
```

Посмотрим информацию о действующих на данный момент блокировках:
```
locks=*# select locktype, relation::regclass, virtualxid as vxid, transactionid as xid, mode, granted from pg_locks where pid=89117;
  locktype  |   relation    | vxid  | xid |      mode       | granted
------------+---------------+-------+-----+-----------------+---------
 relation   | pg_locks      |       |     | AccessShareLock | t
 relation   | accounts_pkey |       |     | AccessShareLock | t
 relation   | accounts      |       |     | AccessShareLock | t
 virtualxid |               | 4/227 |     | ExclusiveLock   | t
(4 rows)
```

**Сессия #2** - Проверим журнал сообщений:
```diff
!devops@vmotus07:~$ sudo tail -n 10 /var/log/postgresql/postgresql-13-main.log | grep duration
!2024-03-06 09:49:34.006 UTC [89117] postgres@locks LOG:  duration: 678.218 ms  statement: create table accounts (acc_no serial primary key, amount numeric);
!2024-03-06 09:49:45.833 UTC [89117] postgres@locks LOG:  duration: 488.683 ms  statement: insert into accounts (amount) select generate_series (1000, 100999);
```
В журнал стали записываться данные о блокировках и их длительности, например видно, что создание таблицы _accounts_ вызвало блокировку длительностью 678,218 миллисекунд.





**2. Сессия #2** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
!devops@vmotus08:~$
```

**3. Сессия #3** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
+devops@vmotus08:~$
```






<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
