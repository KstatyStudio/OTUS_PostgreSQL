## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 9 "Журналы"

### Домашнее задание
Работа с журналами

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 14

### Решение

**1.** - Проверяем настройки сервера PostgreSQL:
```
devops@vmotus09:~$ sudo -u postgres psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
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
 0/16FB350          | 0/16FB350
(1 row)

postgres=# \q
```

**2.** - Выполняем нагрузочное тестирование:

Cоздаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
devops@vmotus09:~$ sudo su postgres

postgres@vmotus09:/home/devops$ pgbench -i postgres
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
done in 0.86 s (drop tables 0.00 s, create tables 0.03 s, client-side generate 0.53 s, vacuum 0.08 s, primary keys 0.23 s).
```

Запускаем тест на 10 минут:
```
postgres@vmotus09:/home/devops$ pgbench -c8 -P 6 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 222.2 tps, lat 35.860 ms stddev 47.174
progress: 12.0 s, 292.2 tps, lat 27.372 ms stddev 19.605
progress: 18.0 s, 340.7 tps, lat 23.503 ms stddev 18.249
progress: 24.0 s, 501.0 tps, lat 15.950 ms stddev 15.592
progress: 30.0 s, 505.7 tps, lat 15.782 ms stddev 12.591
progress: 36.0 s, 455.2 tps, lat 17.631 ms stddev 20.144
progress: 42.0 s, 581.7 tps, lat 13.757 ms stddev 8.341
progress: 48.0 s, 493.2 tps, lat 16.179 ms stddev 12.248
progress: 54.0 s, 369.2 tps, lat 21.705 ms stddev 16.873
progress: 60.0 s, 505.2 tps, lat 15.774 ms stddev 10.041
progress: 66.0 s, 330.5 tps, lat 24.317 ms stddev 28.930
progress: 72.0 s, 320.8 tps, lat 24.882 ms stddev 21.280
progress: 78.0 s, 467.8 tps, lat 17.126 ms stddev 14.350
progress: 84.0 s, 579.0 tps, lat 13.828 ms stddev 8.469
progress: 90.0 s, 472.2 tps, lat 16.877 ms stddev 13.977
progress: 96.0 s, 287.2 tps, lat 27.950 ms stddev 26.961
progress: 102.0 s, 162.5 tps, lat 49.128 ms stddev 29.109
progress: 108.0 s, 293.5 tps, lat 27.262 ms stddev 18.312
progress: 114.0 s, 220.8 tps, lat 36.214 ms stddev 20.932
progress: 120.0 s, 238.3 tps, lat 33.378 ms stddev 18.406
progress: 126.0 s, 172.3 tps, lat 46.732 ms stddev 43.573
progress: 132.0 s, 402.5 tps, lat 19.900 ms stddev 13.995
progress: 138.0 s, 462.5 tps, lat 17.305 ms stddev 15.824
progress: 144.0 s, 541.7 tps, lat 14.758 ms stddev 8.825
progress: 150.0 s, 533.0 tps, lat 14.913 ms stddev 9.770
progress: 156.0 s, 358.2 tps, lat 22.468 ms stddev 21.433
progress: 162.0 s, 298.7 tps, lat 26.818 ms stddev 18.713
progress: 168.0 s, 482.1 tps, lat 16.574 ms stddev 12.857
progress: 174.0 s, 541.4 tps, lat 14.790 ms stddev 9.110
progress: 180.0 s, 412.2 tps, lat 19.344 ms stddev 15.932
progress: 186.0 s, 334.8 tps, lat 23.964 ms stddev 29.335
progress: 192.0 s, 494.7 tps, lat 16.128 ms stddev 11.491
progress: 198.0 s, 390.5 tps, lat 20.545 ms stddev 16.789
progress: 204.0 s, 267.0 tps, lat 29.971 ms stddev 24.134
progress: 210.0 s, 553.2 tps, lat 14.379 ms stddev 9.700
progress: 216.0 s, 294.5 tps, lat 27.315 ms stddev 25.602
progress: 222.0 s, 473.7 tps, lat 16.857 ms stddev 13.056
progress: 228.0 s, 252.8 tps, lat 31.584 ms stddev 24.348
progress: 234.0 s, 415.8 tps, lat 19.289 ms stddev 18.148
progress: 240.0 s, 507.8 tps, lat 15.699 ms stddev 10.910
progress: 246.0 s, 330.7 tps, lat 24.297 ms stddev 31.830
progress: 252.0 s, 490.0 tps, lat 16.327 ms stddev 11.421
progress: 258.0 s, 542.2 tps, lat 14.746 ms stddev 15.014
progress: 264.0 s, 491.8 tps, lat 16.257 ms stddev 10.866
progress: 270.0 s, 578.5 tps, lat 13.691 ms stddev 8.832
progress: 276.0 s, 394.8 tps, lat 20.481 ms stddev 30.463
progress: 282.0 s, 443.8 tps, lat 18.006 ms stddev 13.533
progress: 288.0 s, 274.3 tps, lat 29.147 ms stddev 21.097
progress: 294.0 s, 585.3 tps, lat 13.688 ms stddev 8.212
progress: 300.0 s, 308.3 tps, lat 25.813 ms stddev 19.338
progress: 306.0 s, 180.5 tps, lat 44.551 ms stddev 35.222
progress: 312.0 s, 512.3 tps, lat 15.616 ms stddev 9.967
progress: 318.0 s, 398.3 tps, lat 20.004 ms stddev 17.835
progress: 324.0 s, 506.7 tps, lat 15.850 ms stddev 12.698
progress: 330.0 s, 542.0 tps, lat 14.651 ms stddev 10.669
progress: 336.0 s, 351.2 tps, lat 22.918 ms stddev 28.418
progress: 342.0 s, 461.2 tps, lat 17.351 ms stddev 12.859
progress: 348.0 s, 451.7 tps, lat 17.728 ms stddev 13.518
progress: 354.0 s, 552.5 tps, lat 14.470 ms stddev 8.941
progress: 360.0 s, 574.0 tps, lat 13.830 ms stddev 9.108
progress: 366.0 s, 240.0 tps, lat 33.561 ms stddev 30.552
progress: 372.0 s, 436.3 tps, lat 18.362 ms stddev 12.307
progress: 378.0 s, 438.7 tps, lat 18.239 ms stddev 14.377
progress: 384.0 s, 515.3 tps, lat 15.519 ms stddev 9.928
progress: 390.0 s, 561.3 tps, lat 14.116 ms stddev 9.235
progress: 396.0 s, 328.2 tps, lat 24.602 ms stddev 27.952
progress: 402.0 s, 521.2 tps, lat 15.335 ms stddev 10.238
progress: 408.0 s, 468.2 tps, lat 17.100 ms stddev 13.338
progress: 414.0 s, 394.2 tps, lat 20.292 ms stddev 12.578
progress: 420.0 s, 455.3 tps, lat 17.439 ms stddev 10.736
progress: 426.0 s, 179.2 tps, lat 44.889 ms stddev 38.638
progress: 432.0 s, 277.5 tps, lat 28.907 ms stddev 18.810
progress: 438.0 s, 435.3 tps, lat 18.374 ms stddev 13.163
progress: 444.0 s, 524.3 tps, lat 15.234 ms stddev 9.830
progress: 450.0 s, 397.0 tps, lat 20.069 ms stddev 13.282
progress: 456.0 s, 378.0 tps, lat 21.285 ms stddev 21.717
progress: 462.0 s, 465.5 tps, lat 17.143 ms stddev 12.117
progress: 468.0 s, 244.3 tps, lat 32.780 ms stddev 23.784
progress: 474.0 s, 344.3 tps, lat 23.190 ms stddev 13.802
progress: 480.0 s, 224.2 tps, lat 35.558 ms stddev 18.014
progress: 486.0 s, 170.3 tps, lat 47.149 ms stddev 30.314
progress: 492.0 s, 309.5 tps, lat 25.908 ms stddev 19.193
progress: 498.0 s, 498.2 tps, lat 16.057 ms stddev 12.706
progress: 504.0 s, 433.7 tps, lat 18.454 ms stddev 14.419
progress: 510.0 s, 517.3 tps, lat 15.400 ms stddev 10.170
progress: 516.0 s, 328.7 tps, lat 24.432 ms stddev 29.716
progress: 522.0 s, 525.7 tps, lat 15.221 ms stddev 10.457
progress: 528.0 s, 480.3 tps, lat 16.584 ms stddev 15.366
progress: 534.0 s, 529.2 tps, lat 15.178 ms stddev 10.172
progress: 540.0 s, 515.3 tps, lat 15.469 ms stddev 10.228
progress: 546.0 s, 269.8 tps, lat 29.773 ms stddev 33.218
progress: 552.0 s, 501.3 tps, lat 15.925 ms stddev 10.820
progress: 558.0 s, 495.2 tps, lat 16.182 ms stddev 15.423
progress: 564.0 s, 486.3 tps, lat 16.433 ms stddev 11.146
progress: 570.0 s, 544.3 tps, lat 14.621 ms stddev 9.365
progress: 576.0 s, 381.0 tps, lat 21.124 ms stddev 23.224
progress: 582.0 s, 437.5 tps, lat 18.269 ms stddev 13.910
progress: 588.0 s, 490.3 tps, lat 16.324 ms stddev 12.284
progress: 594.0 s, 450.8 tps, lat 17.743 ms stddev 12.428
progress: 600.0 s, 502.5 tps, lat 15.868 ms stddev 10.484
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
duration: 600 s
number of transactions actually processed: 248971
latency average = 19.279 ms
latency stddev = 17.958 ms
initial connection time = 16.021 ms
tps = 414.922854 (without initial connection time)
```

**3.** - Оценим объем сгенерированных журнальных записей.

Смотрим значение LSN:
```
postgres@vmotus09:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# select pg_current_wal_lsn(), pg_current_wal_insert_lsn();
 pg_current_wal_lsn | pg_current_wal_insert_lsn
--------------------+---------------------------
 0/1B9B0F48         | 0/1B9B0F48
(1 row)
```

Вычисляем объем сгенерированных журнальных записей:
```
postgres=# select '0/1B9B0F48'::pg_lsn - '0/16FB350'::pg_lsn as bytes;
   bytes
-----------
 439049208
(1 row)
```

В процессе нагрузочного теста было сгененрировано 439049208 байт журнальных записей. В течение 10 минут должны были выполниться 20 контрольных точек (600 сек. тест / 30 сек. checkpoint_timeout). Таким образом, на каждую контрольную точку приходится примерно 21952460 байт журнальных записей (~ 22 Мб).

**4.** - Проверяем данные статистики:
```
postgres=# select* from pg_stat_bgwriter \gx
-[ RECORD 1 ]---------+------------------------------
checkpoints_timed     | 34
checkpoints_req       | 0
checkpoint_write_time | 591676
checkpoint_sync_time  | 421
buffers_checkpoint    | 42002
buffers_clean         | 0
maxwritten_clean      | 0
buffers_backend       | 3442
buffers_backend_fsync | 0
buffers_alloc         | 4028
stats_reset           | 2024-03-11 07:28:18.556853+00
```
Выполнены 34 контрольные точки. 


Смотрим настройки PostgreSQL:
```
postgres=# select setting, unit from pg_settings where name='min_wal_size';
 setting | unit
---------+------
 80      | MB
(1 row)

postgres=# select setting, unit from pg_settings where name='max_wal_size';
 setting | unit
---------+------
 1024    | MB
(1 row)
```



<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
