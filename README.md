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

pgbench (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 756.3 tps, lat 10.515 ms stddev 6.694, 0 failed
progress: 12.0 s, 743.2 tps, lat 10.792 ms stddev 7.226, 0 failed
progress: 18.0 s, 534.3 tps, lat 14.970 ms stddev 15.594, 0 failed
progress: 24.0 s, 823.5 tps, lat 9.713 ms stddev 6.547, 0 failed
progress: 30.0 s, 746.8 tps, lat 10.713 ms stddev 7.575, 0 failed
progress: 36.0 s, 773.0 tps, lat 10.341 ms stddev 6.506, 0 failed
progress: 42.0 s, 654.7 tps, lat 12.222 ms stddev 36.235, 0 failed
progress: 48.0 s, 567.0 tps, lat 14.112 ms stddev 15.984, 0 failed
progress: 54.0 s, 803.5 tps, lat 9.953 ms stddev 6.582, 0 failed
progress: 60.0 s, 810.5 tps, lat 9.871 ms stddev 6.853, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 43285
number of failed transactions: 0 (0.000%)
latency average = 11.088 ms
latency stddev = 13.979 ms
initial connection time = 14.789 ms
tps = 721.342332 (without initial connection time)
```

Редактируем конфигурацию PostgreSQL - применяем рекомендованные по условиям домашнего задания параметры:

<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Параметр</th><th>По умолчанию</th><th>Рекомендовано</th></tr>
	</thead>
	<tbody>
		<tr><td>max_connections</td><td>100</td><td>40</td></tr>
		<tr><td>shared_buffers</td><td>128MB</td><td>1GB</td></tr>
		<tr><td>effective_cache_size</td><td>4GB</td><td>3GB</td></tr>
		<tr><td>maintenance_work_mem</td><td>64MB</td><td>512MB</td></tr>
		<tr><td>checkpoint_completion_target</td><td>0.9</td><td>0.9</td></tr>
		<tr><td>wal_buffers</td><td>-1</td><td>16MB</td></tr>
		<tr><td>default_statistics_target</td><td>100</td><td>500</td></tr>
		<tr><td>random_page_cost</td><td>4.0</td><td>4</td></tr>
		<tr><td>effective_io_concurrency</td><td>1</td><td>2</td></tr>
		<tr><td>work_mem</td><td>4MB</td><td>6553kB</td></tr>
		<tr><td>min_wal_size</td><td>80MB</td><td>4GB</td></tr>
		<tr><td>max_wal_size</td><td>1GB</td><td>16GB</td></tr>
	</tbody>
</table>

```
postgres@vmotus08:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
Type "help" for help.

postgres=# alter system set max_connections=40;
ALTER SYSTEM

postgres=# alter system set shared_buffers='1GB';
ALTER SYSTEM

postgres=# alter system set effective_cache_size='3GB';
ALTER SYSTEM

postgres=# alter system set maintenance_work_mem='512MB';
ALTER SYSTEM

postgres=# alter system set checkpoint_completion_target='0.9';
ALTER SYSTEM

postgres=# alter system set wal_buffers='16MB';
ALTER SYSTEM

postgres=# alter system set default_statistics_target=500;
ALTER SYSTEM

postgres=# alter system set random_page_cost=4;
ALTER SYSTEM

postgres=# alter system set effective_io_concurrency=2;
ALTER SYSTEM

postgres=# alter system set work_mem='6553kB';
ALTER SYSTEM

postgres=# alter system set min_wal_size='4GB';
ALTER SYSTEM

postgres=# alter system set max_wal_size='16GB';
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)

postgres=# \q
```

Запускаем тест ещё раз:
```
postgres@vmotus08:/home/devops$ pgbench -c8 -P 6 -T 60 -U postgres postgres
pgbench (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 756.8 tps, lat 10.533 ms stddev 6.895, 0 failed
progress: 12.0 s, 791.5 tps, lat 10.104 ms stddev 6.662, 0 failed
progress: 18.0 s, 701.7 tps, lat 11.356 ms stddev 8.562, 0 failed
progress: 24.0 s, 660.0 tps, lat 12.174 ms stddev 12.210, 0 failed
progress: 30.0 s, 808.7 tps, lat 9.891 ms stddev 6.562, 0 failed
progress: 36.0 s, 784.3 tps, lat 10.196 ms stddev 7.146, 0 failed
progress: 42.0 s, 759.0 tps, lat 10.529 ms stddev 6.832, 0 failed
progress: 48.0 s, 736.3 tps, lat 10.840 ms stddev 8.025, 0 failed
progress: 54.0 s, 542.7 tps, lat 14.791 ms stddev 14.649, 0 failed
progress: 60.0 s, 840.0 tps, lat 9.525 ms stddev 6.292, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 44294
number of failed transactions: 0 (0.000%)
latency average = 10.835 ms
latency stddev = 8.563 ms
initial connection time = 15.197 ms
tps = 738.186520 (without initial connection time)
```

Проверим и при необходимости изменим рекомендованные параметры в конфигурационном файле, перезапустим сервис PistgreSQL:
```
postgres@vmotus08:/home/devops$ nano /etc/postgresql/15/main/postgresql.conf

postgres@vmotus08:/home/devops$ exit

devops@vmotus08:~$ sudo systemctl restart postgresql
```

Запускаем тест:
```
devops@vmotus08:~$ sudo su postgres

postgres@vmotus08:/home/devops$ pgbench -c8 -P 6 -T 60 -U postgres postgres
pgbench (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 754.8 tps, lat 10.548 ms stddev 6.889, 0 failed
progress: 12.0 s, 797.7 tps, lat 10.039 ms stddev 5.601, 0 failed
progress: 18.0 s, 771.7 tps, lat 10.368 ms stddev 6.209, 0 failed
progress: 24.0 s, 560.2 tps, lat 14.281 ms stddev 13.754, 0 failed
progress: 30.0 s, 854.5 tps, lat 9.360 ms stddev 5.840, 0 failed
progress: 36.0 s, 764.3 tps, lat 10.463 ms stddev 7.056, 0 failed
progress: 42.0 s, 721.8 tps, lat 11.071 ms stddev 6.778, 0 failed
progress: 48.0 s, 693.3 tps, lat 11.552 ms stddev 8.234, 0 failed
progress: 54.0 s, 536.5 tps, lat 14.915 ms stddev 14.991, 0 failed
progress: 60.0 s, 866.5 tps, lat 9.230 ms stddev 5.487, 0 failed
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 43936
number of failed transactions: 0 (0.000%)
latency average = 10.923 ms
latency stddev = 8.358 ms
initial connection time = 15.585 ms
tps = 732.214936 (without initial connection time)
```

Сравниваем результаты трёх тестов:

<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Параметры по умолчанию</th><th>Рекомендованные параметры</th><th>Рекомендованные параметры
(после перезагрузки сервиса PostgreSQL)</th></tr>
	</thead>
	<tbody>
		<tr><td>scaling factor: 1</td><td>scaling factor: 1</td><td>scaling factor: 1</td></tr>
		<tr><td>query mode: simple</td><td>query mode: simple</td><td>query mode: simple</td></tr>
		<tr><td>number of clients: 8</td><td>number of clients: 8</td><td>number of clients: 8</td></tr>
		<tr><td>number of threads: 1</td><td>number of threads: 1</td><td>number of threads: 1</td></tr>
		<tr><td>maximum number of tries: 1</td><td>maximum number of tries: 1</td><td>maximum number of tries: 1</td></tr>
		<tr><td>duration: 60 s</td><td>duration: 60 s</td><td>duration: 60 s</td></tr>
		<tr><td>number of transactions actually processed: 43285</td><td>number of transactions actually processed: 44294</td><td>number of transactions actually processed: 43936</td></tr>
		<tr><td>number of failed transactions: 0 (0.000%)</td><td>number of failed transactions: 0 (0.000%)</td><td>number of failed transactions: 0 (0.000%)</td></tr>
		<tr><td>latency average = 11.088 ms</td><td>latency average = 10.835 ms</td><td>latency average = 10.923 ms</td></tr>
		<tr><td>latency stddev = 13.979 ms</td><td>latency stddev = 8.563 ms</td><td>latency stddev = 8.358 ms</td></tr>
		<tr><td>initial connection time = 14.789 ms</td><td>initial connection time = 15.197 ms</td><td>initial connection time = 15.585 ms</td></tr>
		<tr><td>tps = 721.342332 (without initial connection time)</td><td>tps = 738.186520 (without initial connection time)</td><td>tps = 732.214936  (without initial connection time)</td></tr>
	</tbody>
</table>

За счет ограничения max_connections и effective_cache_size при увеличении значений остальных рекомендованных параметров мы получили небольшой прирост количества транзакций - во втором (и третьем) тесте за 1 минуту было обработано 44294 (43936) транзакции с пропускной способностью примерно 738 (732) транзакций в секунду.

**2.** - Создаём таблицу _test_ и заполняем её тестовыми данными:
```
postgres@vmotus08:/home/devops$ psql

postgres=# create database otus;
CREATE DATABASE

postgres=# \c otus
You are now connected to database "otus" as user "postgres".
otus=#

otus=# create table test (id1 serial, str1 text);
CREATE TABLE

otus=# do $$
begin
insert into test(str1) select gen_random_uuid() from generate_series(1,1000000);
end$$;
DO
```

Проверяем:
```
otus=# select count(id1) from test;
  count
---------
 1000000
(1 row)

otus=# select * from test order by id1 limit 5;
 id1 |                 str1
-----+--------------------------------------
   1 | 3d89fe12-1239-4d9d-9b30-770f89bc783f
   2 | 73ada861-599a-49a0-9530-1868a4bc3a0f
   3 | 7e906057-343a-4cf3-82f2-023bd0b7e437
   4 | 76fa0412-68ee-48a6-a0c5-bbe48a2c62af
   5 | 7f8d71fb-abdb-489e-b1d0-69b174d7bf9c
(5 rows)
```

Смотрим размер файла:
```
otus=# select pg_size_pretty(pg_total_relation_size('test'));
 pg_size_pretty
----------------
 73 MB
(1 row)
```

Обновляем все строки таблицы _test_ 5 раз - добавляем 1 символ к текствовому полю:
```
otus=# do $$declare ii integer =0;
begin
loop
exit when ii>=5;
update test set str1=str1||ii;
ii=ii+1;
end loop;
end$$;
DO
```

Проверяем:
```
otus=# select count(id1) from test;
  count
---------
 1000000
(1 row)

otus=# select * from test order by id1 limit 5;
 id1 |                   str1
-----+-------------------------------------------
   1 | 3d89fe12-1239-4d9d-9b30-770f89bc783f01234
   2 | 73ada861-599a-49a0-9530-1868a4bc3a0f01234
   3 | 7e906057-343a-4cf3-82f2-023bd0b7e43701234
   4 | 76fa0412-68ee-48a6-a0c5-bbe48a2c62af01234
   5 | 7f8d71fb-abdb-489e-b1d0-69b174d7bf9c01234
(5 rows)

otus=# select pg_size_pretty(pg_total_relation_size('test'));
 pg_size_pretty
----------------
 438 MB
(1 row)

otus=# select relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum from pg_stat_user_tables where relname='test';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test    |    1000000 |          0 |      0 | 2024-02-28 08:07:38.609484+00
(1 row)
```
Автовакуум успел очистить мёртвые строки.

Повторяем обновление строк ещё 5 раз:
```
otus=# do $$declare ii integer =0;
begin
loop
exit when ii>=5;
update test set str1=str1||ii;
ii=ii+1;
end loop;
end$$;
DO
```

Смотрим данные по строкам таблицы _test_:
```
otus=# select relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum from pg_stat_user_tables where relname='test';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test    |    1000000 |    5000000 |    499 | 2024-02-28 08:07:38.609484+00
(1 row)
```
Пятикратное обновление 1 млн. строк привело к появлению 5 млн. мёртвых строк.

Смотрим данные ещё раз:
```
otus=# select relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum from pg_stat_user_tables where relname='test';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test    |    1000000 |          0 |      0 | 2024-02-28 08:12:38.469629+00
(1 row)
```
Автовакуум отработал.

Смотрим размер файла:
```
otus=# select pg_size_pretty(pg_total_relation_size('test'));
 pg_size_pretty
----------------
 461 MB
(1 row)
```
Размер файла только увеличивается. Автовакуум удаляет мёртвые строки, но место на диске остаётся зарезервированным под новые строки.

Отключаем автовакуум для таблицы _test_;
```
otus=# alter table test set (autovacuum_enabled = off);
ALTER TABLE
```

Обновляем все строки таблицы _test_ 10 раз:
```
otus=# do $$declare ii integer =0;
begin
loop
exit when ii>=10;
update test set str1=str1||ii;
ii=ii+1;
end loop;
end$$;
DO
```

Смотрим размер файла:
```
 pg_size_pretty
----------------
 927 MB
(1 row)
```
Размер файла ожидаемо вырос. Операция _update_ подразумевает выполнение двух операций - _insert_ новой строки с новым значением изменяемого атрибута (новая версия строки) и _delete_ текущей версии изменяемой строки. При этом фактическое удаление не производится, выполняется только изменение служебных атрибутов - строка отмечается как мёртвая.

Смотрим данные по живым и мёртвым строкам:
```
otus=# select relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum from pg_stat_user_tables where relname='test';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test    |    1000000 |   10000000 |    999 | 2024-02-28 08:12:38.469629+00
(1 row)
```
В очередной раз мы получили количество мёртвых строк пропорциональное количеству операций обновления.

Включаем автовакуум для таблицы _test_:
```
otus=# alter table test set (autovacuum_enabled = on);
ALTER TABLE
```

Смотрим данные по живым и мёртвым строкам:
```
otus=# select relname, n_live_tup, n_dead_tup, trunc(100*n_dead_tup/(n_live_tup+1))::float "ratio%", last_autovacuum from pg_stat_user_tables where relname='test';
 relname | n_live_tup | n_dead_tup | ratio% |        last_autovacuum
---------+------------+------------+--------+-------------------------------
 test    |    1000000 |          0 |      0 | 2024-02-28 08:51:02.339003+00
(1 row)
```
Автовакуум очистил мётвые строки.

Для возвращения освобожденного объёма памяти/дискового пространства в операционную систему необходимо выполнить vacuum full:
```
otus=# vacuum full test;
VACUUM

otus=# select pg_size_pretty(pg_total_relation_size('test'));
 pg_size_pretty
----------------
 96 MB
(1 row)
```

Для оптимизации работы так же нужно пересчитать статистику:
```
otus=# analyze test;
ANALYZE
```

**3.** - Задание со * - автономная процедура, в которой в цикле 10 раз обновляются все строки в искомой таблице и выводится номер шага
```
do $$declare ii integer =0;
begin
loop
exit when ii>=10;
update test set str1=str1||ii;
raise notice 'step: %',ii;
ii=ii+1;
end loop;
end$$;
```

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
