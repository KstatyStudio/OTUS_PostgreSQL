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

Редактируем конфигурацию PostgreSQL - применяем рекомендованные параметры:

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

Сравниваем результаты двух тестов:
<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Параметры по умолчанию</th><th>Рекомендованные параметры</th></tr>
	</thead>
	<tbody>
		<tr><td>scaling factor: 1</td><td>scaling factor: 1</td></tr>
		<tr><td>query mode: simple</td><td>query mode: simple</td></tr>
		<tr><td>number of clients: 8</td><td>number of clients: 8</td></tr>
		<tr><td>number of threads: 1</td><td>number of threads: 1</td></tr>
		<tr><td>maximum number of tries: 1</td><td>maximum number of tries: 1</td></tr>
		<tr><td>duration: 60 s</td><td>duration: 60 s</td></tr>
		<tr><td>number of transactions actually processed: 43285</td><td>number of transactions actually processed: 44294</td></tr>
		<tr><td>number of failed transactions: 0 (0.000%)</td><td>number of failed transactions: 0 (0.000%)</td></tr>
		<tr><td>latency average = 11.088 ms</td><td>latency average = 10.835 ms</td></tr>
		<tr><td>latency stddev = 13.979 ms</td><td>latency stddev = 8.563 ms</td></tr>
		<tr><td>initial connection time = 14.789 ms</td><td>initial connection time = 15.197 ms</td></tr>
		<tr><td>tps = 721.342332 (without initial connection time)</td><td>tps = 738.186520 (without initial connection time)</td></tr>
	</tbody>
</table>

За счет ограничения max_connections и effective_cache_size при увеличении значений остальных рекомендованных параметров мы получили небольшой прирост количества транзакций - во втором тесте за 1 минуту было обработано 44294 транзакции с пропускной способностью примерно 738 транзакций в секунду.








postgres@vmotus08:/home/devops$ psql
could not change directory to "/home/devops": Permission denied
psql (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
Type "help" for help.

postgres=# create database otus;
CREATE DATABASE

postgres=# \q



<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
