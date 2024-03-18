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

Изменяем параметр _wal_level_ - переключаемся на логическую репликацию, меняем стандартный пароль пользователя _postgres_, презагружаем кластер _main_ для применения изменений:
```
postgres=# alter system set wal_level='logical';
ALTER SYSTEM

postgres=# \password
Enter new password for user "postgres":
Enter it again:
postgres=# \q
postgres@vmotus1:/home/devops$ exit

devops@vmotus1:~$ sudo pg_ctlcluster 14 main restart
```

Cоздаем базу данных _repldb_, таблицы _test_ для записи, _test2_ для запросов на чтение:
```
devops@vmotus1:~$ sudo su postgres
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database repldb;
CREATE DATABASE

postgres=# \c repldb;
You are now connected to database "repldb" as user "postgres".

repldb=# create table test (id serial primary key, str char(10));
CREATE TABLE

repldb=# create table test2 (id serial primary key, str char(10));
CREATE TABLE

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 0 bytes    |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes    |
(2 rows)
repldb=# \q
```

**2. Сессия#2** - Создаём второй кластер PostgreSQL 14 _main2_:
```diff
!devops@vmotus1:~$ sudo su postgres
!postgres@vmotus1:/home/devops$ pg_createcluster -d /var/lib/postgresql/14/main2 14 main2
!Creating new PostgreSQL cluster 14/main2 ...
!/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main2 --auth-local peer --auth-host scram-sha-256 --no-instructions
!The files belonging to this database system will be owned by user "postgres".
!This user must also own the server process.

!The database cluster will be initialized with locale "en_US.UTF-8".
!The default database encoding has accordingly been set to "UTF8".
!The default text search configuration will be set to "english".

!Data page checksums are disabled.

!fixing permissions on existing directory /var/lib/postgresql/14/main2 ... ok
!creating subdirectories ... ok
!selecting dynamic shared memory implementation ... posix
!selecting default max_connections ... 100
!selecting default shared_buffers ... 128MB
!selecting default time zone ... Etc/UTC
!creating configuration files ... ok
!running bootstrap script ... ok
!performing post-bootstrap initialization ... ok
!syncing data to disk ... ok
!Warning: systemd does not know about the new cluster yet. Operations like "service postgresql start" will not handle it. To fix, run:
!  sudo systemctl daemon-reload
!Ver Cluster Port Status Owner    Data directory               Log file
!14  main2   5433 down   postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```
Кластеру _main2_ назначен порт 5433.

Удаляем каталог кластера _main2_:
```diff
!postgres@vmotus1:/home/devops$ rm -rf /var/lib/postgresql/14/main2

!postgres@vmotus1:/home/devops$ pg_lsclusters
!Ver Cluster Port Status Owner     Data directory               Log file
!14  main    5432 online postgres  /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
!14  main2   5433 down   <unknown> /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

**3. Сессия#1** - Создаём бэкап кластера _main_ в каталоге кластера _main2_:
```
postgres@vmotus1:/home/devops$ pg_basebackup -p 5432 -D /var/lib/postgresql/14/main2

postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory               Log file
14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
14  main2   5433 down   postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

**4. Сессия#2** - Запускаем кластер _main2_ (порт 5433):
```diff
!postgres@vmotus1:/home/devops$ pg_ctlcluster 14 main2 start
!postgres@vmotus1:/home/devops$ pg_lsclusters
!Ver Cluster Port Status Owner    Data directory               Log file
!14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
!14  main2   5433 online postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
```

Подключаемся к базе данных _repldb_ в кластере _main2_ (порт 5433), заполняем данными таблицу _test2_, создаём публикацию таблицы _test2_:
```diff
!postgres@vmotus1:/home/devops$ psql -p 5433
!psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
!Type "help" for help.

!postgres=# \c repldb
!You are now connected to database "repldb" as user "postgres".

!repldb=# \conninfo
!You are connected to database "repldb" as user "postgres" via socket in "/var/run/postgresql" at port "5433".

!repldb=# \dt+
!                                    List of relations
! Schema | Name  | Type  |  Owner   | Persistence | Access method |  Size   | Description
!--------+-------+-------+----------+-------------+---------------+---------+-------------
! public | test  | table | postgres | permanent   | heap          | 0 bytes |
! public | test2 | table | postgres | permanent   | heap          | 0 bytes |
!(2 rows)

!repldb=# insert into test2 (str) select md5(random()::text)::char(10) from generate_series(1, 4);
!INSERT 0 4

!repldb=# select* from test2;
! id |    str
!----+------------
!  1 | 1e36afe32a
!  2 | 33dfb0bd19
!  3 | bcda117e62
!  4 | 99edca1679
!(4 rows)

!repldb=# \dt+
!                                     List of relations
! Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
!--------+-------+-------+----------+-------------+---------------+------------+-------------
! public | test  | table | postgres | permanent   | heap          | 0 bytes    |
! public | test2 | table | postgres | permanent   | heap          | 8192 bytes |
!(2 rows)

!repldb=# create publication test2_pub for table test2;
!CREATE PUBLICATION

!repldb=# \dRp+
!                           Publication test2_pub
!  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
!----------+------------+---------+---------+---------+-----------+----------
! postgres | f          | t       | t       | t       | t         | f
!Tables:
!    "public.test2"
```

**5. Сессия#1** - Заполняем таблицу _test_ в кластере _main_:
```
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c repldb
You are now connected to database "repldb" as user "postgres".

repldb=# \conninfo
You are connected to database "repldb" as user "postgres" via socket in "/var/run/postgresql" at port "5432".

repldb=# insert into test (str) select md5(random()::text)::char(10) from generate_series(1, 3);
INSERT 0 3

repldb=# select* from test;
 id |    str
----+------------
  1 | cec8aeabe2
  2 | 951236d920
  3 | 09124a3798
(3 rows)

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 8192 bytes |
 public | test2 | table | postgres | permanent   | heap          | 0 bytes    |
(2 rows)
```

Cоздаём публикацию таблицы _test_:
```
repldb=# create publication test_pub for table test;
CREATE PUBLICATION

repldb=# \dRp+
                            Publication test_pub
  Owner   | All tables | Inserts | Updates | Deletes | Truncates | Via root
----------+------------+---------+---------+---------+-----------+----------
 postgres | f          | t       | t       | t       | t         | f
Tables:
    "public.test"
```

Создаём подписку на таблицу _test2_ из кластера _main2_ с опцией копирования существующих данных:
```
repldb=# create subscription test2_sub connection 'host=localhost port=5433 user=postgres password=****** dbname=repldb' publication test2_pub with (copy_data=true);
NOTICE:  created replication slot "test2_sub" on publisher
CREATE SUBSCRIPTION

repldb=# \dRs
            List of subscriptions
   Name    |  Owner   | Enabled | Publication
-----------+----------+---------+-------------
 test2_sub | postgres | t       | {test2_pub}
(1 row)

repldb=# select* from test2;
 id |    str
----+------------
  1 | 1e36afe32a
  2 | 33dfb0bd19
  3 | bcda117e62
  4 | 99edca1679
(4 rows)

repldb=# \dt+
                                     List of relations
 Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
--------+-------+-------+----------+-------------+---------------+------------+-------------
 public | test  | table | postgres | permanent   | heap          | 8192 bytes |
 public | test2 | table | postgres | permanent   | heap          | 8192 bytes |
(2 rows)
```
Данные из таблицы _test2_ кластера _main2_ были реплицированы на кластер _main_.

**6. Сессия#2** - Создаём подписку на таблицу _test_ из кластера _main_ с опцией копирования существующих данных:
```diff
!repldb=# create subscription test_sub connection 'host=localhost port=5432 user=postgres password=****** dbname=repldb' publication test_pub with (copy_data=true);
!NOTICE:  created replication slot "test_sub" on publisher
!CREATE SUBSCRIPTION

!repldb=# select* from test;
! id |    str
!----+------------
!  1 | cec8aeabe2
!  2 | 951236d920
!  3 | 09124a3798
!(3 rows)

!repldb=# \dt+
!                                     List of relations
! Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
!--------+-------+-------+----------+-------------+---------------+------------+-------------
! public | test  | table | postgres | permanent   | heap          | 8192 bytes |
! public | test2 | table | postgres | permanent   | heap          | 8192 bytes |
!(2 rows)
```
Данные из таблицы _test_ кластера _main_ были реплицированы на кластер _main2_.

Вносим изменения в таблицу _test2_:
```diff
!repldb=# update test2 set str='second' where id=2;
!UPDATE 1
!repldb=# select* from test2;
! id |    str
!----+------------
!  1 | 1e36afe32a
!  3 | bcda117e62
!  4 | 99edca1679
!  2 | second
!(4 rows)
```

**7. Сессия#1** - Проверяем изменения в таблице _test2_:
```
repldb=# select* from test2;
 id |    str
----+------------
  1 | 1e36afe32a
  3 | bcda117e62
  4 | 99edca1679
  2 | second
(4 rows)

repldb=# \q
```
Изменение данных в таблице _test2_ кластера _main2_ так же были реплицированы на кластер _main_.

**8. Сессия#3** - Создаём третий кластер PostgreSQL 14 _main3_:
```diff
+devops@vmotus1:~$ sudo su postgres

+postgres@vmotus1:/home/devops$ pg_createcluster -d /var/lib/postgresql/14/main3 14 main3

+Creating new PostgreSQL cluster 14/main3 ...
+/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main3 --auth-local peer --auth-host scram-sha-256 --no-instructions
+The files belonging to this database system will be owned by user "postgres".
+This user must also own the server process.

+The database cluster will be initialized with locale "en_US.UTF-8".
+The default database encoding has accordingly been set to "UTF8".
+The default text search configuration will be set to "english".

+Data page checksums are disabled.

+fixing permissions on existing directory /var/lib/postgresql/14/main3 ... ok
+creating subdirectories ... ok
+selecting dynamic shared memory implementation ... posix
+selecting default max_connections ... 100
+selecting default shared_buffers ... 128MB
+selecting default time zone ... Etc/UTC
+creating configuration files ... ok
+running bootstrap script ... ok
+performing post-bootstrap initialization ... ok
+syncing data to disk ... ok
+Warning: systemd does not know about the new cluster yet. Operations like "service postgresql start" will not handle it. To fix, run:
+  sudo systemctl daemon-reload
+Ver Cluster Port Status Owner    Data directory               Log file
+14  main3   5434 down   postgres /var/lib/postgresql/14/main3 /var/log/postgresql/postgresql-14-main3.log
```
Кластеру _main3_ назначен порт 5434.

Удаляем каталог кластера _main3_:
```diff
+postgres@vmotus1:/home/devops$ rm -rf /var/lib/postgresql/14/main3
```

**9. Сессия#1** - Создаём бэкап кластера _main_ в каталоге кластера _main3_:
```
postgres@vmotus1:/home/devops$ pg_basebackup -p 5432 -D /var/lib/postgresql/14/main3

postgres@vmotus1:/home/devops$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory               Log file
14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
14  main2   5433 online postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
14  main3   5434 down   postgres /var/lib/postgresql/14/main3 /var/log/postgresql/postgresql-14-main3.log
```

**10. Сессия#3** - Запускаем кластер _main3_ (порт 5434):
```diff
+postgres@vmotus1:/home/devops$ pg_ctlcluster 14 main3 start

+postgres@vmotus1:/home/devops$ pg_lsclusters
+Ver Cluster Port Status Owner    Data directory               Log file
+14  main    5432 online postgres /var/lib/postgresql/14/main  /var/log/postgresql/postgresql-14-main.log
+14  main2   5433 online postgres /var/lib/postgresql/14/main2 /var/log/postgresql/postgresql-14-main2.log
+14  main3   5434 online postgres /var/lib/postgresql/14/main3 /var/log/postgresql/postgresql-14-main3.log
```

Подключаемся к базе данных _repldb_ и проверяем данные, загруженные при копировании кластера:
```diff
+postgres@vmotus1:/home/devops$ psql -p 5434
+psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
+Type "help" for help.

+postgres=# \c repldb
+You are now connected to database "repldb" as user "postgres".

+repldb=# \conninfo
+You are connected to database "repldb" as user "postgres" via socket in "/var/run/postgresql" at port "5434".

+repldb=# \dt+
+                                     List of relations
+ Schema | Name  | Type  |  Owner   | Persistence | Access method |    Size    | Description
+--------+-------+-------+----------+-------------+---------------+------------+-------------
+ public | test  | table | postgres | permanent   | heap          | 8192 bytes |
+ public | test2 | table | postgres | permanent   | heap          | 8192 bytes |
+(2 rows)

+repldb=# select* from test;
+ id |    str
+----+------------
+  1 | cec8aeabe2
+  2 | 951236d920
+  3 | 09124a3798
+(3 rows)

+repldb=# select* from test2;
+ id |    str
+----+------------
+  1 | 1e36afe32a
+  3 | bcda117e62
+  4 | 99edca1679
+  2 | second
+(4 rows)
```

Создаём подписки на таблицу _test_ из кластера _main_ и таблицу _test2_ из кластера _main2_ без опции копирования существующих данных:
```diff
+repldb=# create subscription test_sub_3 connection 'host=localhost port=5432 user=postgres password=****** dbname=repldb' publication test_pub with (copy_data=false);
+NOTICE:  created replication slot "test_sub_3" on publisher
+CREATE SUBSCRIPTION

+repldb=# create subscription test2_sub_3 connection 'host=localhost port=5433 user=postgres password=****** dbname=repldb' publication test2_pub with (copy_data=false);
+NOTICE:  created replication slot "test2_sub_3" on publisher
+CREATE SUBSCRIPTION

+repldb=# \dRs
+             List of subscriptions
+    Name     |  Owner   | Enabled | Publication
+-------------+----------+---------+-------------
+ test2_sub   | postgres | t       | {test2_pub}
+ test2_sub_3 | postgres | t       | {test2_pub}
+ test_sub_3  | postgres | t       | {test_pub}
+(3 rows)
```

При копировании кластера была скопирована и подписка _test2_sub_, удалим её, чтобы избежать двойной репликации.
```diff
+repldb=# alter subscription test2_sub disable;
+ALTER SUBSCRIPTION

+repldb=# alter subscription test2_sub set (slot_name = NONE);
+ALTER SUBSCRIPTION

+repldb=# drop subscription test2_sub;
+DROP SUBSCRIPTION

+repldb=# \dRs+
+    Name     |  Owner   | Enabled | Publication | Binary | Streaming | Synchronous commit |                               Conninfo
+-------------+----------+---------+-------------+--------+-----------+--------------------+----------------------------------------------------------------------
+ test2_sub_3 | postgres | t       | {test2_pub} | f      | f         | off                | host=localhost port=5433 user=postgres password=****** dbname=repldb
+ test_sub_3  | postgres | t       | {test_pub}  | f      | f         | off                | host=localhost port=5432 user=postgres password=****** dbname=repldb
+(2 rows)
```
В базе данных _repldb_ кластера _main3_ остались две подписки. 

**11. Сессия#1** - Вносим изменения в таблицу _test_ на кластере _main_ и проверяем репликацию изменений на кластерах _main2_ и _main3_:
```
postgres@vmotus1:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c repldb
You are now connected to database "repldb" as user "postgres".

repldb=# update test set str='first' where id=1;
UPDATE 1

repldb=# insert into test(str) values (md5(random()::text)::char(10));
INSERT 0 1
repldb=# select* from test;
 id |    str
----+------------
  2 | 951236d920
  3 | 09124a3798
  4 | dc7d406807
  1 | first
(4 rows)
```

**Сессия#2**
```diff
!repldb=# select* from test;
! id |    str
!----+------------
!  2 | 951236d920
!  3 | 09124a3798
!  4 | dc7d406807
!  1 | first
!(4 rows)
```

**Сессия#3**
```diff
+repldb=# select* from test;
+ id |    str
+----+------------
+  2 | 951236d920
+  3 | 09124a3798
+  4 | dc7d406807
+  1 | first
+(4 rows)
```
Данные реплицированы на все подписанные кластеры.

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
