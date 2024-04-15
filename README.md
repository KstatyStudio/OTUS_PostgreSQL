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


<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
