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

# ПРОВЕРИТЬ
# ПРЕДСТАВЛЕНИЯ
#
#
#
#


Создаём представление _accounts_v_ для просмотра информации о блокировках таблицы _accounts_:
```
locks=# create view accounts_v as
select '(0,'||lp||')' as ctid,
       t_xmax as xmax,
       case when (t_infomask & 128) > 0 then 't' end as lock_only,
       case when (t_infomask & 4096) > 0 then 't' end as is_multi,
       case when (t_infomask2 & 8192) > 0 then 't' end as keys_upd,
       case when (t_infomask & 16) > 0 then 't' end as keyshr_lock,
       case when (t_infomask & 16+64) = 16+64 then 't' end as shr_lock
from heap_page_items(get_raw_page('accounts',0))
order by lp;
```

Создаём представление _locks_v_ для просмотра информации о блокировках строк:
```
locks=# create view locks_v AS
select pid,
       locktype,
       case locktype
         when 'relation' then relation::regclass::text
         when 'transactionid' then transactionid::text
         when 'tuple' then relation::regclass::text||':'||tuple::text
       end as lockid,
       mode,
       granted
from pg_locks
where locktype in ('relation','transactionid','tuple')
and (locktype != 'relation' or relation = 'accounts'::regclass);
```

**2. - Смоделируем длительные блокировки**:

**Сессия #1** - Определяем номер процесса:
```
locks=*# select pg_backend_pid();
 pg_backend_pid
----------------
          135902
(1 row)
```

Начнём транзакцию и выполним запрос к таблице _accounts_, а так же обновим все строки:
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

locks=*# update accounts set amount=amount+10;
UPDATE 100000
```

**Сессия #2** - Проверим журнал сообщений:
```diff
!devops@vmotus07:~$ sudo tail -n 10 /var/log/postgresql/postgresql-13-main.log | grep duration
!2024-03-06 11:57:34.965 UTC [135902] postgres@locks LOG:  duration: 372.286 ms  statement: insert into accounts (amount) select generate_series (1000, 100999);
!2024-03-06 11:57:42.626 UTC [135902] postgres@locks LOG:  duration: 257.364 ms  statement: create extension pageinspect;
!2024-03-06 12:16:01.976 UTC [135902] postgres@locks LOG:  duration: 596.174 ms  statement: update accounts set amount=amount+10;
```
В журнал стали записываться данные о блокировках и их длительности, например видно, что заполнение данными таблицы _accounts_ вызвало блокировку длительностью 372 миллисекунды, а выборка 3 строк в незавершённой транзакции не вызвала блокировок, превышающих 200 миллисекунд. Подключение расширения "подвисло" на 257 миллисекунд. Обновление всех строк таблицы _account_ вызвало блокировку на 596 миллисекунд.

**3. - Смоделируем ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах:**

**Сессия #1** - в ранее начатой транзакции выполним обновление строки - увеличим сумму на 10,00 на первом счёте (acc_no = 1):
```
locks=*# update accounts set amount=amount+10 where acc_no=1;
UPDATE 1
```

**Сессия #2** - начнём новую транзакцию и выполним обновление той же строки - увеличим сумму на 20,00 на первом счёте (acc_no = 1):
```diff
!devops@vmotus07:~$ sudo -u postgres psql
!psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
!Type "help" for help.

!postgres=# \c locks
!You are now connected to database "locks" as user "postgres".

!locks=# begin;
!BEGIN

!locks=*# update accounts set amount=amount+20 where acc_no=1;
```
Выполнение операции обновления зависло.

**Сессия #3** - так же начнём новую транзакцию и выполним обновление той же строки - увеличим сумму на 30,00 на первом счёте (acc_no = 1):
```diff
+devops@vmotus07:~$ sudo -u postgres psql
+psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
+Type "help" for help.

+postgres=# \c locks
+You are now connected to database "locks" as user "postgres".

+locks=# begin;
+BEGIN

+locks=*# update accounts set amount=amount+30 where acc_no=1;
```
Выполнение операции обновления так же зависло.

**Сессия #1** - Посмотрим информацию о действующих блокировках для таблицы _accounts_:
```
locks=*# select locktype, mode, granted, pid, pg_blocking_pids(pid) as wait_for from pg_locks where relation='accounts'::regclass;
 locktype |       mode       | granted |  pid   | wait_for
----------+------------------+---------+--------+----------
 relation | RowExclusiveLock | t       | 115932 | {110821}
 relation | AccessShareLock  | t       |  89117 | {}
 relation | RowExclusiveLock | t       |  89117 | {}
 relation | RowExclusiveLock | t       | 110821 | {89117}
 tuple    | ExclusiveLock    | t       | 110821 | {89117}
 tuple    | ExclusiveLock    | f       | 115932 | {110821}
(6 rows)
```
Транзакция в сессии #1 (pid = 89117) выполняется, таблица заблокирована в разделяемом режиме, строка - в исключительном.
Транзакция в сессии #2 (pid = ) ожидает снятия блокировок таблицы и строки, наложенных процессом в сессии #1 (pid = ).
Транзакция в сессии #3 (pid = ) ожидает снятия блокировок, наложенных процессом в сессии #2 (pid = ).

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/45f49b19-96a6-4ed0-961e-9024381c71a3)

**2. Сессия #2** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
!devops@vmotus08:~$
```

**3. Сессия #3** - Создаём базу данных _locks_, таблицу _test_, заполняем тестовыми данными:
```diff
+devops@vmotus08:~$
```






<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
