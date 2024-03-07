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

locks=*# rollback;
ROLLBACK
```

**Сессия #2** - Проверим журнал сообщений:
```diff
!locks=# \q
!devops@vmotus07:~$ sudo tail -n 10 /var/log/postgresql/postgresql-13-main.log | grep duration
!2024-03-06 11:57:34.965 UTC [135902] postgres@locks LOG:  duration: 372.286 ms  statement: insert into accounts (amount) select generate_series (1000, 100999);
!2024-03-06 11:57:42.626 UTC [135902] postgres@locks LOG:  duration: 257.364 ms  statement: create extension pageinspect;
!2024-03-06 12:16:01.976 UTC [135902] postgres@locks LOG:  duration: 596.174 ms  statement: update accounts set amount=amount+10;
```
В журнал стали записываться данные о блокировках и их длительности, например видно, что заполнение данными таблицы _accounts_ вызвало блокировку длительностью 372 миллисекунды, а выборка 3 строк в незавершённой транзакции не вызвала блокировок, превышающих 200 миллисекунд. Подключение расширения "подвисло" на 257 миллисекунд. Обновление всех строк таблицы _account_ вызвало блокировку на 596 миллисекунд.

**3. - Смоделируем ситуацию обновления одной и той же строки тремя командами UPDATE в разных сеансах:**

**Сессия #1** - Начнём новую транзакцию и выполним обновление строки - увеличим сумму на 10,00 на первом счёте (acc_no = 1):
```
locks=# begin;
BEGIN

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

!locks=# select pg_backend_pid();
! pg_backend_pid
!----------------
!         147821
!(1 row)

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

+locks=# select pg_backend_pid();
+ pg_backend_pid
+----------------
+         147916
+(1 row)

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
 relation | RowExclusiveLock | t       | 147821 | {135902}
 relation | RowExclusiveLock | t       | 147916 | {147821}
 relation | RowExclusiveLock | t       | 135902 | {}
 tuple    | ExclusiveLock    | t       | 147821 | {135902}
 tuple    | ExclusiveLock    | f       | 147916 | {147821}
(5 rows)
```
Транзакция в сессии #1 (pid = 135902) выполняется, строка заблокирована в эксклюзивном (исключительном) режиме.

Транзакция в сессии #2 (pid = 147821) ожидает снятия блокировки строки, наложенной процессом в сессии #1 (pid = 135902).

Транзакция в сессии #3 (pid = 147916) ожидает снятия блокировок, наложенных процессом в сессии #2 (pid = 147821).

Обе ожидающие транзакции создали свои версии строк (tuple), при этом блокировка tuple ExclusiveLock в сессии #3 (pid = 147916) не получила разрешения (granted false).

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/36e76dcc-72f3-4038-9b29-a0fb949f5e9f)

Завершим транзакции во всех сессиях.

**3. - Смоделируем взаимоблокировку трех транзакций**:

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/b5e47004-5f38-4014-b173-c50f5aa7fa0c)

**Сессия #1** - Начнём новую транзакцию и выполним обновление строки - уменьшим сумму на 10,00 на первом счёте (**acc_no = 1**):
```
locks=# select pg_backend_pid();
 pg_backend_pid
----------------
         178469
(1 row)

locks=# begin;
BEGIN

locks=*# update accounts set amount=amount-10 where acc_no=1;
UPDATE 1
```

**Сессия #2** - Начнём новую транзакцию и выполним обновление строки - уменьшим сумму на 10,00 на втором счёте (**acc_no = 2**):
```diff
!locks=# select pg_backend_pid();
! pg_backend_pid
!----------------
!         178516
!(1 row)

!locks=# begin;
!BEGIN

!locks=*# update accounts set amount=amount-10 where acc_no=2;
!UPDATE 1
```

**Сессия #3** - Начнём новую транзакцию и выполним обновление строки - уменьшим сумму на 10,00 на третьем счёте (**acc_no = 3**):
```diff
+locks=# select pg_backend_pid();
+ pg_backend_pid
+----------------
+         178563
+(1 row)

+locks=# begin;
+BEGIN

+locks=*# update accounts set amount=amount-10 where acc_no=3;
+UPDATE 1
```

**Сессия #1** - Выполним обновление строки - увеличим сумму на 10,00 на втором счёте (**acc_no = 2**):
```
locks=*# update accounts set amount=amount+10 where acc_no=2;
```
Выполнение операции обновления зависло.

**Сессия #2** - Выполним обновление строки - увеличим сумму на 10,00 на третьем счёте (**acc_no = 3**):
```diff
!locks=*# update accounts set amount=amount+10 where acc_no=3;
```
Выполнение операции обновления зависло.

**Сессия #3** - Выполним обновление строки - увеличим сумму на 10,00 на первом счёте (**acc_no = 1**):
```diff
+locks=*# update accounts set amount=amount+10 where acc_no=1;
```
Выполнение операции обновления вызвало появление deadlock, система выдала ошибку:
```diff
+ERROR:  deadlock detected
+DETAIL:  Process 178563 waits for ShareLock on transaction 657; blocked by process 178469.
+Process 178469 waits for ShareLock on transaction 658; blocked by process 178516.
+Process 178516 waits for ShareLock on transaction 659; blocked by process 178563.
+HINT:  See server log for query details.
+CONTEXT:  while updating tuple (540,102) in relation "accounts"
```

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/a2d98c44-4c5d-4f21-b905-10236679de6b)

Завершаем транзакции во всех сессиях. Смотрим логи.
```
devops@vmotus07:~$ sudo tail -n 20 /var/log/postgresql/postgresql-13-main.log
2024-03-06 14:02:34.196 UTC [178563] postgres@locks ERROR:  deadlock detected
2024-03-06 14:02:34.196 UTC [178563] postgres@locks DETAIL:  Process 178563 waits for ShareLock on transaction 657; blocked by process 178469.
        Process 178469 waits for ShareLock on transaction 658; blocked by process 178516.
        Process 178516 waits for ShareLock on transaction 659; blocked by process 178563.
        Process 178563: update accounts set amount=amount+10 where acc_no=1;
        Process 178469: update accounts set amount=amount+10 where acc_no=2;
        Process 178516: update accounts set amount=amount+10 where acc_no=3;
2024-03-06 14:02:34.196 UTC [178563] postgres@locks HINT:  See server log for query details.
2024-03-06 14:02:34.196 UTC [178563] postgres@locks CONTEXT:  while updating tuple (540,102) in relation "accounts"
2024-03-06 14:02:34.196 UTC [178563] postgres@locks STATEMENT:  update accounts set amount=amount+10 where acc_no=1;
2024-03-06 14:02:34.197 UTC [178516] postgres@locks LOG:  duration: 36590.025 ms  statement: update accounts set amount=amount+10 where acc_no=3;
2024-03-06 14:08:52.279 UTC [178469] postgres@locks LOG:  duration: 538617.624 ms  statement: update accounts set amount=amount+10 where acc_no=2;
```
В журнале сообщений записана информация о появлении deadlock. Видно какие процессы участвовали в его формировании - 178469, 178516, 178563, а так же содержание операций (update).

**4. - Смоделируем взаимоблокировку двух транзакций, выполняющих update всей таблицы**:

**Сессия #1** - Начнём новую транзакцию и выполним обновление всех строк - увеличим сумму на 10,00:
```
locks=# select pg_backend_pid();
 pg_backend_pid
----------------
         190525
(1 row)

locks=# begin;
BEGIN
locks=*# update accounts set amount=amount+10;
UPDATE 100000
```

**Сессия #2** - Начнём новую транзакцию и тоже выполним обновление всех строк - увеличим сумму на 10,00:
```diff
!locks=# select pg_backend_pid();
! pg_backend_pid
!----------------
!         190686
!(1 row)
!
!locks=# begin;
!BEGIN
!locks=*# update accounts set amount=amount+10;
```
Транзакция зависла.

**Сессия #1** - Смотрим блокировки:
```
locks=*# select locktype, mode, granted, pid, pg_blocking_pids(pid) as wait_for from pg_locks where relation='accounts'::regclass;
 locktype |       mode       | granted |  pid   | wait_for
----------+------------------+---------+--------+----------
 relation | RowExclusiveLock | t       | 190525 | {}
 relation | RowExclusiveLock | t       | 190686 | {190525}
 tuple    | ExclusiveLock    | t       | 190686 | {190525}
(3 rows)
```
Транзакция в сессии #1 (pid = 190525) выполняется, эксклюзивная блокировка устанавливается на строки, данный режим позволяет выполнять другие RowExclusiveLock.

Транзакция в сессии #2 (pid = 190686) попыталась обновить уже заблокированную транзакцией #1 строку и ожидает снятия блокировки.

Взаимоблокировка в данном случае не произошла. Но если бы транзакция #2 начала обновлять строки в другом порядке, то произошла бы взаимоблокировка. 

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
