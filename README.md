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
progress: 6.0 s, 419.3 tps, lat 19.010 ms stddev 20.208
progress: 12.0 s, 335.3 tps, lat 23.857 ms stddev 28.299
progress: 18.0 s, 402.2 tps, lat 19.867 ms stddev 21.288
progress: 24.0 s, 359.8 tps, lat 22.207 ms stddev 21.614
progress: 30.0 s, 384.2 tps, lat 20.861 ms stddev 21.563
progress: 36.0 s, 373.7 tps, lat 21.410 ms stddev 36.087
progress: 42.0 s, 311.2 tps, lat 25.719 ms stddev 27.965
progress: 48.0 s, 476.5 tps, lat 16.767 ms stddev 18.754
progress: 54.0 s, 437.2 tps, lat 18.247 ms stddev 20.699
progress: 60.0 s, 357.3 tps, lat 22.421 ms stddev 37.798
progress: 66.0 s, 372.5 tps, lat 21.315 ms stddev 28.786
progress: 72.0 s, 330.5 tps, lat 24.451 ms stddev 30.293
progress: 78.0 s, 385.0 tps, lat 20.768 ms stddev 20.510
progress: 84.0 s, 405.3 tps, lat 19.734 ms stddev 20.771
progress: 90.0 s, 357.0 tps, lat 22.391 ms stddev 30.522
progress: 96.0 s, 335.5 tps, lat 23.844 ms stddev 32.816
progress: 102.0 s, 272.7 tps, lat 29.338 ms stddev 39.050
progress: 108.0 s, 359.2 tps, lat 22.301 ms stddev 22.525
progress: 114.0 s, 365.7 tps, lat 21.781 ms stddev 23.198
progress: 120.0 s, 287.2 tps, lat 27.986 ms stddev 36.837
progress: 126.0 s, 289.3 tps, lat 27.587 ms stddev 24.036
progress: 132.0 s, 261.2 tps, lat 30.405 ms stddev 35.698
progress: 138.0 s, 363.7 tps, lat 22.201 ms stddev 22.784
progress: 144.0 s, 344.5 tps, lat 23.189 ms stddev 23.568
progress: 150.0 s, 354.2 tps, lat 22.637 ms stddev 22.686
progress: 156.0 s, 314.2 tps, lat 25.333 ms stddev 34.358
progress: 162.0 s, 273.7 tps, lat 29.361 ms stddev 43.229
progress: 168.0 s, 316.8 tps, lat 25.246 ms stddev 23.389
progress: 174.0 s, 333.8 tps, lat 23.859 ms stddev 23.641
progress: 180.0 s, 406.8 tps, lat 19.763 ms stddev 20.419
progress: 186.0 s, 381.2 tps, lat 20.766 ms stddev 31.924
progress: 192.0 s, 304.8 tps, lat 26.424 ms stddev 37.580
progress: 198.0 s, 318.0 tps, lat 25.132 ms stddev 25.379
progress: 204.0 s, 391.8 tps, lat 20.336 ms stddev 21.535
progress: 210.0 s, 369.0 tps, lat 21.866 ms stddev 21.609
progress: 216.0 s, 351.8 tps, lat 22.724 ms stddev 36.086
progress: 222.0 s, 269.5 tps, lat 29.696 ms stddev 39.193
progress: 228.0 s, 397.3 tps, lat 20.133 ms stddev 21.821
progress: 234.0 s, 390.7 tps, lat 20.439 ms stddev 22.298
progress: 240.0 s, 382.0 tps, lat 20.952 ms stddev 20.992
progress: 246.0 s, 363.7 tps, lat 22.033 ms stddev 36.186
progress: 252.0 s, 329.0 tps, lat 24.305 ms stddev 25.440
progress: 258.0 s, 364.0 tps, lat 21.774 ms stddev 34.098
progress: 264.0 s, 375.3 tps, lat 21.451 ms stddev 21.529
progress: 270.0 s, 353.8 tps, lat 22.680 ms stddev 32.216
progress: 276.0 s, 413.5 tps, lat 19.349 ms stddev 21.008
progress: 282.0 s, 220.2 tps, lat 36.322 ms stddev 38.840
progress: 288.0 s, 315.2 tps, lat 25.241 ms stddev 35.007
progress: 294.0 s, 234.3 tps, lat 34.082 ms stddev 29.060
progress: 300.0 s, 227.7 tps, lat 35.336 ms stddev 37.543
progress: 306.0 s, 226.5 tps, lat 35.283 ms stddev 25.757
progress: 312.0 s, 234.2 tps, lat 33.900 ms stddev 37.368
progress: 318.0 s, 361.3 tps, lat 22.370 ms stddev 29.179
progress: 324.0 s, 342.3 tps, lat 23.287 ms stddev 22.908
progress: 330.0 s, 401.7 tps, lat 19.991 ms stddev 20.426
progress: 336.0 s, 397.7 tps, lat 20.049 ms stddev 31.282
progress: 342.0 s, 299.8 tps, lat 26.762 ms stddev 30.604
progress: 348.0 s, 374.8 tps, lat 21.350 ms stddev 33.469
progress: 354.0 s, 365.8 tps, lat 21.371 ms stddev 25.596
progress: 360.0 s, 366.7 tps, lat 22.311 ms stddev 26.762
progress: 366.0 s, 397.3 tps, lat 20.136 ms stddev 31.382
progress: 372.0 s, 316.3 tps, lat 25.229 ms stddev 25.320
progress: 378.0 s, 275.3 tps, lat 29.096 ms stddev 37.300
progress: 384.0 s, 309.3 tps, lat 25.723 ms stddev 23.690
progress: 390.0 s, 368.0 tps, lat 21.005 ms stddev 24.011
progress: 396.0 s, 368.8 tps, lat 22.552 ms stddev 29.995
progress: 402.0 s, 270.5 tps, lat 29.390 ms stddev 32.257
progress: 408.0 s, 343.8 tps, lat 23.409 ms stddev 24.368
progress: 414.0 s, 353.0 tps, lat 22.548 ms stddev 34.447
progress: 420.0 s, 341.3 tps, lat 23.411 ms stddev 36.226
progress: 426.0 s, 431.7 tps, lat 18.619 ms stddev 20.494
progress: 432.0 s, 370.7 tps, lat 21.586 ms stddev 28.281
progress: 438.0 s, 436.5 tps, lat 18.354 ms stddev 19.014
progress: 444.0 s, 327.8 tps, lat 24.319 ms stddev 35.367
progress: 450.0 s, 274.8 tps, lat 28.066 ms stddev 27.360
progress: 456.0 s, 398.0 tps, lat 20.883 ms stddev 30.625
progress: 462.0 s, 301.8 tps, lat 26.446 ms stddev 29.318
progress: 468.0 s, 414.2 tps, lat 19.200 ms stddev 20.768
progress: 474.0 s, 372.3 tps, lat 21.518 ms stddev 34.399
progress: 480.0 s, 358.8 tps, lat 21.481 ms stddev 23.864
progress: 486.0 s, 416.3 tps, lat 20.036 ms stddev 28.985
progress: 492.0 s, 321.3 tps, lat 24.798 ms stddev 32.611
progress: 498.0 s, 422.8 tps, lat 19.002 ms stddev 21.303
progress: 504.0 s, 366.8 tps, lat 21.693 ms stddev 34.207
progress: 510.0 s, 360.0 tps, lat 22.332 ms stddev 29.559
progress: 516.0 s, 415.2 tps, lat 19.270 ms stddev 20.056
progress: 522.0 s, 290.5 tps, lat 27.540 ms stddev 28.357
progress: 528.0 s, 310.2 tps, lat 25.781 ms stddev 23.837
progress: 534.0 s, 304.7 tps, lat 26.140 ms stddev 34.126
progress: 540.0 s, 300.7 tps, lat 26.741 ms stddev 34.552
progress: 546.0 s, 401.8 tps, lat 19.902 ms stddev 20.860
progress: 552.0 s, 337.8 tps, lat 23.591 ms stddev 30.783
progress: 558.0 s, 403.5 tps, lat 19.913 ms stddev 21.111
progress: 564.0 s, 365.7 tps, lat 21.801 ms stddev 21.421
progress: 570.0 s, 361.3 tps, lat 22.206 ms stddev 42.010
progress: 576.0 s, 386.5 tps, lat 20.698 ms stddev 21.010
progress: 582.0 s, 273.3 tps, lat 29.056 ms stddev 30.918
progress: 588.0 s, 432.8 tps, lat 18.610 ms stddev 19.958
progress: 594.0 s, 419.2 tps, lat 18.893 ms stddev 21.170
progress: 600.0 s, 346.5 tps, lat 23.172 ms stddev 41.429
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 8
number of threads: 1
duration: 600 s
number of transactions actually processed: 209867
latency average = 22.871 ms
latency stddev = 28.532 ms
tps = 349.765637 (including connections establishing)
tps = 349.766734 (excluding connections establishing)
```




<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
