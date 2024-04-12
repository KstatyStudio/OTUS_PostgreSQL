## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 18 "Сбор и использование статистики"

### Домашнее задание
Работа с join'ами, статистикой

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 15,  
база данных _demo_ (https://edu.postgrespro.ru/demo-small.zip), разархивированный скрипт (https://github.com/KstatyStudio/OTUS_PostgreSQL/blob/hw18/demo-small-20170815.sql)

**Схема базы данных _demo_:**

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/3d6c1854-bb3b-47b4-a2f6-16bc6d971650)
  
Подробно структура и содержание таблиц приведены в конце отчёта.  

### Решение  

**1. - Прямое соединение двух или более таблиц**  
Выведем расписание вылетов из аэропорта _Внуково_ на 25 августа 2017 года с указанием аэропортов назначения:
```
demo=# select f.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport||' '||dep.airport_name as "departure", scheduled_arrival, f.arrival_airport||' '||arr.airport_name as "arrival" from flights f join airports_data dep on f.departure_airport=dep.airport_code join airports_data arr on f.arrival_airport=arr.airport_code where f.departure_airport='VKO' and f.scheduled_departure::date='2017-08-25' limit 10;
 flight_id | flight_no |  scheduled_departure   |                          departure                           |   scheduled_arrival    |                            arrival
-----------+-----------+------------------------+--------------------------------------------------------------+------------------------+---------------------------------------------------------------
      3979 | PG0052    | 2017-08-25 11:50:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 14:35:00+00 | HMA {"en": "Khanty Mansiysk Airport", "ru": "Ханты-Мансийск"}
      3285 | PG0229    | 2017-08-25 08:50:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 09:40:00+00 | LED {"en": "Pulkovo Airport", "ru": "Пулково"}
      3294 | PG0228    | 2017-08-25 08:25:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 09:15:00+00 | LED {"en": "Pulkovo Airport", "ru": "Пулково"}
      3298 | PG0227    | 2017-08-25 06:45:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 07:35:00+00 | LED {"en": "Pulkovo Airport", "ru": "Пулково"}
      3425 | PG0671    | 2017-08-25 10:05:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 13:20:00+00 | OMS {"en": "Omsk Central Airport", "ru": "Омск-Центральный"}
      3505 | PG0412    | 2017-08-25 08:00:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 09:25:00+00 | PEE {"en": "Bolshoye Savino Airport", "ru": "Пермь"}
      3534 | PG0396    | 2017-08-25 13:20:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 14:30:00+00 | VOG {"en": "Volgograd International Airport", "ru": "Гумрак"}
      3601 | PG0414    | 2017-08-25 06:05:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 08:10:00+00 | MMK {"en": "Murmansk Airport", "ru": "Мурманск"}
      3661 | PG0050    | 2017-08-25 11:20:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 12:20:00+00 | PES {"en": "Petrozavodsk Airport", "ru": "Бесовец"}
      3795 | PG0008    | 2017-08-25 08:45:00+00 | VKO {"en": "Vnukovo International Airport", "ru": "Внуково"} | 2017-08-25 10:55:00+00 | JOK {"en": "Yoshkar-Ola Airport", "ru": "Йошкар-Ола"}
(10 rows)
```
Результат содержит объединение столбцов из трёх таблиц - _flights_ и два экземпляра _airports_data_, для которых найдено соответствие по столбцам _departure_airport/arrival_airport, airport_code_ и значение этих столбцов равно _'VKO'_ (соответствует услолвию). Вывод ограничен 10 строками и перечнем столбцов.  

План запроса:  
```
demo=# explain select f.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport||' '||dep.airport_name as "departure", scheduled_arrival, f.arrival_airport||' '||arr.airport_name as "arrival" from flights f join airports_data dep on f.departure_airport=dep.airport_code join airports_data arr on f.arrival_airport=arr.airport_code where f.departure_airport='VKO' and f.scheduled_departure::date='2017-08-25' limit 10;
                                                        QUERY PLAN
--------------------------------------------------------------------------------------------------------------------------
 Limit  (cost=5.34..981.60 rows=9 width=91)
   ->  Hash Join  (cost=5.34..981.60 rows=9 width=91)
         Hash Cond: (f.arrival_airport = arr.airport_code)
         ->  Nested Loop  (cost=0.00..976.01 rows=9 width=96)
               ->  Seq Scan on airports_data dep  (cost=0.00..4.30 rows=1 width=65)
                     Filter: (airport_code = 'VKO'::bpchar)
               ->  Seq Scan on flights f  (cost=0.00..971.62 rows=9 width=35)
                     Filter: ((departure_airport = 'VKO'::bpchar) AND ((scheduled_departure)::date = '2017-08-25'::date))
         ->  Hash  (cost=4.04..4.04 rows=104 width=65)
               ->  Seq Scan on airports_data arr  (cost=0.00..4.04 rows=104 width=65)
(10 rows)
```

Статистика:
```
demo=# select* from pg_stat_statements where query like '%select f.flight_id%' \gx

-[ RECORD 1 ]----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
userid                 | 10
dbid                   | 16388
toplevel               | t
queryid                | 2662642071027588672
query                  | explain select f.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport||' '||dep.airport_name as "departure", scheduled_arrival, f.arrival_airport||' '||arr.airport_name as "arrival" from flights f join airports_data dep on f.departure_airport=dep.airport_code join airports_data arr on f.arrival_airport=arr.airport_code where f.departure_airport='VKO' and f.scheduled_departure::date='2017-08-25' limit 10
plans                  | 0
total_plan_time        | 0
min_plan_time          | 0
max_plan_time          | 0
mean_plan_time         | 0
stddev_plan_time       | 0
calls                  | 1
total_exec_time        | 38.443162
min_exec_time          | 38.443162
max_exec_time          | 38.443162
mean_exec_time         | 38.443162
stddev_exec_time       | 0
rows                   | 0
shared_blks_hit        | 4
shared_blks_read       | 0
shared_blks_dirtied    | 0
shared_blks_written    | 0
local_blks_hit         | 0
local_blks_read        | 0
local_blks_dirtied     | 0
local_blks_written     | 0
temp_blks_read         | 0
temp_blks_written      | 0
blk_read_time          | 0
blk_write_time         | 0
temp_blk_read_time     | 0
temp_blk_write_time    | 0
wal_records            | 0
wal_fpi                | 0
wal_bytes              | 0
jit_functions          | 0
jit_generation_time    | 0
jit_inlining_count     | 0
jit_inlining_time      | 0
jit_optimization_count | 0
jit_optimization_time  | 0
jit_emission_count     | 0
jit_emission_time      | 0
```
```
-[ RECORD 2 ]----------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
userid                 | 10
dbid                   | 16388
toplevel               | t
queryid                | -7265423808759686202
query                  | select f.flight_id, f.flight_no, f.scheduled_departure, f.departure_airport||$1||dep.airport_name as "departure", scheduled_arrival, f.arrival_airport||$2||arr.airport_name as "arrival" from flights f join airports_data dep on f.departure_airport=dep.airport_code join airports_data arr on f.arrival_airport=arr.airport_code where f.departure_airport=$3 and f.scheduled_departure::date=$4 limit $5
plans                  | 0
total_plan_time        | 0
min_plan_time          | 0
max_plan_time          | 0
mean_plan_time         | 0
stddev_plan_time       | 0
calls                  | 2
total_exec_time        | 320.58299400000004
min_exec_time          | 0.5183190000000001
max_exec_time          | 320.064675
mean_exec_time         | 160.29149700000002
stddev_exec_time       | 159.773178
rows                   | 20
shared_blks_hit        | 53
shared_blks_read       | 47
shared_blks_dirtied    | 0
shared_blks_written    | 0
local_blks_hit         | 0
local_blks_read        | 0
local_blks_dirtied     | 0
local_blks_written     | 0
temp_blks_read         | 0
temp_blks_written      | 0
blk_read_time          | 0
blk_write_time         | 0
temp_blk_read_time     | 0
temp_blk_write_time    | 0
wal_records            | 0
wal_fpi                | 0
wal_bytes              | 0
jit_functions          | 0
jit_generation_time    | 0
jit_inlining_count     | 0
jit_inlining_time      | 0
jit_optimization_count | 0
jit_optimization_time  | 0
jit_emission_count     | 0
jit_emission_time      | 0
```
  
**2. - Левостороннее (или правостороннее) соединение двух или более таблиц**  
Выведем список типов самолётов и посмотрим сколько раз каждый тип самолёта вылетал из аэропорта _Владивосток_:
```
demo=# select a.aircraft_code, a.model, a.range, count(flight_id) from aircrafts_data a left join flights f on a.aircraft_code=f.aircraft_code and f.departure_airport='VVO' group by a.aircraft_code;
 aircraft_code |                           model                            | range | count
---------------+------------------------------------------------------------+-------+-------
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"}        |  6700 |     0
 320           | {"en": "Airbus A320-200", "ru": "Аэробус A320-200"}        |  5700 |     0
 321           | {"en": "Airbus A321-200", "ru": "Аэробус A321-200"}        |  5600 |     0
 733           | {"en": "Boeing 737-300", "ru": "Боинг 737-300"}            |  4200 |     0
 763           | {"en": "Boeing 767-300", "ru": "Боинг 767-300"}            |  7900 |    61
 773           | {"en": "Boeing 777-300", "ru": "Боинг 777-300"}            | 11100 |     0
 CN1           | {"en": "Cessna 208 Caravan", "ru": "Сессна 208 Караван"}   |  1200 |     0
 CR2           | {"en": "Bombardier CRJ-200", "ru": "Бомбардье CRJ-200"}    |  2700 |    61
 SU9           | {"en": "Sukhoi Superjet-100", "ru": "Сухой Суперджет-100"} |  3000 |    61
(9 rows)
```
В результате мы видим, что из аэропорта _Владивосток_ вылетали только три типа самолётов, а для остальных типов самолётов соответствий в таблице _flights_ не найдены. Так например, запрос без ограничения списка столбцов для самолёта _Аэробус A319-100_ выдаёт строку с незаполненными столбцами из таблицы _flights_:
```
demo=# select * from aircrafts_data a left join flights f on a.aircraft_code=f.aircraft_code and f.departure_airport='VVO' where a.aircraft_code='319';
 aircraft_code |                        model                        | range | flight_id | flight_no | scheduled_departure | scheduled_arrival | departure_airport | arrival_airport | status | aircraft_code | actual_departure | actual_arrival
---------------+-----------------------------------------------------+-------+-----------+-----------+---------------------+-------------------+-------------------+-----------------+--------+---------------+------------------+----------------
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 |           |           |                     |                   |                   |                 |        |               |                  |
(1 row)
```

**3. - Кросс соединение двух или более таблиц**  
Выведем перечень всех возможный вариантов прямых перелётов между двумя аэропортами: 
```
demo=# select dep.airport_code as "departure.code", dep.airport_name as "departure.name", dep.coordinates as "departure.coordinates", arr.airport_code as "arrival.code", arr.airport_name as "arrival.name", arr.coordinates as "arrival.coordinates" from airports_data dep cross join airports_data arr limit 10;
 departure.code |              departure.name               |        departure.coordinates         | arrival.code |                           arrival.name                           |           arrival.coordinates
----------------+-------------------------------------------+--------------------------------------+--------------+------------------------------------------------------------------+-----------------------------------------
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | YKS          | {"en": "Yakutsk Airport", "ru": "Якутск"}                        | (129.77099609375,62.093299865722656)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | MJZ          | {"en": "Mirny Airport", "ru": "Мирный"}                          | (114.03900146484375,62.534698486328125)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | KHV          | {"en": "Khabarovsk-Novy Airport", "ru": "Хабаровск-Новый"}       | (135.18800354004,48.52799987793)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | PKC          | {"en": "Yelizovo Airport", "ru": "Елизово"}                      | (158.45399475097656,53.16790008544922)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | UUS          | {"en": "Yuzhno-Sakhalinsk Airport", "ru": "Хомутово"}            | (142.71800231933594,46.88869857788086)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | VVO          | {"en": "Vladivostok International Airport", "ru": "Владивосток"} | (132.1479949951172,43.39899826049805)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | LED          | {"en": "Pulkovo Airport", "ru": "Пулково"}                       | (30.262500762939453,59.80030059814453)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | KGD          | {"en": "Khrabrovo Airport", "ru": "Храброво"}                    | (20.592599868774414,54.88999938964844)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | KEJ          | {"en": "Kemerovo Airport", "ru": "Кемерово"}                     | (86.1072006225586,55.27009963989258)
 YKS            | {"en": "Yakutsk Airport", "ru": "Якутск"} | (129.77099609375,62.093299865722656) | CEK          | {"en": "Chelyabinsk Balandino Airport", "ru": "Челябинск"}       | (61.5033,55.305801)
(10 rows)
```
Результат запроса включает соединение всех строк одного экземпляра таблицы _airports_data_ со всеми строками второго экземпляра этой же таблицы без каких либо условий.

**4. - Полное соединение двух или более таблиц**  
Выведем информацию о местах в самолётах:
```
demo=# select* from aircrafts_data a full join seats s on a.aircraft_code=s.aircraft_code limit 10;
 aircraft_code |                        model                        | range | aircraft_code | seat_no | fare_conditions
---------------+-----------------------------------------------------+-------+---------------+---------+-----------------
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10A     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10B     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10C     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10D     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10E     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 10F     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 11A     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 11B     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 11C     | Economy
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"} |  6700 | 319           | 11D     | Economy
(10 rows)
```
Результат запроса включает все строки из обеих таблиц _aircrafts_data_ и _seats_, соединённые по столбцу _aircraft_code_. Для строк из таблицы _aircrafts_data_ в случае отсутствия соответствующей записи в таблице _seats_ столбцы _s.aircraft_code_, _s.seat_no_ и _s.fare_conditions_ заполняются _null_-значениями. И аналогично для строк из таблицы _seats_ столбцы _a.aircraft_code_, _a.model_ и _a.range_ заполняются _null_-значениями, если для строки не найдено соотвтетсвие в таблице _aircrafts_data_.  

**5. - Запрос, в котором будут использованы разные типы соединений**
Выведем список бронирований (_booking_), билетов (_tickets_) и посадочных талонов (_boarding_passes_). Таблицы _booking_ и _tickets_ будем соединять простым джоином, т.к. нас интересует информация по привязанным к бронированиям билетам. Таблицы _tickets_ и _boarding_passes_ будем соединять левосторонним джоином без учёта дополнительной таблицы _ticket_flights_, т.к. по планируемым полётам могут отсутствовать посадочные талоны и подробная информация о полётах в рамках данного запроса не нужна.
```
demo=# select* from bookings b join tickets t on b.book_ref=t.book_ref left join boarding_passes bp on t.ticket_no=bp.ticket_no limit 20;
 book_ref |       book_date        | total_amount |   ticket_no   | book_ref | passenger_id |   passenger_name    |                                   contact_data                                   |   ticket_no   | flight_id | boarding_no | seat_no
----------+------------------------+--------------+---------------+----------+--------------+---------------------+----------------------------------------------------------------------------------+---------------+-----------+-------------+---------
 06B046   | 2017-07-05 17:19:00+00 |     12400.00 | 0005432000987 | 06B046   | 8149 604011  | VALERIY TIKHONOV    | {"phone": "+70127117011"}                                                        | 0005432000987 |     28935 |          10 | 7A
 06B046   | 2017-07-05 17:19:00+00 |     12400.00 | 0005432000988 | 06B046   | 8499 420203  | EVGENIYA ALEKSEEVA  | {"phone": "+70378089255"}                                                        | 0005432000988 |     28935 |          14 | 10E
 E170C3   | 2017-06-28 22:55:00+00 |     24700.00 | 0005432000989 | E170C3   | 1011 752484  | ARTUR GERASIMOV     | {"phone": "+70760429203"}                                                        | 0005432000989 |     28939 |          27 | 18E
 E170C3   | 2017-06-28 22:55:00+00 |     24700.00 | 0005432000990 | E170C3   | 4849 400049  | ALINA VOLKOVA       | {"email": "volkova.alina_03101973@postgrespro.ru", "phone": "+70582584031"}      | 0005432000990 |     28939 |           2 | 3F
 F313DD   | 2017-07-03 01:37:00+00 |     30900.00 | 0005432000991 | F313DD   | 6615 976589  | MAKSIM ZHUKOV       | {"email": "m-zhukov061972@postgrespro.ru", "phone": "+70149562185"}              | 0005432000991 |     28913 |           1 | 1D
 F313DD   | 2017-07-03 01:37:00+00 |     30900.00 | 0005432000992 | F313DD   | 2021 652719  | NIKOLAY EGOROV      | {"phone": "+70791452932"}                                                        | 0005432000992 |     28913 |           6 | 5F
 F313DD   | 2017-07-03 01:37:00+00 |     30900.00 | 0005432000993 | F313DD   | 0817 363231  | TATYANA KUZNECOVA   | {"email": "kuznecova-t-011961@postgrespro.ru", "phone": "+70400736223"}          | 0005432000993 |     28913 |          24 | 19E
 CCC5CB   | 2017-07-07 00:03:00+00 |     13000.00 | 0005432000994 | CCC5CB   | 2883 989356  | IRINA ANTONOVA      | {"email": "antonova.irina04121972@postgrespro.ru", "phone": "+70844502960"}      | 0005432000994 |     28912 |           8 | 6F
 CCC5CB   | 2017-07-07 00:03:00+00 |     13000.00 | 0005432000995 | CCC5CB   | 3097 995546  | VALENTINA KUZNECOVA | {"email": "kuznecova.valentina10101976@postgrespro.ru", "phone": "+70268080457"} | 0005432000995 |     28912 |          26 | 17A
 1FB1E4   | 2017-07-05 21:08:00+00 |      6200.00 | 0005432000996 | 1FB1E4   | 6866 920231  | POLINA ZHURAVLEVA   | {"phone": "+70639918455"}                                                        | 0005432000996 |     28929 |          13 | 14A
 DE3EA6   | 2017-07-04 18:12:00+00 |      6200.00 | 0005432000997 | DE3EA6   | 6030 369450  | ALEKSANDR TIKHONOV  | {"phone": "+70568350272"}                                                        | 0005432000997 |     28904 |          38 | 19F
 4B75D1   | 2017-07-05 17:49:00+00 |     18500.00 | 0005432000998 | 4B75D1   | 8675 588663  | ILYA POPOV          | {"email": "popov_ilya.1971@postgrespro.ru", "phone": "+70003638926"}             | 0005432000998 |     28904 |           2 | 2C
 9E60AA   | 2017-06-30 16:44:00+00 |      6200.00 | 0005432000999 | 9E60AA   | 0764 728785  | ALEKSANDR KUZNECOV  | {"phone": "+70892601069"}                                                        | 0005432000999 |     28904 |          16 | 8F
 69DAD1   | 2017-07-07 08:46:00+00 |     18600.00 | 0005432001000 | 69DAD1   | 8954 972101  | VSEVOLOD BORISOV    | {"email": "borisov_v_1975@postgrespro.ru", "phone": "+70126208679"}              | 0005432001000 |     28895 |          21 | 11D
 69DAD1   | 2017-07-07 08:46:00+00 |     18600.00 | 0005432001001 | 69DAD1   | 6772 748756  | NATALYA ROMANOVA    | {"email": "n-romanova.1981@postgrespro.ru", "phone": "+70898580864"}             | 0005432001001 |     28895 |          20 | 11A
 69DAD1   | 2017-07-07 08:46:00+00 |     18600.00 | 0005432001002 | 69DAD1   | 7364 216524  | ANTON BONDARENKO    | {"phone": "+70322899756"}                                                        | 0005432001002 |     28895 |          24 | 12C
 08A2A5   | 2017-07-07 16:18:00+00 |     25300.00 | 0005432001003 | 08A2A5   | 3635 182357  | VALENTINA NIKITINA  | {"email": "nikitinavalentina.1975@postgrespro.ru", "phone": "+70794132478"}      | 0005432001003 |     28948 |           3 | 2C
 08A2A5   | 2017-07-07 16:18:00+00 |     25300.00 | 0005432001004 | 08A2A5   | 8252 507584  | ALLA TARASOVA       | {"phone": "+70212106431"}                                                        | 0005432001004 |     28948 |          15 | 6F
 C2CAB7   | 2017-07-12 17:03:00+00 |      6200.00 | 0005432001005 | C2CAB7   | 1026 982766  | OKSANA MOROZOVA     | {"phone": "+70806484401"}                                                        | 0005432001005 |     28942 |          42 | 17C
 C6DA66   | 2017-07-13 06:08:00+00 |     12400.00 | 0005432001006 | C6DA66   | 7107 950192  | GENNADIY GERASIMOV  | {"email": "gerasimov.g111981@postgrespro.ru", "phone": "+70733090498"}           | 0005432001006 |     28915 |          41 | 16C
(20 rows)
```
Результат запроса включает строки со столбцами из трёх таблиц 
  
Повторим запрос с ортировкой по коду бронирования:
```
demo=# select* from bookings b join tickets t on b.book_ref=t.book_ref left join boarding_passes bp on t.ticket_no=bp.ticket_no order by b.book_ref limit 20;
 book_ref |       book_date        | total_amount |   ticket_no   | book_ref | passenger_id |  passenger_name   |                                contact_data                                |   ticket_no   | flight_id | boarding_no | seat_no
----------+------------------------+--------------+---------------+----------+--------------+-------------------+----------------------------------------------------------------------------+---------------+-----------+-------------+---------
 00000F   | 2017-07-05 00:12:00+00 |    265700.00 | 0005435838975 | 00000F   | 1708 262537  | ANNA ANTONOVA     | {"email": "annaantonova-19021973@postgrespro.ru", "phone": "+70938049942"} | 0005435838975 |      5995 |          15 | 10E
 00000F   | 2017-07-05 00:12:00+00 |    265700.00 | 0005435838975 | 00000F   | 1708 262537  | ANNA ANTONOVA     | {"email": "annaantonova-19021973@postgrespro.ru", "phone": "+70938049942"} | 0005435838975 |     18058 |           6 | 5C
 000012   | 2017-07-14 06:02:00+00 |     37900.00 | 0005432527326 | 000012   | 9091 269355  | TAMARA ZAYCEVA    | {"email": "tamarazayceva-1971@postgrespro.ru", "phone": "+70749401734"}    | 0005432527326 |      7737 |         159 | 28C
 000012   | 2017-07-14 06:02:00+00 |     37900.00 | 0005432527326 | 000012   | 9091 269355  | TAMARA ZAYCEVA    | {"email": "tamarazayceva-1971@postgrespro.ru", "phone": "+70749401734"}    | 0005432527326 |     30620 |          46 | 13G
 000068   | 2017-08-15 11:27:00+00 |     18100.00 | 0005432293273 | 000068   | 5895 674437  | TATYANA PETROVA   | {"email": "t_petrova1970@postgrespro.ru", "phone": "+70886117503"}         |               |           |             |
 000181   | 2017-08-10 10:28:00+00 |    131800.00 | 0005435545945 | 000181   | 0929 739492  | EVGENIYA KARPOVA  | {"email": "karpovaevgeniya.1985@postgrespro.ru", "phone": "+70669289906"}  |               |           |             |
 000181   | 2017-08-10 10:28:00+00 |    131800.00 | 0005435545944 | 000181   | 6799 285573  | ALEKSANDR ZHUKOV  | {"email": "aleksandrzhukov111972@postgrespro.ru", "phone": "+70411811316"} |               |           |             |
 0002D8   | 2017-08-07 18:40:00+00 |     23600.00 | 0005435767874 | 0002D8   | 2126 190814  | SANIYA KOROLEVA   | {"email": "s_koroleva_1965@postgrespro.ru", "phone": "+70635878668"}       |               |           |             |
 0002DB   | 2017-07-29 03:30:00+00 |    101500.00 | 0005433986734 | 0002DB   | 9617 908381  | OLGA POTAPOVA     | {"phone": "+70138304349"}                                                  |               |           |             |
 0002DB   | 2017-07-29 03:30:00+00 |    101500.00 | 0005433986733 | 0002DB   | 1093 509566  | ANNA TITOVA       | {"email": "titova-a_051959@postgrespro.ru", "phone": "+70594590451"}       |               |           |             |
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407174 | 0002E0   | 5699 345447  | ALEKSANDR TARASOV | {"email": "tarasov.a-1972@postgrespro.ru", "phone": "+70450335494"}        | 0005434407174 |      7064 |         101 | 22B
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407174 | 0002E0   | 5699 345447  | ALEKSANDR TARASOV | {"email": "tarasov.a-1972@postgrespro.ru", "phone": "+70450335494"}        | 0005434407174 |     20299 |          13 | 4C
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407174 | 0002E0   | 5699 345447  | ALEKSANDR TARASOV | {"email": "tarasov.a-1972@postgrespro.ru", "phone": "+70450335494"}        | 0005434407174 |     26920 |          35 | 8C
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407174 | 0002E0   | 5699 345447  | ALEKSANDR TARASOV | {"email": "tarasov.a-1972@postgrespro.ru", "phone": "+70450335494"}        | 0005434407174 |     26987 |          28 | 8C
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407173 | 0002E0   | 3986 620108  | IGOR KARPOV       | {"email": "karpov-igor.1970@postgrespro.ru", "phone": "+70253260520"}      | 0005434407173 |      7064 |          63 | 14B
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407173 | 0002E0   | 3986 620108  | IGOR KARPOV       | {"email": "karpov-igor.1970@postgrespro.ru", "phone": "+70253260520"}      | 0005434407173 |     20299 |          56 | 14D
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407173 | 0002E0   | 3986 620108  | IGOR KARPOV       | {"email": "karpov-igor.1970@postgrespro.ru", "phone": "+70253260520"}      | 0005434407173 |     26920 |          15 | 4E
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00 | 0005434407173 | 0002E0   | 3986 620108  | IGOR KARPOV       | {"email": "karpov-igor.1970@postgrespro.ru", "phone": "+70253260520"}      | 0005434407173 |     26987 |           2 | 1D
 0002F3   | 2017-07-10 02:31:00+00 |     69600.00 | 0005433036155 | 0002F3   | 7293 080905  | NATALYA KISELEVA  | {"email": "n_kiseleva-16071971@postgrespro.ru", "phone": "+70989197928"}   | 0005433036155 |      2139 |          82 | 20H
 0002F3   | 2017-07-10 02:31:00+00 |     69600.00 | 0005433036155 | 0002F3   | 7293 080905  | NATALYA KISELEVA  | {"email": "n_kiseleva-16071971@postgrespro.ru", "phone": "+70989197928"}   | 0005433036155 |     24086 |          33 | 12G
(20 rows)
```
  
Сравним планы выполнения приведённых запросов:
```
demo=# explain select* from bookings b join tickets t on b.book_ref=t.book_ref left join boarding_passes bp on t.ticket_no=bp.ticket_no limit 20;
                                                     QUERY PLAN
---------------------------------------------------------------------------------------------------------------------
 Limit  (cost=1.27..9.33 rows=20 width=150)
   ->  Merge Left Join  (cost=1.27..233666.58 rows=579686 width=150)
         Merge Cond: (t.ticket_no = bp.ticket_no)
         ->  Nested Loop  (cost=0.84..188258.89 rows=366733 width=125)
               ->  Index Scan using tickets_pkey on tickets t  (cost=0.42..17308.42 rows=366733 width=104)
               ->  Index Scan using bookings_pkey on bookings b  (cost=0.42..0.47 rows=1 width=21)
                     Index Cond: (book_ref = t.book_ref)
         ->  Index Scan using boarding_passes_pkey on boarding_passes bp  (cost=0.42..37244.78 rows=579686 width=25)
(8 rows)

demo=# explain select* from bookings b join tickets t on b.book_ref=t.book_ref left join boarding_passes bp on t.ticket_no=bp.ticket_no order by b.book_ref limit 20;
                                                 QUERY PLAN
------------------------------------------------------------------------------------------------------------
 Limit  (cost=30192.86..30202.21 rows=20 width=150)
   ->  Nested Loop Left Join  (cost=30192.86..301316.68 rows=579686 width=150)
         ->  Merge Join  (cost=30192.43..86647.68 rows=366733 width=125)
               Merge Cond: (t.book_ref = b.book_ref)
               ->  Gather Merge  (cost=30187.61..72899.71 rows=366733 width=104)
                     Workers Planned: 2
                     ->  Sort  (cost=29187.58..29569.60 rows=152805 width=104)
                           Sort Key: t.book_ref
                           ->  Parallel Seq Scan on tickets t  (cost=0.00..7672.05 rows=152805 width=104)
               ->  Index Scan using bookings_pkey on bookings b  (cost=0.42..8511.24 rows=262788 width=21)
         ->  Index Scan using boarding_passes_pkey on boarding_passes bp  (cost=0.42..0.56 rows=3 width=25)
               Index Cond: (ticket_no = t.ticket_no)
(12 rows)
```
Не смотря на наличие индекса по столбцу b.book_ref (первичный ключ) стоимость запроса с группировкой значительно выше стоимости выполнения запроса без группировки.



  
**ОПИСАНИЕ БАЗЫ ДАННЫХ _demo_**  

**Структура и содержание таблицы _aircrafts_data_:**
```
demo=# \d aircrafts_data
                Table "bookings.aircrafts_data"
    Column     |     Type     | Collation | Nullable | Default
---------------+--------------+-----------+----------+---------
 aircraft_code | character(3) |           | not null |
 model         | jsonb        |           | not null |
 range         | integer      |           | not null |
Indexes:
    "aircrafts_pkey" PRIMARY KEY, btree (aircraft_code)
Check constraints:
    "aircrafts_range_check" CHECK (range > 0)
Referenced by:
    TABLE "flights" CONSTRAINT "flights_aircraft_code_fkey" FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code)
    TABLE "seats" CONSTRAINT "seats_aircraft_code_fkey" FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code) ON DELETE CASCADE

demo=# select* from aircrafts_data limit 10;
 aircraft_code |                           model                            | range
---------------+------------------------------------------------------------+-------
 773           | {"en": "Boeing 777-300", "ru": "Боинг 777-300"}            | 11100
 763           | {"en": "Boeing 767-300", "ru": "Боинг 767-300"}            |  7900
 SU9           | {"en": "Sukhoi Superjet-100", "ru": "Сухой Суперджет-100"} |  3000
 320           | {"en": "Airbus A320-200", "ru": "Аэробус A320-200"}        |  5700
 321           | {"en": "Airbus A321-200", "ru": "Аэробус A321-200"}        |  5600
 319           | {"en": "Airbus A319-100", "ru": "Аэробус A319-100"}        |  6700
 733           | {"en": "Boeing 737-300", "ru": "Боинг 737-300"}            |  4200
 CN1           | {"en": "Cessna 208 Caravan", "ru": "Сессна 208 Караван"}   |  1200
 CR2           | {"en": "Bombardier CRJ-200", "ru": "Бомбардье CRJ-200"}    |  2700
(9 rows)
```

**Структура и содержание таблицы _airports_data_:**
```
demo=# \d airports_data
                Table "bookings.airports_data"
    Column    |     Type     | Collation | Nullable | Default
--------------+--------------+-----------+----------+---------
 airport_code | character(3) |           | not null |
 airport_name | jsonb        |           | not null |
 city         | jsonb        |           | not null |
 coordinates  | point        |           | not null |
 timezone     | text         |           | not null |
Indexes:
    "airports_data_pkey" PRIMARY KEY, btree (airport_code)
Referenced by:
    TABLE "flights" CONSTRAINT "flights_arrival_airport_fkey" FOREIGN KEY (arrival_airport) REFERENCES airports_data(airport_code)
    TABLE "flights" CONSTRAINT "flights_departure_airport_fkey" FOREIGN KEY (departure_airport) REFERENCES airports_data(airport_code)

demo=# select* from airports_data limit 10;
 airport_code |                           airport_name                           |                           city                            |               coordinates               |      timezone
--------------+------------------------------------------------------------------+-----------------------------------------------------------+-----------------------------------------+--------------------
 YKS          | {"en": "Yakutsk Airport", "ru": "Якутск"}                        | {"en": "Yakutsk", "ru": "Якутск"}                         | (129.77099609375,62.093299865722656)    | Asia/Yakutsk
 MJZ          | {"en": "Mirny Airport", "ru": "Мирный"}                          | {"en": "Mirnyj", "ru": "Мирный"}                          | (114.03900146484375,62.534698486328125) | Asia/Yakutsk
 KHV          | {"en": "Khabarovsk-Novy Airport", "ru": "Хабаровск-Новый"}       | {"en": "Khabarovsk", "ru": "Хабаровск"}                   | (135.18800354004,48.52799987793)        | Asia/Vladivostok
 PKC          | {"en": "Yelizovo Airport", "ru": "Елизово"}                      | {"en": "Petropavlovsk", "ru": "Петропавловск-Камчатский"} | (158.45399475097656,53.16790008544922)  | Asia/Kamchatka
 UUS          | {"en": "Yuzhno-Sakhalinsk Airport", "ru": "Хомутово"}            | {"en": "Yuzhno-Sakhalinsk", "ru": "Южно-Сахалинск"}       | (142.71800231933594,46.88869857788086)  | Asia/Sakhalin
 VVO          | {"en": "Vladivostok International Airport", "ru": "Владивосток"} | {"en": "Vladivostok", "ru": "Владивосток"}                | (132.1479949951172,43.39899826049805)   | Asia/Vladivostok
 LED          | {"en": "Pulkovo Airport", "ru": "Пулково"}                       | {"en": "St. Petersburg", "ru": "Санкт-Петербург"}         | (30.262500762939453,59.80030059814453)  | Europe/Moscow
 KGD          | {"en": "Khrabrovo Airport", "ru": "Храброво"}                    | {"en": "Kaliningrad", "ru": "Калининград"}                | (20.592599868774414,54.88999938964844)  | Europe/Kaliningrad
 KEJ          | {"en": "Kemerovo Airport", "ru": "Кемерово"}                     | {"en": "Kemorovo", "ru": "Кемерово"}                      | (86.1072006225586,55.27009963989258)    | Asia/Novokuznetsk
 CEK          | {"en": "Chelyabinsk Balandino Airport", "ru": "Челябинск"}       | {"en": "Chelyabinsk", "ru": "Челябинск"}                  | (61.5033,55.305801)                     | Asia/Yekaterinburg
(10 rows)
```

**Структура и содержание таблицы _boarding_passes_:**
```
demo=# \d boarding_passes
                  Table "bookings.boarding_passes"
   Column    |         Type         | Collation | Nullable | Default
-------------+----------------------+-----------+----------+---------
 ticket_no   | character(13)        |           | not null |
 flight_id   | integer              |           | not null |
 boarding_no | integer              |           | not null |
 seat_no     | character varying(4) |           | not null |
Indexes:
    "boarding_passes_pkey" PRIMARY KEY, btree (ticket_no, flight_id)
    "boarding_passes_flight_id_boarding_no_key" UNIQUE CONSTRAINT, btree (flight_id, boarding_no)
    "boarding_passes_flight_id_seat_no_key" UNIQUE CONSTRAINT, btree (flight_id, seat_no)
Foreign-key constraints:
    "boarding_passes_ticket_no_fkey" FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id)

demo=# select* from boarding_passes limit 10;
   ticket_no   | flight_id | boarding_no | seat_no
---------------+-----------+-------------+---------
 0005435212351 |     30625 |           1 | 2D
 0005435212386 |     30625 |           2 | 3G
 0005435212381 |     30625 |           3 | 4H
 0005432211370 |     30625 |           4 | 5D
 0005435212357 |     30625 |           5 | 11A
 0005435212360 |     30625 |           6 | 11E
 0005435212393 |     30625 |           7 | 11H
 0005435212374 |     30625 |           8 | 12E
 0005435212365 |     30625 |           9 | 13D
 0005435212378 |     30625 |          10 | 14H
(10 rows)
```

**Структура и содержание таблицы _bookings_:**
```
demo=# \d bookings
                        Table "bookings.bookings"
    Column    |           Type           | Collation | Nullable | Default
--------------+--------------------------+-----------+----------+---------
 book_ref     | character(6)             |           | not null |
 book_date    | timestamp with time zone |           | not null |
 total_amount | numeric(10,2)            |           | not null |
Indexes:
    "bookings_pkey" PRIMARY KEY, btree (book_ref)
Referenced by:
    TABLE "tickets" CONSTRAINT "tickets_book_ref_fkey" FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)

demo=# select* from bookings limit 10;
 book_ref |       book_date        | total_amount
----------+------------------------+--------------
 00000F   | 2017-07-05 00:12:00+00 |    265700.00
 000012   | 2017-07-14 06:02:00+00 |     37900.00
 000068   | 2017-08-15 11:27:00+00 |     18100.00
 000181   | 2017-08-10 10:28:00+00 |    131800.00
 0002D8   | 2017-08-07 18:40:00+00 |     23600.00
 0002DB   | 2017-07-29 03:30:00+00 |    101500.00
 0002E0   | 2017-07-11 13:09:00+00 |     89600.00
 0002F3   | 2017-07-10 02:31:00+00 |     69600.00
 00034E   | 2017-08-04 13:52:00+00 |     73300.00
 000352   | 2017-07-05 23:02:00+00 |    109500.00
(10 rows)
```

**Структура и содержание таблицы _flights_:**
```
demo=# \d flights
                                              Table "bookings.flights"
       Column        |           Type           | Collation | Nullable |                  Default
---------------------+--------------------------+-----------+----------+--------------------------------------------
 flight_id           | integer                  |           | not null | nextval('flights_flight_id_seq'::regclass)
 flight_no           | character(6)             |           | not null |
 scheduled_departure | timestamp with time zone |           | not null |
 scheduled_arrival   | timestamp with time zone |           | not null |
 departure_airport   | character(3)             |           | not null |
 arrival_airport     | character(3)             |           | not null |
 status              | character varying(20)    |           | not null |
 aircraft_code       | character(3)             |           | not null |
 actual_departure    | timestamp with time zone |           |          |
 actual_arrival      | timestamp with time zone |           |          |
Indexes:
    "flights_pkey" PRIMARY KEY, btree (flight_id)
    "flights_flight_no_scheduled_departure_key" UNIQUE CONSTRAINT, btree (flight_no, scheduled_departure)
Check constraints:
    "flights_check" CHECK (scheduled_arrival > scheduled_departure)
    "flights_check1" CHECK (actual_arrival IS NULL OR actual_departure IS NOT NULL AND actual_arrival IS NOT NULL AND actual_arrival > actual_departure)
    "flights_status_check" CHECK (status::text = ANY (ARRAY['On Time'::character varying::text, 'Delayed'::character varying::text, 'Departed'::character varying::text, 'Arrived'::character varying::text, 'Scheduled'::character varying::text, 'Cancelled'::character varying::text]))
Foreign-key constraints:
    "flights_aircraft_code_fkey" FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code)
    "flights_arrival_airport_fkey" FOREIGN KEY (arrival_airport) REFERENCES airports_data(airport_code)
    "flights_departure_airport_fkey" FOREIGN KEY (departure_airport) REFERENCES airports_data(airport_code)
Referenced by:
    TABLE "ticket_flights" CONSTRAINT "ticket_flights_flight_id_fkey" FOREIGN KEY (flight_id) REFERENCES flights(flight_id)

demo=# select* from flights limit 10;
 flight_id | flight_no |  scheduled_departure   |   scheduled_arrival    | departure_airport | arrival_airport |  status   | aircraft_code | actual_departure | actual_arrival
-----------+-----------+------------------------+------------------------+-------------------+-----------------+-----------+---------------+------------------+----------------
      1185 | PG0134    | 2017-09-10 06:50:00+00 | 2017-09-10 11:55:00+00 | DME               | BTK             | Scheduled | 319           |                  |
      3979 | PG0052    | 2017-08-25 11:50:00+00 | 2017-08-25 14:35:00+00 | VKO               | HMA             | Scheduled | CR2           |                  |
      4739 | PG0561    | 2017-09-05 09:30:00+00 | 2017-09-05 11:15:00+00 | VKO               | AER             | Scheduled | 763           |                  |
      5502 | PG0529    | 2017-09-12 06:50:00+00 | 2017-09-12 08:20:00+00 | SVO               | UFA             | Scheduled | 763           |                  |
      6938 | PG0461    | 2017-09-04 09:25:00+00 | 2017-09-04 10:20:00+00 | SVO               | ULV             | Scheduled | SU9           |                  |
      7784 | PG0667    | 2017-09-10 12:00:00+00 | 2017-09-10 14:30:00+00 | SVO               | KRO             | Scheduled | CR2           |                  |
      9478 | PG0360    | 2017-08-28 06:00:00+00 | 2017-08-28 08:35:00+00 | LED               | REN             | Scheduled | CR2           |                  |
     11085 | PG0569    | 2017-08-24 12:05:00+00 | 2017-08-24 13:10:00+00 | SVX               | SCW             | Scheduled | 733           |                  |
     11847 | PG0498    | 2017-09-12 07:15:00+00 | 2017-09-12 11:55:00+00 | KZN               | IKT             | Scheduled | 319           |                  |
     12012 | PG0621    | 2017-08-26 13:05:00+00 | 2017-08-26 14:00:00+00 | KZN               | MQF             | Scheduled | CR2           |                  |
(10 rows)
```

**Структура и содержание таблицы _seats_:**
```
demo=# \d seats
                          Table "bookings.seats"
     Column      |         Type          | Collation | Nullable | Default
-----------------+-----------------------+-----------+----------+---------
 aircraft_code   | character(3)          |           | not null |
 seat_no         | character varying(4)  |           | not null |
 fare_conditions | character varying(10) |           | not null |
Indexes:
    "seats_pkey" PRIMARY KEY, btree (aircraft_code, seat_no)
Check constraints:
    "seats_fare_conditions_check" CHECK (fare_conditions::text = ANY (ARRAY['Economy'::character varying::text, 'Comfort'::character varying::text, 'Business'::character varying::text]))
Foreign-key constraints:
    "seats_aircraft_code_fkey" FOREIGN KEY (aircraft_code) REFERENCES aircrafts_data(aircraft_code) ON DELETE CASCADE

demo=# select* from seats limit 10;
 aircraft_code | seat_no | fare_conditions
---------------+---------+-----------------
 319           | 2A      | Business
 319           | 2C      | Business
 319           | 2D      | Business
 319           | 2F      | Business
 319           | 3A      | Business
 319           | 3C      | Business
 319           | 3D      | Business
 319           | 3F      | Business
 319           | 4A      | Business
 319           | 4C      | Business
(10 rows)
```

**Структура и содержание таблицы _ticket_flights_:**
```
demo=# \d ticket_flights
                     Table "bookings.ticket_flights"
     Column      |         Type          | Collation | Nullable | Default
-----------------+-----------------------+-----------+----------+---------
 ticket_no       | character(13)         |           | not null |
 flight_id       | integer               |           | not null |
 fare_conditions | character varying(10) |           | not null |
 amount          | numeric(10,2)         |           | not null |
Indexes:
    "ticket_flights_pkey" PRIMARY KEY, btree (ticket_no, flight_id)
Check constraints:
    "ticket_flights_amount_check" CHECK (amount >= 0::numeric)
    "ticket_flights_fare_conditions_check" CHECK (fare_conditions::text = ANY (ARRAY['Economy'::character varying::text, 'Comfort'::character varying::text, 'Business'::character varying::text]))
Foreign-key constraints:
    "ticket_flights_flight_id_fkey" FOREIGN KEY (flight_id) REFERENCES flights(flight_id)
    "ticket_flights_ticket_no_fkey" FOREIGN KEY (ticket_no) REFERENCES tickets(ticket_no)
Referenced by:
    TABLE "boarding_passes" CONSTRAINT "boarding_passes_ticket_no_fkey" FOREIGN KEY (ticket_no, flight_id) REFERENCES ticket_flights(ticket_no, flight_id)

demo=# select* from ticket_flights limit 10;
   ticket_no   | flight_id | fare_conditions |  amount
---------------+-----------+-----------------+----------
 0005432159776 |     30625 | Business        | 42100.00
 0005435212351 |     30625 | Business        | 42100.00
 0005435212386 |     30625 | Business        | 42100.00
 0005435212381 |     30625 | Business        | 42100.00
 0005432211370 |     30625 | Business        | 42100.00
 0005435212357 |     30625 | Comfort         | 23900.00
 0005435212360 |     30625 | Comfort         | 23900.00
 0005435212393 |     30625 | Comfort         | 23900.00
 0005435212374 |     30625 | Comfort         | 23900.00
 0005435212365 |     30625 | Comfort         | 23900.00
(10 rows)
```

**Структура и содержание таблицы _tickets_:**
```
demo=# \d tickets
                        Table "bookings.tickets"
     Column     |         Type          | Collation | Nullable | Default
----------------+-----------------------+-----------+----------+---------
 ticket_no      | character(13)         |           | not null |
 book_ref       | character(6)          |           | not null |
 passenger_id   | character varying(20) |           | not null |
 passenger_name | text                  |           | not null |
 contact_data   | jsonb                 |           |          |
Indexes:
    "tickets_pkey" PRIMARY KEY, btree (ticket_no)
Foreign-key constraints:
    "tickets_book_ref_fkey" FOREIGN KEY (book_ref) REFERENCES bookings(book_ref)
Referenced by:
    TABLE "ticket_flights" CONSTRAINT "ticket_flights_ticket_no_fkey" FOREIGN KEY (ticket_no) REFERENCES tickets(ticket_no)

demo=# select* from tickets limit 10;
   ticket_no   | book_ref | passenger_id |   passenger_name    |                                   contact_data
---------------+----------+--------------+---------------------+----------------------------------------------------------------------------------
 0005432000987 | 06B046   | 8149 604011  | VALERIY TIKHONOV    | {"phone": "+70127117011"}
 0005432000988 | 06B046   | 8499 420203  | EVGENIYA ALEKSEEVA  | {"phone": "+70378089255"}
 0005432000989 | E170C3   | 1011 752484  | ARTUR GERASIMOV     | {"phone": "+70760429203"}
 0005432000990 | E170C3   | 4849 400049  | ALINA VOLKOVA       | {"email": "volkova.alina_03101973@postgrespro.ru", "phone": "+70582584031"}
 0005432000991 | F313DD   | 6615 976589  | MAKSIM ZHUKOV       | {"email": "m-zhukov061972@postgrespro.ru", "phone": "+70149562185"}
 0005432000992 | F313DD   | 2021 652719  | NIKOLAY EGOROV      | {"phone": "+70791452932"}
 0005432000993 | F313DD   | 0817 363231  | TATYANA KUZNECOVA   | {"email": "kuznecova-t-011961@postgrespro.ru", "phone": "+70400736223"}
 0005432000994 | CCC5CB   | 2883 989356  | IRINA ANTONOVA      | {"email": "antonova.irina04121972@postgrespro.ru", "phone": "+70844502960"}
 0005432000995 | CCC5CB   | 3097 995546  | VALENTINA KUZNECOVA | {"email": "kuznecova.valentina10101976@postgrespro.ru", "phone": "+70268080457"}
 0005432000996 | 1FB1E4   | 6866 920231  | POLINA ZHURAVLEVA   | {"phone": "+70639918455"}
(10 rows)
```
  
<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
