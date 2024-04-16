## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 19 "Секционирование"

### Домашнее задание
Секционирование таблицы

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 15
база данных _demo small_ (https://postgrespro.ru/education/demodb)  

**Схема базы данных _demo_:**

![image](https://github.com/KstatyStudio/OTUS_PostgreSQL/assets/157008688/3d6c1854-bb3b-47b4-a2f6-16bc6d971650)
  
### Решение  

**1.** Получаем список таблиц базы данных _demo_ с указанием физических размеров:  
```
demo=# \dt+
                                                 List of relations
  Schema  |      Name       | Type  |  Owner   | Persistence | Access method |  Size   |        Description
----------+-----------------+-------+----------+-------------+---------------+---------+---------------------------
 bookings | aircrafts_data  | table | postgres | permanent   | heap          | 16 kB   | Aircrafts (internal data)
 bookings | airports_data   | table | postgres | permanent   | heap          | 56 kB   | Airports (internal data)
 bookings | boarding_passes | table | postgres | permanent   | heap          | 33 MB   | Boarding passes
 bookings | bookings        | table | postgres | permanent   | heap          | 13 MB   | Bookings
 bookings | flights         | table | postgres | permanent   | heap          | 3168 kB | Flights
 bookings | seats           | table | postgres | permanent   | heap          | 96 kB   | Seats
 bookings | ticket_flights  | table | postgres | permanent   | heap          | 68 MB   | Flight segment
 bookings | tickets         | table | postgres | permanent   | heap          | 48 MB   | Tickets
(8 rows)
```
  
Самая большая по размеру на диске таблица - _ticket_flights_.  
Посмотрим структуру этой таблицы:  
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
```
Первичный ключ таблицы составной - сочетание столбцов _ticket_no_ и _flight_id_.
    
Посмотрим статистику:  
```
demo=# select* from pg_stats where tablename='ticket_flights' \gx
```
  
```
-[ RECORD 1 ]----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
schemaname             | bookings
tablename              | ticket_flights
attname                | ticket_no
inherited              | f
null_frac              | 0
avg_width              | 14
n_distinct             | -0.3084747
most_common_vals       |
most_common_freqs      |
histogram_bounds       | {0005432001043,0005432106603,0005432207694,0005432328195,0005432359674,0005432383331,0005432423940,0005432458983,0005432525708,0005432530550,0005432571311,0005432609798,0005432658558,0005432692767,0005432720666,0005432783066,0005432799204,0005432823445,0005432880632,0005432920035,0005432949519,0005433008738,0005433057393,0005433103245,0005433126872,0005433180897,0005433233216,0005433252104,0005433289770,0005433343322,0005433345648,0005433373697,0005433404967,0005433449763,0005433477202,0005433525116,0005433569228,0005433614053,0005433616820,0005433654846,0005433716212,0005433754467,0005433785637,0005433810678,0005433868240,0005433923181,0005433960582,0005433985439,0005434024314,0005434067818,0005434082301,0005434138210,0005434142601,0005434175834,0005434215725,0005434245478,0005434286946,0005434326047,0005434375343,0005434408858,0005434435589,0005434462812,0005434505146,0005434551484,0005434566237,0005434610231,0005434655285,0005434727500,0005434757104,0005434825636,0005434878175,0005434880898,0005434908809,0005434948116,0005434988755,0005435040181,0005435069717,0005435100195,0005435127022,0005435150139,0005435213728,0005435243308,0005435282858,0005435311391,0005435373479,0005435424768,0005435464511,0005435502520,0005435529494,0005435554246,0005435616512,0005435653243,0005435696964,0005435720819,0005435767741,0005435808109,0005435852619,0005435902428,0005435928244,0005435982563,0005435999860}
correlation            | 0.056975093
most_common_elems      |
most_common_elem_freqs |
elem_count_histogram   |
```
  
```
-[ RECORD 2 ]----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
schemaname             | bookings
tablename              | ticket_flights
attname                | flight_id
inherited              | f
null_frac              | 0
avg_width              | 4
n_distinct             | 15135
most_common_vals       | {7753,5346,9871,30604,5296,30632,250,281,5311,5321,5328,5344,7757,9836,9847,10917,30579,30583,30631,249,298,5362,10886,10894,10899,10915,26212,30610,247,256,267,278,286,290,301,302,304,3488,3504,3511,3512,4962,5320,7769,9818,9828,9837,9874,9934,10908,14544,14556,259,260,275,282,284,2110,3487,5255,5259,5298,5303,5307,5317,5332,7720,7722,7727,7736,7761,7765,7776,9826,9909,10876,10887,10905,10918,10922,10932,14568,30581,30582,30626,265,269,274,2131,2325,3466,5268,5280,5322,5330,5336,5356,5360,7721,7734}
most_common_freqs      | {0.00063333334,0.00056666665,0.00056666665,0.00056666665,0.00053333334,0.00053333334,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.0005,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00046666668,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.00043333333,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.0004,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667,0.00036666667}
histogram_bounds       | {1,252,324,442,916,1173,1406,1576,1766,2115,2271,2362,2804,3125,3337,3492,3660,4248,4656,4795,5064,5248,5308,5406,5508,5605,6051,6365,6601,6981,7167,7422,7675,7771,8069,8257,8475,8807,9316,9544,9841,9895,10081,10640,10888,11021,11211,11571,11865,12063,12535,12782,12985,13449,13755,14464,14575,14705,15002,15382,15671,16564,17064,17313,17992,18550,19273,19736,20267,20493,20950,21099,21699,22029,22674,23272,23893,24254,24672,25107,25296,25718,25951,26209,26493,26845,27008,27528,28014,28608,28763,29146,29512,30042,30470,30574,30630,31020,31332,32352,33120}
correlation            | 0.0696742
most_common_elems      |
most_common_elem_freqs |
elem_count_histogram   |
```
  
```
-[ RECORD 3 ]----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
schemaname             | bookings
tablename              | ticket_flights
attname                | fare_conditions
inherited              | f
null_frac              | 0
avg_width              | 8
n_distinct             | 3
most_common_vals       | {Economy,Business,Comfort}
most_common_freqs      | {0.8812,0.10256667,0.016233332}
histogram_bounds       |
correlation            | 0.78496206
most_common_elems      |
most_common_elem_freqs |
elem_count_histogram   |
```

```  
-[ RECORD 4 ]----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
schemaname             | bookings
tablename              | ticket_flights
attname                | amount
inherited              | f
null_frac              | 0
avg_width              | 6
n_distinct             | 326
most_common_vals       | {6300.00,14400.00,6000.00,27900.00,14000.00,6700.00,11700.00,28000.00,12200.00,4000.00,7200.00,3300.00,61500.00,9800.00,13600.00,11800.00,11600.00,14800.00,7900.00,11000.00,3200.00,6200.00,10900.00,10200.00,19100.00,16400.00,12100.00,13400.00,44300.00,62100.00,17600.00,8200.00,3700.00,35300.00,13000.00,3400.00,7700.00,3000.00,6600.00,12700.00,16600.00,33300.00,9300.00,16700.00,10700.00,16200.00,18000.00,3100.00,5400.00,17000.00,20400.00,6900.00,9000.00,28700.00,4200.00,7100.00,3800.00,15400.00,13700.00,41500.00,38300.00,8800.00,8900.00,23500.00,9200.00,23100.00,3600.00,16100.00,4400.00,17400.00,15000.00,29900.00,16800.00,22400.00,9500.00,66400.00,23900.00,8100.00,9900.00,23200.00,24400.00,47400.00,19000.00,20000.00,15700.00,5200.00,22600.00,66600.00,18100.00,21500.00,18800.00,19900.00,29000.00,10100.00,15100.00,7600.00,4100.00,132900.00,47600.00,18900.00}
most_common_freqs      | {0.0318,0.026433334,0.026366666,0.025266666,0.024833333,0.023833333,0.0205,0.018466666,0.0175,0.016666668,0.016533334,0.016366666,0.0147,0.0133,0.013266667,0.013066667,0.0128,0.0128,0.0126,0.012533333,0.0117,0.0116,0.0116,0.011266666,0.010966667,0.0101333335,0.010066667,0.009933333,0.009766666,0.009666666,0.009233333,0.0092,0.008866667,0.008733333,0.008533333,0.008433334,0.0081,0.0074333334,0.007333333,0.0072,0.0071666664,0.0070666666,0.007033333,0.007,0.0066,0.0064666667,0.0063333334,0.006233333,0.006233333,0.0062,0.006,0.0059666666,0.0058333334,0.0058333334,0.0058,0.005566667,0.0054666665,0.0050666668,0.005,0.0048,0.004766667,0.0047333334,0.0046333335,0.0046333335,0.0046,0.0046,0.0045333332,0.004466667,0.0043666665,0.004333333,0.0042,0.0041,0.004033333,0.004033333,0.004,0.0039666668,0.0038666667,0.0038,0.0038,0.0037,0.0036666666,0.0036666666,0.0036,0.0035666667,0.0034666667,0.0033666666,0.0033,0.0032666668,0.0031666667,0.0031,0.0029,0.0029,0.0028666668,0.0028333333,0.0028333333,0.0027,0.0026333334,0.0026,0.0025666666,0.0025}
histogram_bounds       | {3500.00,4300.00,4900.00,5800.00,5900.00,7000.00,7000.00,7400.00,7500.00,7800.00,8700.00,9100.00,10300.00,10500.00,11100.00,11300.00,11900.00,12000.00,12400.00,12500.00,12800.00,13900.00,13900.00,14100.00,14600.00,14700.00,15500.00,15600.00,15600.00,16300.00,17200.00,17900.00,18500.00,18700.00,19300.00,19400.00,19700.00,20200.00,20300.00,20900.00,21400.00,22300.00,22800.00,23600.00,24500.00,24600.00,24700.00,25500.00,25700.00,26400.00,26900.00,27800.00,28900.00,29100.00,29200.00,29400.00,29500.00,30600.00,30700.00,30800.00,32000.00,32800.00,33000.00,33700.00,34700.00,35000.00,35600.00,36500.00,36600.00,38800.00,39100.00,40900.00,41200.00,42100.00,43100.00,44400.00,48100.00,48400.00,48700.00,49100.00,49700.00,50100.00,52900.00,57200.00,61800.00,64400.00,67700.00,67800.00,70400.00,83700.00,83700.00,84000.00,86900.00,89800.00,99800.00,106800.00,133200.00,184500.00,186200.00,199300.00,203300.00}
correlation            | 0.011273632
most_common_elems      |
most_common_elem_freqs |
elem_count_histogram   |
```
Самая высокая корреляция данных - в столбце fare_conditions (0.78496206). Но распределение имеющихся трёх значений класса обслуживания очень неравномерное: {0.8812,0.10256667,0.016233332}. Секционирование по списку значений этого столбца может оказаться неэффективным. 
Корреляция данных в столбцах _ticket_no_ и _flight_id_ довольно низкая (-0.3084747 и 0.0696742), но эти поля входят в состав первичного ключа и сочетание их значений в каждой строке уникальное. Данные можно равномерно распределить на секции по хэшу первичного ключа.

Предварительно выполним запрос и посмотрим какие перелеты включены в билет с номером 0005432661915:  
```
demo=# SELECT   to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
    when    |     departure     |      arrival      |  class   |  amount
------------+-------------------+-------------------+----------+-----------
 29.07.2017 | Москва(SVO)       | Анадырь(DYR)      | Business | 185300.00
 01.08.2017 | Анадырь(DYR)      | Хабаровск(KHV)    | Business |  92200.00
 03.08.2017 | Хабаровск(KHV)    | Благовещенск(BQS) | Business |  18000.00
 08.08.2017 | Благовещенск(BQS) | Хабаровск(KHV)    | Business |  18000.00
 12.08.2017 | Хабаровск(KHV)    | Анадырь(DYR)      | Economy  |  30700.00
 17.08.2017 | Анадырь(DYR)      | Москва(SVO)       | Business | 185300.00
(6 rows)
```
  
План запроса:
```
demo=# EXPLAIN ANALYZE SELECT   to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
                                                                           QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=43.96..43.96 rows=3 width=118) (actual time=0.141..0.143 rows=6 loops=1)
   Sort Key: f.scheduled_departure
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=1.00..43.93 rows=3 width=118) (actual time=0.074..0.133 rows=6 loops=1)
         ->  Nested Loop  (cost=0.86..41.87 rows=3 width=79) (actual time=0.030..0.063 rows=6 loops=1)
               ->  Nested Loop  (cost=0.71..41.39 rows=3 width=30) (actual time=0.022..0.046 rows=6 loops=1)
                     ->  Index Scan using ticket_flights_pkey on ticket_flights tf  (cost=0.42..16.46 rows=3 width=18) (actual time=0.014..0.020 rows=6 loops=1)
                           Index Cond: (ticket_no = '0005432661915'::bpchar)
                     ->  Index Scan using flights_pkey on flights f  (cost=0.29..8.31 rows=1 width=20) (actual time=0.003..0.003 rows=1 loops=6)
                           Index Cond: (flight_id = tf.flight_id)
               ->  Index Scan using airports_data_pkey on airports_data ml  (cost=0.14..0.16 rows=1 width=53) (actual time=0.002..0.002 rows=1 loops=6)
                     Index Cond: (airport_code = f.departure_airport)
         ->  Index Scan using airports_data_pkey on airports_data ml_1  (cost=0.14..0.16 rows=1 width=53) (actual time=0.002..0.002 rows=1 loops=6)
               Index Cond: (airport_code = f.arrival_airport)
 Planning Time: 0.491 ms
 Execution Time: 0.183 ms
(16 rows)
```
Стоимость выполнения запроса 43.96, время выполнеия - 0,183 миллисекунды.

Для секционирования таблицы _ticket_flights_ создадим её копию _ticket_flights_prt:
```
demo=# create table ticket_flights_prt (like ticket_flights including all) partition by hash (ticket_no, flight_id);
CREATE TABLE
```

Создадим 3 секции (объём, занимаемый таблицей на диске, не нуждается в более сильном дроблении):
```
demo=# create table ticket_flights_0 partition of ticket_flights_prt for values with (modulus 3, remainder 0);
CREATE TABLE
  
demo=# create table ticket_flights_1 partition of ticket_flights_prt for values with (modulus 3, remainder 1);
CREATE TABLE
  
demo=# create table ticket_flights_2 partition of ticket_flights_prt for values with (modulus 3, remainder 2);
CREATE TABLE
```
  
Заполним данными из _ticket_flights_:
```
demo=# insert into ticket_flights_prt select* from ticket_flights;

demo=# analyze ticket_flights_prt;
ANALYZE
```
  
Проверяем:
```
demo=# SELECT   to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights_prt tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
    when    |     departure     |      arrival      |  class   |  amount
------------+-------------------+-------------------+----------+-----------
 29.07.2017 | Москва(SVO)       | Анадырь(DYR)      | Business | 185300.00
 01.08.2017 | Анадырь(DYR)      | Хабаровск(KHV)    | Business |  92200.00
 03.08.2017 | Хабаровск(KHV)    | Благовещенск(BQS) | Business |  18000.00
 08.08.2017 | Благовещенск(BQS) | Хабаровск(KHV)    | Business |  18000.00
 12.08.2017 | Хабаровск(KHV)    | Анадырь(DYR)      | Economy  |  30700.00
 17.08.2017 | Анадырь(DYR)      | Москва(SVO)       | Business | 185300.00
(6 rows)
```

План запроса:
```
demo=# EXPLAIN ANALYZE SELECT to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights_prt tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
                                                                                 QUERY PLAN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=92.48..92.49 rows=6 width=118) (actual time=0.177..0.179 rows=6 loops=1)
   Sort Key: f.scheduled_departure
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=1.87..92.40 rows=6 width=118) (actual time=0.108..0.169 rows=6 loops=1)
         ->  Nested Loop  (cost=1.72..88.27 rows=6 width=79) (actual time=0.066..0.101 rows=6 loops=1)
               ->  Nested Loop  (cost=1.58..87.31 rows=6 width=30) (actual time=0.062..0.088 rows=6 loops=1)
                     ->  Merge Append  (cost=1.29..37.46 rows=6 width=18) (actual time=0.051..0.059 rows=6 loops=1)
                           Sort Key: tf.flight_id
                           ->  Index Scan using ticket_flights_0_pkey on ticket_flights_0 tf_1  (cost=0.42..12.45 rows=2 width=18) (actual time=0.020..0.024 rows=3 loops=1)
                                 Index Cond: (ticket_no = '0005432661915'::bpchar)
                           ->  Index Scan using ticket_flights_1_pkey on ticket_flights_1 tf_2  (cost=0.42..12.45 rows=2 width=18) (actual time=0.015..0.017 rows=2 loops=1)
                                 Index Cond: (ticket_no = '0005432661915'::bpchar)
                           ->  Index Scan using ticket_flights_2_pkey on ticket_flights_2 tf_3  (cost=0.42..12.45 rows=2 width=18) (actual time=0.015..0.015 rows=1 loops=1)
                                 Index Cond: (ticket_no = '0005432661915'::bpchar)
                     ->  Index Scan using flights_pkey on flights f  (cost=0.29..8.31 rows=1 width=20) (actual time=0.004..0.004 rows=1 loops=6)
                           Index Cond: (flight_id = tf.flight_id)
               ->  Index Scan using airports_data_pkey on airports_data ml  (cost=0.14..0.16 rows=1 width=53) (actual time=0.002..0.002 rows=1 loops=6)
                     Index Cond: (airport_code = f.departure_airport)
         ->  Index Scan using airports_data_pkey on airports_data ml_1  (cost=0.14..0.16 rows=1 width=53) (actual time=0.001..0.001 rows=1 loops=6)
               Index Cond: (airport_code = f.arrival_airport)
 Planning Time: 0.731 ms
 Execution Time: 0.223 ms
(22 rows)
```
Время выполнения запроса выросло. Сканирование выполняется по всем секциям. Секционирование по составному атрибуту в данном случае не привело к повышению производительности.
  
Удаляем таблицу _ticket_flights_prt_ и секционируем _ticket_flights_ по хэшу одного столбца - _ticket_no_:
```
demo=# drop table ticket_flights_prt;
DROP TABLE

demo=# create table ticket_flights_prt (like ticket_flights including all) partition by hash (ticket_no);
CREATE TABLE
demo=# create table ticket_flights_0 partition of ticket_flights_prt for values with (modulus 3, remainder 0);
CREATE TABLE
demo=# create table ticket_flights_1 partition of ticket_flights_prt for values with (modulus 3, remainder 1);
CREATE TABLE
demo=# create table ticket_flights_2 partition of ticket_flights_prt for values with (modulus 3, remainder 2);
CREATE TABLE

demo=# insert into ticket_flights_prt select* from ticket_flights;
INSERT 0 1045726

demo=# analyze ticket_flights_prt;
ANALYZE
```
  
Проверяем:
```
demo=# \dt+
                                                        List of relations
  Schema  |        Name        |       Type        |  Owner   | Persistence | Access method |  Size   |        Description
----------+--------------------+-------------------+----------+-------------+---------------+---------+---------------------------
 bookings | aircrafts_data     | table             | postgres | permanent   | heap          | 16 kB   | Aircrafts (internal data)
 bookings | airports_data      | table             | postgres | permanent   | heap          | 56 kB   | Airports (internal data)
 bookings | boarding_passes    | table             | postgres | permanent   | heap          | 33 MB   | Boarding passes
 bookings | bookings           | table             | postgres | permanent   | heap          | 13 MB   | Bookings
 bookings | flights            | table             | postgres | permanent   | heap          | 3168 kB | Flights
 bookings | seats              | table             | postgres | permanent   | heap          | 96 kB   | Seats
 bookings | ticket_flights     | table             | postgres | permanent   | heap          | 68 MB   | Flight segment
 bookings | ticket_flights_0   | table             | postgres | permanent   | heap          | 23 MB   |
 bookings | ticket_flights_1   | table             | postgres | permanent   | heap          | 23 MB   |
 bookings | ticket_flights_2   | table             | postgres | permanent   | heap          | 23 MB   |
 bookings | ticket_flights_prt | partitioned table | postgres | permanent   |               | 0 bytes |
 bookings | tickets            | table             | postgres | permanent   | heap          | 48 MB   | Tickets
(12 rows)
```
Данные из _ticket_flights_ равномерно распределились по трём секциям таблицы _ticket_flights_prt_.
  
Выполним тестовый запрос:   
```
demo=# SELECT to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights_prt tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
    when    |     departure     |      arrival      |  class   |  amount
------------+-------------------+-------------------+----------+-----------
 29.07.2017 | Москва(SVO)       | Анадырь(DYR)      | Business | 185300.00
 01.08.2017 | Анадырь(DYR)      | Хабаровск(KHV)    | Business |  92200.00
 03.08.2017 | Хабаровск(KHV)    | Благовещенск(BQS) | Business |  18000.00
 08.08.2017 | Благовещенск(BQS) | Хабаровск(KHV)    | Business |  18000.00
 12.08.2017 | Хабаровск(KHV)    | Анадырь(DYR)      | Economy  |  30700.00
 17.08.2017 | Анадырь(DYR)      | Москва(SVO)       | Business | 185300.00
(6 rows)
```
  
План запроса:
```
demo=# EXPLAIN ANALYZE SELECT to_char(f.scheduled_departure, 'DD.MM.YYYY') as when,
         f.departure_city || '(' || f.departure_airport || ')' as departure,
         f.arrival_city || '(' || f.arrival_airport || ')' as arrival,
         tf.fare_conditions as class,
         tf.amount
FROM     ticket_flights_prt tf
         JOIN flights_v f ON tf.flight_id = f.flight_id
WHERE    tf.ticket_no = '0005432661915'
ORDER BY f.scheduled_departure;
                                                                             QUERY PLAN
---------------------------------------------------------------------------------------------------------------------------------------------------------------------
 Sort  (cost=43.96..43.97 rows=3 width=118) (actual time=0.133..0.135 rows=6 loops=1)
   Sort Key: f.scheduled_departure
   Sort Method: quicksort  Memory: 25kB
   ->  Nested Loop  (cost=1.00..43.93 rows=3 width=118) (actual time=0.064..0.125 rows=6 loops=1)
         ->  Nested Loop  (cost=0.85..41.87 rows=3 width=79) (actual time=0.025..0.058 rows=6 loops=1)
               ->  Nested Loop  (cost=0.71..41.39 rows=3 width=30) (actual time=0.022..0.046 rows=6 loops=1)
                     ->  Index Scan using ticket_flights_0_pkey on ticket_flights_0 tf  (cost=0.42..16.46 rows=3 width=18) (actual time=0.016..0.024 rows=6 loops=1)
                           Index Cond: (ticket_no = '0005432661915'::bpchar)
                     ->  Index Scan using flights_pkey on flights f  (cost=0.29..8.31 rows=1 width=20) (actual time=0.003..0.003 rows=1 loops=6)
                           Index Cond: (flight_id = tf.flight_id)
               ->  Index Scan using airports_data_pkey on airports_data ml  (cost=0.14..0.16 rows=1 width=53) (actual time=0.001..0.001 rows=1 loops=6)
                     Index Cond: (airport_code = f.departure_airport)
         ->  Index Scan using airports_data_pkey on airports_data ml_1  (cost=0.14..0.16 rows=1 width=53) (actual time=0.001..0.001 rows=1 loops=6)
               Index Cond: (airport_code = f.arrival_airport)
 Planning Time: 0.551 ms
 Execution Time: 0.169 ms
(16 rows)
```
Время выполнения запроса незначительно сократилось. Сканирование выполняется по партиции, а не по всей таблице. Возможно, при росте объёма данных будет более заметных рост производительности.
  
<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
