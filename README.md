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
 30      | s\q
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
Выполнены 34 контрольные точки. Это больше, чем наши расчётные 20 точек. Причины: статистика просмотрена несколько позже окончания нагрузочного тестирования, а контрольные точки выполняются каждые 30 секунд. А так же точка может быть выполнена вне плана при достижении максимального размера журнала предзаписи. Смотрим текущие настройки минимального и максимального размеров журнала:
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

**5.** - Сравним производительность в синхронном и асинхронном режиме:
Смотрим текущие настройки записи журнала:
```
postgres=# select setting, unit from pg_settings where name='synchronous_commit';
 setting | unit
---------+------
 on      |
(1 row)
```
По умолчнию включён синхронный режим. Изменим режим на асинхронный и проведём повторное нагрузочное тестирование:
```
postgres=# alter system set synchronous_commit=off;
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)

postgres=# select setting, unit from pg_settings where name='synchronous_commit';
 setting | unit
---------+------
 off     |
(1 row)

postgres=# \q

postgres@vmotus09:/home/devops$ pgbench -c8 -P 6 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 6.0 s, 3134.3 tps, lat 2.544 ms stddev 0.801
progress: 12.0 s, 3151.1 tps, lat 2.538 ms stddev 0.796
progress: 18.0 s, 3211.4 tps, lat 2.491 ms stddev 0.815
progress: 24.0 s, 3168.8 tps, lat 2.524 ms stddev 0.783
progress: 30.0 s, 3156.8 tps, lat 2.534 ms stddev 0.824
progress: 36.0 s, 3181.0 tps, lat 2.514 ms stddev 0.784
progress: 42.0 s, 3101.2 tps, lat 2.579 ms stddev 0.910
progress: 48.0 s, 3065.7 tps, lat 2.609 ms stddev 0.837
progress: 54.0 s, 3042.5 tps, lat 2.629 ms stddev 1.038
progress: 60.0 s, 3140.5 tps, lat 2.547 ms stddev 0.794
progress: 66.0 s, 3019.3 tps, lat 2.649 ms stddev 0.746
progress: 72.0 s, 3198.3 tps, lat 2.501 ms stddev 0.874
progress: 78.0 s, 3179.9 tps, lat 2.516 ms stddev 0.817
progress: 84.0 s, 3165.8 tps, lat 2.526 ms stddev 0.758
progress: 90.0 s, 3203.0 tps, lat 2.497 ms stddev 0.886
progress: 96.0 s, 3234.2 tps, lat 2.473 ms stddev 0.762
progress: 102.0 s, 3219.7 tps, lat 2.484 ms stddev 0.846
progress: 108.0 s, 3182.3 tps, lat 2.513 ms stddev 0.860
progress: 114.0 s, 3129.2 tps, lat 2.556 ms stddev 0.807
progress: 120.0 s, 3180.4 tps, lat 2.515 ms stddev 0.892
progress: 126.0 s, 3199.1 tps, lat 2.500 ms stddev 0.795
progress: 132.0 s, 3240.7 tps, lat 2.468 ms stddev 0.788
progress: 138.0 s, 3192.7 tps, lat 2.505 ms stddev 0.839
progress: 144.0 s, 3003.8 tps, lat 2.663 ms stddev 0.781
progress: 150.0 s, 3206.2 tps, lat 2.495 ms stddev 0.814
progress: 156.0 s, 3245.1 tps, lat 2.465 ms stddev 0.789
progress: 162.0 s, 3200.7 tps, lat 2.499 ms stddev 0.769
progress: 168.0 s, 3119.2 tps, lat 2.564 ms stddev 0.800
progress: 174.0 s, 3146.7 tps, lat 2.542 ms stddev 0.795
progress: 180.0 s, 3089.3 tps, lat 2.589 ms stddev 0.899
progress: 186.0 s, 3159.5 tps, lat 2.531 ms stddev 0.759
progress: 192.0 s, 3145.7 tps, lat 2.543 ms stddev 0.811
progress: 198.0 s, 3071.0 tps, lat 2.605 ms stddev 0.769
progress: 204.0 s, 3265.3 tps, lat 2.449 ms stddev 0.812
progress: 210.0 s, 3161.2 tps, lat 2.530 ms stddev 0.768
progress: 216.0 s, 3166.7 tps, lat 2.524 ms stddev 0.749
progress: 222.0 s, 3162.7 tps, lat 2.530 ms stddev 0.808
progress: 228.0 s, 3113.5 tps, lat 2.569 ms stddev 0.789
progress: 234.0 s, 3228.2 tps, lat 2.478 ms stddev 0.820
progress: 240.0 s, 3163.5 tps, lat 2.528 ms stddev 0.921
progress: 246.0 s, 3154.7 tps, lat 2.535 ms stddev 0.783
progress: 252.0 s, 3224.0 tps, lat 2.481 ms stddev 0.785
progress: 258.0 s, 3139.0 tps, lat 2.548 ms stddev 0.773
progress: 264.0 s, 3238.7 tps, lat 2.470 ms stddev 0.739
progress: 270.0 s, 3224.2 tps, lat 2.481 ms stddev 0.831
progress: 276.0 s, 3057.0 tps, lat 2.616 ms stddev 0.823
progress: 282.0 s, 3176.5 tps, lat 2.518 ms stddev 0.841
progress: 288.0 s, 3195.7 tps, lat 2.503 ms stddev 0.757
progress: 294.0 s, 3132.0 tps, lat 2.554 ms stddev 0.881
progress: 300.0 s, 3173.0 tps, lat 2.521 ms stddev 0.806
progress: 306.0 s, 3071.7 tps, lat 2.604 ms stddev 0.838
progress: 312.0 s, 3165.2 tps, lat 2.527 ms stddev 0.823
progress: 318.0 s, 3125.1 tps, lat 2.559 ms stddev 0.774
progress: 324.0 s, 3147.0 tps, lat 2.541 ms stddev 0.803
progress: 330.0 s, 3156.8 tps, lat 2.534 ms stddev 0.781
progress: 336.0 s, 3077.0 tps, lat 2.599 ms stddev 0.895
progress: 342.0 s, 3179.3 tps, lat 2.515 ms stddev 0.734
progress: 348.0 s, 3065.1 tps, lat 2.610 ms stddev 0.789
progress: 354.0 s, 3189.7 tps, lat 2.508 ms stddev 0.914
progress: 360.0 s, 3180.8 tps, lat 2.515 ms stddev 0.850
progress: 366.0 s, 3164.7 tps, lat 2.527 ms stddev 0.860
progress: 372.0 s, 3249.7 tps, lat 2.461 ms stddev 0.808
progress: 378.0 s, 3172.0 tps, lat 2.521 ms stddev 0.750
progress: 384.0 s, 3224.3 tps, lat 2.481 ms stddev 0.780
progress: 390.0 s, 3175.5 tps, lat 2.519 ms stddev 0.807
progress: 396.0 s, 3215.7 tps, lat 2.487 ms stddev 0.792
progress: 402.0 s, 3248.9 tps, lat 2.462 ms stddev 0.787
progress: 408.0 s, 3195.3 tps, lat 2.503 ms stddev 0.777
progress: 414.0 s, 3212.8 tps, lat 2.490 ms stddev 0.923
progress: 420.0 s, 3243.3 tps, lat 2.466 ms stddev 0.767
progress: 426.0 s, 3084.5 tps, lat 2.593 ms stddev 0.837
progress: 432.0 s, 3158.5 tps, lat 2.532 ms stddev 0.837
progress: 438.0 s, 3178.5 tps, lat 2.516 ms stddev 0.849
progress: 444.0 s, 3185.2 tps, lat 2.511 ms stddev 0.812
progress: 450.0 s, 3126.7 tps, lat 2.558 ms stddev 0.812
progress: 456.0 s, 3116.5 tps, lat 2.566 ms stddev 0.780
progress: 462.0 s, 3242.2 tps, lat 2.467 ms stddev 1.006
progress: 468.0 s, 3163.0 tps, lat 2.529 ms stddev 0.762
progress: 474.0 s, 3198.0 tps, lat 2.501 ms stddev 0.941
progress: 480.0 s, 3011.7 tps, lat 2.656 ms stddev 0.923
progress: 486.0 s, 3094.3 tps, lat 2.585 ms stddev 0.747
progress: 492.0 s, 3181.0 tps, lat 2.515 ms stddev 0.786
progress: 498.0 s, 3047.2 tps, lat 2.625 ms stddev 0.830
progress: 504.0 s, 3198.0 tps, lat 2.501 ms stddev 0.782
progress: 510.0 s, 3074.7 tps, lat 2.602 ms stddev 0.805
progress: 516.0 s, 3055.8 tps, lat 2.617 ms stddev 0.792
progress: 522.0 s, 3136.3 tps, lat 2.550 ms stddev 0.855
progress: 528.0 s, 3112.0 tps, lat 2.570 ms stddev 0.748
progress: 534.0 s, 3113.8 tps, lat 2.569 ms stddev 0.834
progress: 540.0 s, 3144.0 tps, lat 2.544 ms stddev 2.740
progress: 546.0 s, 3163.5 tps, lat 2.528 ms stddev 0.996
progress: 552.0 s, 3202.2 tps, lat 2.498 ms stddev 0.799
progress: 558.0 s, 3186.0 tps, lat 2.511 ms stddev 0.799
progress: 564.0 s, 3089.7 tps, lat 2.589 ms stddev 0.777
progress: 570.0 s, 3174.8 tps, lat 2.519 ms stddev 0.779
progress: 576.0 s, 3160.3 tps, lat 2.531 ms stddev 0.857
progress: 582.0 s, 3184.5 tps, lat 2.512 ms stddev 0.798
progress: 588.0 s, 3133.2 tps, lat 2.553 ms stddev 0.792
progress: 594.0 s, 3173.7 tps, lat 2.520 ms stddev 0.893
progress: 600.0 s, 3214.8 tps, lat 2.488 ms stddev 0.811
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
duration: 600 s
number of transactions actually processed: 1894959
latency average = 2.532 ms
latency stddev = 0.862 ms
initial connection time = 16.078 ms
tps = 3158.278223 (without initial connection time)
```

Сравниваем результаты нагрузочного тестирования:
<table class='table-1 table-striped-1'>
	<thead>
		<tr><th>Синхронный режим</th><th>Асинхронный режим</th></tr>
	</thead>
	<tbody>
		<tr><td>transaction type: &lt;builtin: TPC-B (sort of)&gt;</td><td>transaction type: &lt;builtin: TPC-B (sort of)&gt;</td></tr>
		<tr><td>scaling factor: 1</td><td>scaling factor: 1</td></tr>
		<tr><td>query mode: simple</td><td>query mode: simple</td></tr>
		<tr><td>number of clients: 8</td><td>number of clients: 8</td></tr>
		<tr><td>number of threads: 1</td><td>number of threads: 1</td></tr>
		<tr><td>duration: 600 s</td><td>duration: 600 s</td></tr>
		<tr><td>number of transactions actually processed: 248971</td><td>number of transactions actually processed: 1894959</td></tr>
		<tr><td>latency average = 19.279 ms</td><td>latency average = 2.532 ms</td></tr>
		<tr><td>latency stddev = 17.958 ms</td><td>latency stddev = 0.862 ms</td></tr>
		<tr><td>initial connection time = 16.021 ms</td><td>initial connection time = 16.078 ms</td></tr>
		<tr><td>tps = 414.922854 (without initial connection time)</td><td>tps = 3158.278223 (without initial connection time)</td></tr>
	</tbody>
</table>

При асинхронном режиме получаем значительный прирост производительности - 3158 транзакций в секунду против 415 транзакций в секунду при синхронном режиме. В асинхронном режиме сервер при фиксации транзакции сообщает об успешном завершении операции не дожидаясь сохранения записей из WAL на диск, что и даёт увеличение производительности, но снижает надёжность.

**6.** - Создаём новый кластер _second_ с включённой контрольной суммой страниц:
```
postgres@vmotus09:/home/devops$ exit

devops@vmotus09:~$ sudo pg_createcluster 14 second -- --data-checksums
Creating new PostgreSQL cluster 14/second ...
/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/second --auth-local peer --auth-host scram-sha-256 --no-instructions --data-checksums
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are enabled.

fixing permissions on existing directory /var/lib/postgresql/14/second ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... Etc/UTC
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok
Ver Cluster Port Status Owner    Data directory                Log file
14  second  5433 down   postgres /var/lib/postgresql/14/second /var/log/postgresql/postgresql-14-second.log
```

Кластер создан на 5433 порте. Запускаем калстер _second_. Проверяем:
```
devops@vmotus09:~$ sudo pg_lsclusters
Ver Cluster Port Status Owner    Data directory                Log file
14  main    5432 online postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
14  second  5433 down   postgres /var/lib/postgresql/14/second /var/log/postgresql/postgresql-14-second.log
```

Подключаемся к кластеру _second_, проверяем настройки:
```
devops@vmotus09:~$ sudo pg_ctlcluster 14 second start

devops@vmotus09:~$ sudo pg_lsclusters
Ver Cluster Port Status Owner    Data directory                Log file
14  main    5432 online postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
14  second  5433 online postgres /var/lib/postgresql/14/second /var/log/postgresql/postgresql-14-second.log

devops@vmotus09:~$ sudo -u postgres psql -p5433
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# select setting from pg_settings where name='port';
 setting
---------
 5433
(1 row)

postgres=# select setting from pg_settings where name='data_checksums';
 setting
---------
 on
(1 row)
```

Cоздаём базу данных _checksum_, создаём и заполняем таблицу _test_:
```
postgres=# create database checksum;
CREATE DATABASE

postgres=# \c checksum;
You are now connected to database "checksum" as user "postgres".

checksum=# create table test (id int);
CREATE TABLE

checksum=# insert into test select* from generate_series(1, 100);
INSERT 0 100
```

Определяем файл, в котором хранится таблица _test_:
```
checksum=# select pg_relation_filepath('test');
 pg_relation_filepath
----------------------
 base/16384/16388
(1 row)
```

Отключаем кластер _second_ и вносим злонамеренные изменения в файл таблицы _test_:
```
checksum=# \q

devops@vmotus09:~$ sudo pg_ctlcluster 14 second stop

devops@vmotus09:~$ sudo pg_lsclusters
Ver Cluster Port Status Owner    Data directory                Log file
14  main    5432 online postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
14  second  5433 down   postgres /var/lib/postgresql/14/second /var/log/postgresql/postgresql-14-second.log
```

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/918f1d91-7213-4e6c-80df-1fb56b7ba883)


Включаем кластер _second_:
```
devops@vmotus09:~$ sudo pg_ctlcluster 14 second start
devops@vmotus09:~$ sudo pg_lsclusters
Ver Cluster Port Status Owner    Data directory                Log file
14  main    5432 online postgres /var/lib/postgresql/14/main   /var/log/postgresql/postgresql-14-main.log
14  second  5433 online postgres /var/lib/postgresql/14/second /var/log/postgresql/postgresql-14-second.log
```

Подключаемся к базе данных _checksum_ и делаем выборку данных из таблицы _test_:
```
devops@vmotus09:~$ sudo -u postgres psql -p5433
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c checksum
You are now connected to database "checksum" as user "postgres".

checksum=# select* from test limit 10;
WARNING:  page verification failed, calculated checksum 61808 but expected 54529
ERROR:  invalid page in block 0 of relation base/16384/16388
```

В результате получаем ошибку верификации контрольной суммы, т.к. наша вероломно добавленная в начало файла единица не оталась незамеченной.
Включаем игнорирование контрольной суммы:
```
checksum=# alter system set ignore_checksum_failure=on;
ALTER SYSTEM

checksum=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
```

Повторяем попытку выборки данных из таблицы _test_:
```
checksum=# select* from test limit 10;
 id
----
  1
  2
  3
  4
  5
  6
  7
  8
  9
 13
(10 rows)
```

Повреждения файла позволили прочитать данные, но корректность данных требует проверки. 


<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
