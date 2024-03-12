## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 11 "Настройка PostgreSQL"

### Домашнее задание
Нагрузочное тестирование и тюнинг PostgreSQL

### Исходные данные
ВМ (облако): 2 ядра, 2Гб, HDD 10Гб, Ubuntu 22.04, PostgreSQL 14

### Решение

**1.** - Настроим сервер PostgreSQL на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины.

Увеличим память, буферы и включим асинхронный режим записи на диск журнала предзаписи. Увеличивать min_wal_size и max_wal_size при заданных характеристиках ВМ не имеет смысла:
```
devops@vmotus11:~$ sudo -u postgres psql
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

postgres=# alter system set synchronous_commit=off;
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
postgres=# \q

devops@vmotus11:~$ sudo systemctl restart postgresql 

devops@vmotus11:~$ sudo su postgres
```

**2.** - Проведём нагрузочное тестирование.

Cоздаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
postgres@vmotus11:/home/devops$ pgbench -i postgres
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
done in 0.88 s (drop tables 0.00 s, create tables 0.00 s, client-side generate 0.54 s, vacuum 0.04 s, primary keys 0.29 s).
```

Запускаем тест на 10 минут:
```
postgres@vmotus11:/home/devops$ pgbench -c50 -j 2 -P 10 -T 600 -U postgres postgres
pgbench (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
starting vacuum...end.
progress: 10.0 s, 2796.7 tps, lat 17.747 ms stddev 13.815
progress: 20.0 s, 2633.4 tps, lat 18.980 ms stddev 14.570
progress: 30.0 s, 2590.7 tps, lat 19.309 ms stddev 13.805
progress: 40.0 s, 2470.2 tps, lat 20.243 ms stddev 12.278
progress: 50.0 s, 2603.2 tps, lat 19.200 ms stddev 15.238
progress: 60.0 s, 2587.0 tps, lat 19.334 ms stddev 14.618
progress: 70.0 s, 2574.1 tps, lat 19.419 ms stddev 14.021
progress: 80.0 s, 2556.7 tps, lat 19.557 ms stddev 13.063
progress: 90.0 s, 2483.5 tps, lat 20.130 ms stddev 12.693
progress: 100.0 s, 2450.5 tps, lat 20.402 ms stddev 11.902
progress: 110.0 s, 2455.2 tps, lat 20.366 ms stddev 11.968
progress: 120.0 s, 2452.9 tps, lat 20.381 ms stddev 13.368
progress: 130.0 s, 2457.7 tps, lat 20.342 ms stddev 12.605
progress: 140.0 s, 2417.1 tps, lat 20.690 ms stddev 12.686
progress: 150.0 s, 2459.1 tps, lat 20.326 ms stddev 13.332
progress: 160.0 s, 2405.1 tps, lat 20.794 ms stddev 11.768
progress: 170.0 s, 2795.8 tps, lat 17.885 ms stddev 15.983
progress: 180.0 s, 2546.0 tps, lat 19.635 ms stddev 13.400
progress: 190.0 s, 2480.5 tps, lat 20.148 ms stddev 14.136
progress: 200.0 s, 2456.0 tps, lat 20.364 ms stddev 13.776
progress: 210.0 s, 2446.7 tps, lat 20.440 ms stddev 12.796
progress: 220.0 s, 2395.5 tps, lat 20.874 ms stddev 11.865
progress: 230.0 s, 2604.7 tps, lat 19.193 ms stddev 13.018
progress: 240.0 s, 2572.6 tps, lat 19.428 ms stddev 15.136
progress: 250.0 s, 2442.6 tps, lat 20.479 ms stddev 13.109
progress: 260.0 s, 2455.0 tps, lat 20.363 ms stddev 13.689
progress: 270.0 s, 2379.8 tps, lat 21.014 ms stddev 12.489
progress: 280.0 s, 2546.0 tps, lat 19.634 ms stddev 13.775
progress: 290.0 s, 2799.7 tps, lat 17.861 ms stddev 13.979
progress: 300.0 s, 2640.1 tps, lat 18.939 ms stddev 15.106
progress: 310.0 s, 2420.0 tps, lat 20.658 ms stddev 12.794
progress: 320.0 s, 2385.3 tps, lat 20.946 ms stddev 13.169
progress: 330.0 s, 2542.9 tps, lat 19.675 ms stddev 12.731
progress: 340.0 s, 2542.8 tps, lat 19.662 ms stddev 13.317
progress: 350.0 s, 2608.2 tps, lat 19.173 ms stddev 13.627
progress: 360.0 s, 2587.6 tps, lat 19.321 ms stddev 14.572
progress: 370.0 s, 2567.5 tps, lat 19.472 ms stddev 13.239
progress: 380.0 s, 2473.1 tps, lat 20.221 ms stddev 12.459
progress: 390.0 s, 2410.0 tps, lat 20.745 ms stddev 12.093
progress: 400.0 s, 2499.8 tps, lat 19.999 ms stddev 11.711
progress: 410.0 s, 2440.0 tps, lat 20.485 ms stddev 12.779
progress: 420.0 s, 2507.1 tps, lat 19.950 ms stddev 15.130
progress: 430.0 s, 2654.1 tps, lat 18.835 ms stddev 15.466
progress: 440.0 s, 2582.2 tps, lat 19.358 ms stddev 15.457
progress: 450.0 s, 2412.9 tps, lat 20.730 ms stddev 12.821
progress: 460.0 s, 2462.7 tps, lat 20.295 ms stddev 12.998
progress: 470.0 s, 2671.8 tps, lat 18.721 ms stddev 17.024
progress: 480.0 s, 2598.6 tps, lat 19.236 ms stddev 13.824
progress: 490.0 s, 2545.3 tps, lat 19.648 ms stddev 14.344
progress: 500.0 s, 2503.2 tps, lat 19.976 ms stddev 12.477
progress: 510.0 s, 2489.2 tps, lat 20.079 ms stddev 12.626
progress: 520.0 s, 2557.7 tps, lat 19.549 ms stddev 12.219
progress: 530.0 s, 2637.9 tps, lat 18.949 ms stddev 14.275
progress: 540.0 s, 2694.3 tps, lat 18.554 ms stddev 15.253
progress: 550.0 s, 2634.8 tps, lat 18.971 ms stddev 14.522
progress: 560.0 s, 2690.8 tps, lat 18.595 ms stddev 14.826
progress: 570.0 s, 2489.9 tps, lat 20.073 ms stddev 12.751
progress: 580.0 s, 2645.6 tps, lat 18.896 ms stddev 13.976
progress: 590.0 s, 2574.7 tps, lat 19.422 ms stddev 12.934
progress: 600.0 s, 2548.1 tps, lat 19.623 ms stddev 13.896
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 1
query mode: simple
number of clients: 50
number of threads: 2
duration: 600 s
number of transactions actually processed: 1523372
latency average = 19.692 ms
latency stddev = 13.662 ms
initial connection time = 58.424 ms
tps = 2538.719898 (without initial connection time)
```

Выбранные параметры позволили достичь производительности 2538 транзакций в секунду.





<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
