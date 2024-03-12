## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 11 "Настройка PostgreSQL"

### Домашнее задание
Нагрузочное тестирование и тюнинг PostgreSQL

### Исходные данные
ВМ (облако): 2 ядра, 2Гб, HDD 10Гб, Ubuntu 22.04, PostgreSQL 14

### Решение

**1.** - Cоздаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
devops@vmotus11:~$ sudo su postgres
postgres@vmotus11:/home/devops$ pgbench -i postgres
dropping old tables...
NOTICE:  table "pgbench_accounts" does not exist, skipping
NOTICE:  table "pgbench_branches" does not exist, skipping
NOTICE:  table "pgbench_history" does not exist, skipping
NOTICE:  table "pgbench_tellers" does not exist, skipping
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.06 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 0.59 s (drop tables 0.00 s, create tables 0.03 s, client-side generate 0.45 s, vacuum 0.05 s, primary keys 0.06 s).
```

**2.** - Проведём нагрузочное тестирование сервера PostgreSQL с настройками по умолчанию.
```
postgres@vmotus11:/home/devops$ pgbench -c50 -j 2 -P 60 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 60.0 s, 597.8 tps, lat 83.594 ms stddev 59.082
progress: 120.0 s, 654.5 tps, lat 76.212 ms stddev 55.432
progress: 180.0 s, 629.8 tps, lat 79.863 ms stddev 59.851
progress: 240.0 s, 552.4 tps, lat 90.484 ms stddev 67.033
progress: 300.0 s, 620.7 tps, lat 80.412 ms stddev 56.218
progress: 360.0 s, 630.2 tps, lat 79.262 ms stddev 57.311
progress: 420.0 s, 661.1 tps, lat 75.623 ms stddev 55.853
progress: 480.0 s, 575.0 tps, lat 87.224 ms stddev 68.194
progress: 540.0 s, 578.7 tps, lat 86.337 ms stddev 63.155
progress: 600.0 s, 564.0 tps, lat 88.982 ms stddev 65.214
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
duration: 600 s
number of transactions actually processed: 343060
latency average = 87.449 ms
latency stddev = 75.226 ms
initial connection time = 56.606 ms
tps = 571.700896 (without initial connection time)
```
В среднем при настройках по умолчанию выполняется 571 транзакция в секунду.

**3.** - Увеличим память, буферы и размеры журнала предзаписи:
```
postgres@vmotus11:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# alter system set work_mem='64MB';
ALTER SYSTEM

postgres=# alter system set maintenance_work_mem='512MB';
ALTER SYSTEM

postgres=# alter system set shared_buffers='1GB';
ALTER SYSTEM

postgres=# alter system set wal_buffers='16MB';
ALTER SYSTEM

postgres=# alter system set min_wal_size='512MB';
ALTER SYSTEM

postgres=# alter system set max_wal_size='2GB';
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
postgres=# \q

postgres@vmotus11:/home/devops$ exit

devops@vmotus11:~$ sudo systemctl restart postgresql

devops@vmotus11:~$ sudo su postgres
```

Повторим нагрузочное тестирование:
```
postgres@vmotus11:/home/devops$ pgbench -c50 -j 2 -P 10 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 60.0 s, 586.6 tps, lat 85.237 ms stddev 80.620
progress: 120.0 s, 556.9 tps, lat 89.640 ms stddev 95.617
progress: 180.0 s, 530.6 tps, lat 94.307 ms stddev 92.115
progress: 240.0 s, 501.3 tps, lat 99.565 ms stddev 101.365
progress: 300.0 s, 539.8 tps, lat 92.638 ms stddev 104.537
progress: 360.0 s, 540.3 tps, lat 92.516 ms stddev 85.586
progress: 420.0 s, 466.7 tps, lat 107.418 ms stddev 113.003
progress: 480.0 s, 553.4 tps, lat 90.358 ms stddev 90.675
progress: 540.0 s, 553.0 tps, lat 90.343 ms stddev 86.457
progress: 600.0 s, 516.7 tps, lat 96.762 ms stddev 91.560
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
duration: 600 s
number of transactions actually processed: 350715
latency average = 85.539 ms
latency stddev = 73.049 ms
initial connection time = 58.944 ms
tps = 584.470222 (without initial connection time)
```
Выбранные параметры позволили незначительно увеличить производительность - выполняется 584 транзакции в секунду.

**4.** - Включим асинхронный режим записи на диск журнала предзаписи:
```
postgres@vmotus11:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# alter system set synchronous_commit=off;
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
postgres=# \q

postgres@vmotus11:/home/devops$ exit

devops@vmotus11:~$ sudo systemctl restart postgresql

devops@vmotus11:~$ sudo su postgres
```

И ещё раз повторим нагрузочное тестирование:
```
postgres@vmotus11:/home/devops$ pgbench -c50 -j 2 -P 60 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 60.0 s, 2518.6 tps, lat 19.828 ms stddev 13.525
progress: 120.0 s, 2614.0 tps, lat 19.126 ms stddev 15.532
progress: 180.0 s, 2649.0 tps, lat 18.874 ms stddev 14.005
progress: 240.0 s, 2572.9 tps, lat 19.432 ms stddev 14.029
progress: 300.0 s, 2565.7 tps, lat 19.488 ms stddev 14.566
progress: 360.0 s, 2635.9 tps, lat 18.969 ms stddev 14.607
progress: 420.0 s, 2549.0 tps, lat 19.614 ms stddev 13.767
progress: 480.0 s, 2458.6 tps, lat 20.337 ms stddev 14.102
progress: 540.0 s, 2534.2 tps, lat 19.729 ms stddev 14.830
progress: 600.0 s, 2439.3 tps, lat 20.497 ms stddev 13.319
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
duration: 600 s
number of transactions actually processed: 1532281
latency average = 19.578 ms
latency stddev = 14.264 ms
initial connection time = 60.078 ms
tps = 2553.581965 (without initial connection time)
```
В результате видим значительный прирост производительности - 2553 транзакции в секунду.

**5.** - Сравним результаты выполненных тестов:

<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Параметры</th><th>Настройки по умолчанию</th><th>Увеличены память, буферы, размер WAL</th><th>Включен асинхронный режим</th></tr>
	</thead>
	<tbody>
		<tr><td>number of transactions actually processed</td><td>343060</td><td>350715</td><td>1532281</td></tr>
		<tr><td>latency average</td><td>87.449 ms</td><td>85.539 ms</td><td>19.578 ms</td></tr>
		<tr><td>latency stddev</td><td>75.226 ms</td><td>73.049 ms</td><td>14.264 ms</td></tr>
		<tr><td>initial connection time</td><td>56.606 ms</td><td>58.944 ms</td><td>60.078 ms</td></tr>
		<tr><td>tps</td><td>571.700896</td><td>584.470222</td><td>2553.581965</td></tr>
	</tbody>
</table>

Максимальную производительность можно достигнуть путём включения асинхронного режима записи журнала предзаписи на диск, при условии, что надежность в случае аварийной перезагрузки виртуальной машины не является приоритетом. При заданных параметрах ВМ изменение настроек памяти, буферов и размеров WAL на производительность влияют незначительно.

В ходе тестирования изменялись следующие настройки сервера PostgreSQL:

<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Настройка</th><th>Значение по умолчанию</th><th>Значение для теста</th></tr>
	</thead>
	<tbody>
		<tr><td>work_mem</td><td>4MB</td><td>64MB</td></tr>
		<tr><td>maintenance_work_mem</td><td>64MB</td><td>512MB</td></tr>
		<tr><td>shared_buffers</td><td>128MB</td><td>1GB</td></tr>
		<tr><td>wal_buffers</td><td>-1</td><td>16MB</td></tr>
		<tr><td>min_wal_size</td><td>80MB</td><td>512MB</td></tr>
		<tr><td>max_wal_size</td><td>1GB</td><td>2GB</td></tr>
		<tr><td>synchronous_commit</td><td>on</td><td>off</td></tr>
	</tbody>
</table>

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
