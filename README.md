## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 18 "Сбор и использование статистики"

### Домашнее задание
Работа с join'ами, статистикой

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 15,  
база данных _demo_ (https://edu.postgrespro.ru/demo-small.zip), разархивированный скрипт (https://github.com/KstatyStudio/OTUS_PostgreSQL/blob/hw18/demo-small-20170815.sql)

### Решение

**Список таблиц базы данных _demo_:**
```
demo=# \dt
               List of relations
  Schema  |      Name       | Type  |  Owner
----------+-----------------+-------+----------
 bookings | aircrafts_data  | table | postgres
 bookings | airports_data   | table | postgres
 bookings | boarding_passes | table | postgres
 bookings | bookings        | table | postgres
 bookings | flights         | table | postgres
 bookings | seats           | table | postgres
 bookings | ticket_flights  | table | postgres
 bookings | tickets         | table | postgres
(8 rows)
```

**Содержание таблицы _aircrafts_data_:**
```
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

**Содержание таблицы _airports_data_:**
```
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

**Содержание таблицы _boarding_passes_:**
```
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

**Содержание таблицы _bookings_:**
```
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

**Содержание таблицы _flights_:**
```
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

**Содержание таблицы _seats_:**
```
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

**Содержание таблицы _ticket_flights_:**
```
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

**Содержание таблицы _tickets_:**
```
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

**1. - Прямое соединение двух или более таблиц:**  








<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
