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
postgres=# SELECT pg_current_wal_lsn(), pg_current_wal_insert_lsn();
 pg_current_wal_lsn | pg_current_wal_insert_lsn
--------------------+---------------------------
 0/66DBB808         | 0/66DBB808
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
progress: 6.0 s, 314.5 tps, lat 25.274 ms stddev 30.549
progress: 12.0 s, 416.8 tps, lat 19.215 ms stddev 19.944
progress: 18.0 s, 283.3 tps, lat 28.256 ms stddev 24.444
progress: 24.0 s, 391.0 tps, lat 20.448 ms stddev 22.382
progress: 30.0 s, 361.3 tps, lat 22.133 ms stddev 35.871
progress: 36.0 s, 276.0 tps, lat 28.788 ms stddev 34.490
progress: 42.0 s, 250.7 tps, lat 32.025 ms stddev 27.364
progress: 48.0 s, 286.3 tps, lat 28.073 ms stddev 25.037
progress: 54.0 s, 327.8 tps, lat 24.315 ms stddev 34.411
progress: 60.0 s, 391.0 tps, lat 20.525 ms stddev 21.057
progress: 66.0 s, 283.3 tps, lat 28.237 ms stddev 40.113
progress: 72.0 s, 399.5 tps, lat 20.020 ms stddev 20.625
progress: 78.0 s, 388.2 tps, lat 20.501 ms stddev 21.276
progress: 84.0 s, 378.7 tps, lat 21.252 ms stddev 22.212
progress: 90.0 s, 398.3 tps, lat 20.079 ms stddev 33.207
progress: 96.0 s, 288.3 tps, lat 27.703 ms stddev 36.854
progress: 102.0 s, 366.3 tps, lat 21.880 ms stddev 21.147
progress: 108.0 s, 433.5 tps, lat 18.309 ms stddev 19.881
progress: 114.0 s, 439.2 tps, lat 18.336 ms stddev 20.709
progress: 120.0 s, 369.0 tps, lat 21.676 ms stddev 33.636
progress: 126.0 s, 330.5 tps, lat 24.220 ms stddev 32.855
progress: 132.0 s, 387.3 tps, lat 20.631 ms stddev 20.826
progress: 138.0 s, 369.8 tps, lat 21.671 ms stddev 20.978
progress: 144.0 s, 360.7 tps, lat 21.434 ms stddev 23.517
progress: 150.0 s, 423.0 tps, lat 19.550 ms stddev 26.602
progress: 156.0 s, 288.5 tps, lat 27.097 ms stddev 37.531
progress: 162.0 s, 430.8 tps, lat 18.950 ms stddev 27.114
progress: 168.0 s, 380.7 tps, lat 21.060 ms stddev 21.710
progress: 174.0 s, 372.8 tps, lat 21.387 ms stddev 22.318
progress: 180.0 s, 297.7 tps, lat 26.851 ms stddev 39.473
progress: 186.0 s, 329.0 tps, lat 24.397 ms stddev 32.235
progress: 192.0 s, 276.5 tps, lat 28.922 ms stddev 34.886
progress: 198.0 s, 391.3 tps, lat 20.415 ms stddev 21.511
progress: 204.0 s, 364.5 tps, lat 21.971 ms stddev 23.331
progress: 210.0 s, 317.8 tps, lat 25.025 ms stddev 35.488
progress: 216.0 s, 308.7 tps, lat 26.034 ms stddev 29.571
progress: 222.0 s, 333.7 tps, lat 23.843 ms stddev 30.171
progress: 228.0 s, 421.7 tps, lat 19.097 ms stddev 21.604
progress: 234.0 s, 453.2 tps, lat 17.678 ms stddev 19.687
progress: 240.0 s, 431.5 tps, lat 18.393 ms stddev 30.326
progress: 246.0 s, 354.5 tps, lat 22.711 ms stddev 27.434
progress: 252.0 s, 376.0 tps, lat 21.303 ms stddev 32.062
progress: 258.0 s, 386.3 tps, lat 20.693 ms stddev 21.398
progress: 264.0 s, 287.7 tps, lat 27.792 ms stddev 31.721
progress: 270.0 s, 385.3 tps, lat 20.740 ms stddev 20.722
progress: 276.0 s, 282.8 tps, lat 28.272 ms stddev 27.634
progress: 282.0 s, 359.2 tps, lat 22.248 ms stddev 29.702
progress: 288.0 s, 409.0 tps, lat 19.627 ms stddev 20.837
progress: 294.0 s, 396.2 tps, lat 20.206 ms stddev 21.275
progress: 300.0 s, 404.0 tps, lat 19.716 ms stddev 31.930
progress: 306.0 s, 334.2 tps, lat 24.048 ms stddev 26.227
progress: 312.0 s, 376.3 tps, lat 21.253 ms stddev 30.812
progress: 318.0 s, 392.5 tps, lat 20.371 ms stddev 20.265
progress: 324.0 s, 372.2 tps, lat 21.510 ms stddev 22.570
progress: 330.0 s, 399.3 tps, lat 20.032 ms stddev 29.830
progress: 336.0 s, 316.0 tps, lat 25.262 ms stddev 31.524
progress: 342.0 s, 444.3 tps, lat 18.026 ms stddev 18.627
progress: 348.0 s, 417.3 tps, lat 19.161 ms stddev 30.969
progress: 354.0 s, 381.3 tps, lat 20.952 ms stddev 22.895
progress: 360.0 s, 326.0 tps, lat 24.394 ms stddev 34.663
progress: 366.0 s, 197.7 tps, lat 40.666 ms stddev 32.252
progress: 372.0 s, 315.5 tps, lat 25.426 ms stddev 23.708
progress: 378.0 s, 394.2 tps, lat 20.308 ms stddev 29.817
progress: 384.0 s, 389.5 tps, lat 20.386 ms stddev 20.442
progress: 390.0 s, 298.5 tps, lat 26.992 ms stddev 39.289
progress: 396.0 s, 332.8 tps, lat 24.032 ms stddev 28.562
progress: 402.0 s, 421.2 tps, lat 19.000 ms stddev 19.919
progress: 408.0 s, 373.3 tps, lat 21.238 ms stddev 34.636
progress: 414.0 s, 391.3 tps, lat 20.627 ms stddev 22.131
progress: 420.0 s, 379.5 tps, lat 21.068 ms stddev 33.913
progress: 426.0 s, 302.3 tps, lat 26.442 ms stddev 26.458
progress: 432.0 s, 383.8 tps, lat 20.843 ms stddev 20.012
progress: 438.0 s, 323.7 tps, lat 24.544 ms stddev 34.777
progress: 444.0 s, 322.8 tps, lat 24.897 ms stddev 25.211
progress: 450.0 s, 416.3 tps, lat 19.272 ms stddev 28.121
progress: 456.0 s, 320.3 tps, lat 24.976 ms stddev 26.244
progress: 462.0 s, 422.2 tps, lat 18.924 ms stddev 20.130
progress: 468.0 s, 384.2 tps, lat 20.845 ms stddev 30.538
progress: 474.0 s, 393.7 tps, lat 20.331 ms stddev 22.388
progress: 480.0 s, 429.3 tps, lat 18.634 ms stddev 29.531
progress: 486.0 s, 354.8 tps, lat 22.335 ms stddev 28.943
progress: 492.0 s, 430.5 tps, lat 18.740 ms stddev 19.160
progress: 498.0 s, 436.7 tps, lat 18.329 ms stddev 19.214
progress: 504.0 s, 374.8 tps, lat 21.255 ms stddev 32.156
progress: 510.0 s, 295.7 tps, lat 27.140 ms stddev 36.240
progress: 516.0 s, 312.8 tps, lat 25.459 ms stddev 34.391
progress: 522.0 s, 270.7 tps, lat 29.652 ms stddev 33.184
progress: 528.0 s, 402.0 tps, lat 19.727 ms stddev 20.315
progress: 534.0 s, 314.7 tps, lat 25.637 ms stddev 34.859
progress: 540.0 s, 364.8 tps, lat 21.897 ms stddev 29.305
progress: 546.0 s, 231.5 tps, lat 34.588 ms stddev 40.036
progress: 552.0 s, 336.7 tps, lat 23.832 ms stddev 23.582
progress: 558.0 s, 401.2 tps, lat 19.939 ms stddev 20.987
progress: 564.0 s, 336.5 tps, lat 23.778 ms stddev 35.131
progress: 570.0 s, 351.8 tps, lat 22.732 ms stddev 35.279
progress: 576.0 s, 325.2 tps, lat 24.569 ms stddev 35.740
progress: 582.0 s, 317.0 tps, lat 25.167 ms stddev 23.949
progress: 588.0 s, 397.3 tps, lat 20.120 ms stddev 21.138
progress: 594.0 s, 305.0 tps, lat 25.852 ms stddev 37.002
progress: 600.0 s, 443.7 tps, lat 18.271 ms stddev 21.063
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
duration: 600 s
number of transactions actually processed: 215461
latency average = 22.277 ms
latency stddev = 27.929 ms
tps = 359.084651 (including connections establishing)
tps = 359.085780 (excluding connections establishing)
```

**3.** - Оценим объем сгенерированных журнальных записей.

Смотрим значение LSN:
```
postgres@vmotus07:/home/devops$ psql
psql (13.14 (Ubuntu 13.14-1.pgdg22.04+1))
Type "help" for help.

postgres=# SELECT pg_current_wal_lsn(), pg_current_wal_insert_lsn();
 pg_current_wal_lsn | pg_current_wal_insert_lsn
--------------------+---------------------------
 0/7E9FC8B8         | 0/7E9FC8B8
(1 row)
```

Вычисляем объем сгенерированных журнальных записей:
```
postgres=# select '0/7E9FC8B8'::pg_lsn - '0/66DBB808'::pg_lsn as bytes;
   bytes
-----------
 398725296
(1 row)
```

В процессе нагрузочного теста было сгененрировано 398725296 байт журнальных записей. В течение 10 минут должны были выполниться 20 контрольных точек (600 сек. тест / 30 сек. checkpoint_timeout). Таким образом, на каждую контрольную точку приходится примерно 19936264 байт журнальных записей (~ 19 Мб).

**4.** - Проверяем данные статистики:








<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
