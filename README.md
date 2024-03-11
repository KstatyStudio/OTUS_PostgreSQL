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
```

Смотрим значение LSN:
```
postgres=# select pg_current_wal_lsn(), pg_current_wal_insert_lsn();
 pg_current_wal_lsn | pg_current_wal_insert_lsn
--------------------+---------------------------
 0/84636398         | 0/84636398
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
starting vacuum...end.
progress: 6.0 s, 407.0 tps, lat 19.549 ms stddev 21.671
progress: 12.0 s, 379.0 tps, lat 21.096 ms stddev 21.838
progress: 18.0 s, 441.0 tps, lat 18.052 ms stddev 19.820
progress: 24.0 s, 301.3 tps, lat 26.722 ms stddev 32.156
progress: 30.0 s, 403.2 tps, lat 19.859 ms stddev 20.751
progress: 36.0 s, 361.0 tps, lat 21.953 ms stddev 33.505
progress: 42.0 s, 378.7 tps, lat 21.270 ms stddev 32.432
progress: 48.0 s, 323.5 tps, lat 24.790 ms stddev 23.420
progress: 54.0 s, 373.7 tps, lat 21.406 ms stddev 27.703
progress: 60.0 s, 465.8 tps, lat 17.172 ms stddev 18.507
progress: 66.0 s, 385.3 tps, lat 20.645 ms stddev 27.539
progress: 72.0 s, 386.2 tps, lat 20.839 ms stddev 26.914
progress: 78.0 s, 512.5 tps, lat 15.604 ms stddev 17.544
progress: 84.0 s, 348.8 tps, lat 22.772 ms stddev 29.314
progress: 90.0 s, 414.2 tps, lat 19.447 ms stddev 20.343
progress: 96.0 s, 349.5 tps, lat 22.755 ms stddev 33.305
progress: 102.0 s, 385.8 tps, lat 20.844 ms stddev 23.686
progress: 108.0 s, 393.2 tps, lat 20.328 ms stddev 21.885
progress: 114.0 s, 355.8 tps, lat 22.520 ms stddev 27.132
progress: 120.0 s, 459.8 tps, lat 17.261 ms stddev 18.244
progress: 126.0 s, 423.8 tps, lat 18.967 ms stddev 19.576
progress: 132.0 s, 389.5 tps, lat 20.538 ms stddev 28.433
progress: 138.0 s, 442.7 tps, lat 18.128 ms stddev 19.758
progress: 144.0 s, 260.8 tps, lat 30.528 ms stddev 27.070
progress: 150.0 s, 430.0 tps, lat 18.617 ms stddev 19.198
progress: 156.0 s, 452.0 tps, lat 17.741 ms stddev 19.546
progress: 162.0 s, 416.3 tps, lat 19.240 ms stddev 31.933
progress: 168.0 s, 392.7 tps, lat 20.235 ms stddev 20.554
progress: 174.0 s, 197.8 tps, lat 40.680 ms stddev 31.026
progress: 180.0 s, 362.2 tps, lat 22.111 ms stddev 23.258
progress: 186.0 s, 429.5 tps, lat 18.414 ms stddev 20.040
progress: 192.0 s, 342.5 tps, lat 23.458 ms stddev 38.739
progress: 198.0 s, 372.0 tps, lat 21.656 ms stddev 21.667
progress: 204.0 s, 295.0 tps, lat 26.923 ms stddev 29.282
progress: 210.0 s, 436.5 tps, lat 18.458 ms stddev 19.486
progress: 216.0 s, 405.2 tps, lat 19.588 ms stddev 21.222
progress: 222.0 s, 375.0 tps, lat 21.441 ms stddev 35.986
progress: 228.0 s, 453.3 tps, lat 17.552 ms stddev 19.426
progress: 234.0 s, 353.2 tps, lat 22.831 ms stddev 26.641
progress: 240.0 s, 453.0 tps, lat 17.650 ms stddev 19.179
progress: 246.0 s, 420.0 tps, lat 19.040 ms stddev 20.847
progress: 252.0 s, 354.8 tps, lat 22.529 ms stddev 38.615
progress: 258.0 s, 393.0 tps, lat 20.380 ms stddev 20.636
progress: 264.0 s, 304.0 tps, lat 26.333 ms stddev 30.380
progress: 270.0 s, 439.3 tps, lat 18.068 ms stddev 20.928
progress: 276.0 s, 412.5 tps, lat 19.469 ms stddev 21.128
progress: 282.0 s, 388.0 tps, lat 20.694 ms stddev 31.330
progress: 288.0 s, 407.5 tps, lat 19.632 ms stddev 26.216
progress: 294.0 s, 364.7 tps, lat 21.942 ms stddev 29.452
progress: 300.0 s, 381.2 tps, lat 20.978 ms stddev 21.266
progress: 306.0 s, 453.5 tps, lat 17.599 ms stddev 19.210
progress: 312.0 s, 338.7 tps, lat 23.513 ms stddev 38.207
progress: 318.0 s, 428.0 tps, lat 18.829 ms stddev 27.097
progress: 324.0 s, 295.0 tps, lat 27.115 ms stddev 27.181
progress: 330.0 s, 455.5 tps, lat 17.489 ms stddev 18.917
progress: 336.0 s, 432.3 tps, lat 18.539 ms stddev 20.192
progress: 342.0 s, 378.2 tps, lat 21.208 ms stddev 33.687
progress: 348.0 s, 435.3 tps, lat 18.355 ms stddev 27.761
progress: 354.0 s, 363.2 tps, lat 21.895 ms stddev 24.403
progress: 360.0 s, 414.3 tps, lat 19.425 ms stddev 19.798
progress: 366.0 s, 401.5 tps, lat 19.842 ms stddev 21.979
progress: 372.0 s, 376.3 tps, lat 21.353 ms stddev 35.317
progress: 378.0 s, 429.3 tps, lat 18.639 ms stddev 30.859
progress: 384.0 s, 274.8 tps, lat 28.960 ms stddev 37.445
progress: 390.0 s, 306.3 tps, lat 26.245 ms stddev 23.798
progress: 396.0 s, 406.8 tps, lat 19.595 ms stddev 20.675
progress: 402.0 s, 366.3 tps, lat 21.906 ms stddev 33.333
progress: 408.0 s, 350.2 tps, lat 22.863 ms stddev 32.088
progress: 414.0 s, 336.2 tps, lat 23.771 ms stddev 27.951
progress: 420.0 s, 390.0 tps, lat 20.526 ms stddev 21.697
progress: 426.0 s, 381.3 tps, lat 20.877 ms stddev 21.770
progress: 432.0 s, 366.3 tps, lat 21.847 ms stddev 33.907
progress: 438.0 s, 440.5 tps, lat 18.214 ms stddev 19.280
progress: 444.0 s, 271.0 tps, lat 29.353 ms stddev 43.022
progress: 450.0 s, 452.3 tps, lat 17.813 ms stddev 19.302
progress: 456.0 s, 408.7 tps, lat 19.512 ms stddev 20.728
progress: 462.0 s, 368.5 tps, lat 21.772 ms stddev 33.171
progress: 468.0 s, 435.7 tps, lat 18.346 ms stddev 19.197
progress: 474.0 s, 310.7 tps, lat 25.734 ms stddev 38.660
progress: 480.0 s, 416.7 tps, lat 19.225 ms stddev 20.551
progress: 486.0 s, 397.2 tps, lat 20.064 ms stddev 21.786
progress: 492.0 s, 371.2 tps, lat 21.647 ms stddev 32.130
progress: 498.0 s, 479.7 tps, lat 16.562 ms stddev 18.320
progress: 504.0 s, 290.2 tps, lat 27.768 ms stddev 43.781
progress: 510.0 s, 334.0 tps, lat 23.943 ms stddev 23.067
progress: 516.0 s, 426.7 tps, lat 18.613 ms stddev 20.594
progress: 522.0 s, 387.7 tps, lat 20.795 ms stddev 31.022
progress: 528.0 s, 427.2 tps, lat 18.717 ms stddev 19.556
progress: 534.0 s, 368.0 tps, lat 21.601 ms stddev 32.424
progress: 540.0 s, 413.2 tps, lat 19.472 ms stddev 20.652
progress: 546.0 s, 418.5 tps, lat 19.127 ms stddev 20.308
progress: 552.0 s, 379.0 tps, lat 21.101 ms stddev 32.889
progress: 558.0 s, 334.7 tps, lat 23.898 ms stddev 22.873
progress: 564.0 s, 287.3 tps, lat 27.861 ms stddev 45.072
progress: 570.0 s, 407.5 tps, lat 19.613 ms stddev 21.114
progress: 576.0 s, 405.2 tps, lat 19.595 ms stddev 21.075
progress: 582.0 s, 353.5 tps, lat 22.824 ms stddev 33.726
progress: 588.0 s, 473.5 tps, lat 16.865 ms stddev 17.848
progress: 594.0 s, 333.8 tps, lat 24.008 ms stddev 28.048
progress: 600.0 s, 383.8 tps, lat 20.836 ms stddev 30.458
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
duration: 600 s
number of transactions actually processed: 231179
latency average = 20.762 ms
latency stddev = 26.352 ms
tps = 385.287494 (including connections establishing)
tps = 385.288567 (excluding connections establishing)
```

**3.** - Оценим объем сгенерированных журнальных записей.

Смотрим значение LSN:
```
postgres@vmotus07:/home/devops$ psql
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.

postgres=# select pg_current_wal_lsn(), pg_current_wal_insert_lsn();
 pg_current_wal_lsn | pg_current_wal_insert_lsn
--------------------+---------------------------
 0/9C5B11C0         | 0/9C5B11C0
(1 row)
```

Вычисляем объем сгенерированных журнальных записей:
```
postgres=# select '0/9C5B11C0'::pg_lsn - '0/84636398'::pg_lsn as bytes;
   bytes
-----------
 402107944
(1 row)
```

В процессе нагрузочного теста было сгененрировано 402107944 байт журнальных записей. В течение 10 минут должны были выполниться 20 контрольных точек (600 сек. тест / 30 сек. checkpoint_timeout). Таким образом, на каждую контрольную точку приходится примерно 20105397 байт журнальных записей (~ 20 Мб).

**4.** - Проверяем данные статистики:








<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
