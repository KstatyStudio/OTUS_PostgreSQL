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

```




postgres=# CREATE VIEW accounts_v AS
SELECT '(0,'||lp||')' AS ctid,
       t_xmax as xmax,
       CASE WHEN (t_infomask & 128) > 0   THEN 't' END AS lock_only,
       CASE WHEN (t_infomask & 4096) > 0  THEN 't' END AS is_multi,
       CASE WHEN (t_infomask2 & 8192) > 0 THEN 't' END AS keys_upd,
       CASE WHEN (t_infomask & 16) > 0 THEN 't' END AS keyshr_lock,
       CASE WHEN (t_infomask & 16+64) = 16+64 THEN 't' END AS shr_lock
FROM heap_page_items(get_raw_page('accounts',0))
ORDER BY lp;


postgres=# CREATE VIEW locks_v AS
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






**2. Сессия #2** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
!devops@vmotus08:~$
```

**3. Сессия #3** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
+devops@vmotus08:~$
```





<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
