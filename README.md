## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 18 "Сбор и использование статистики"

### Домашнее задание
Работа с join'ами, статистикой

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 15,  
база данных _demo_ (https://edu.postgrespro.ru/demo-small.zip), разархивированный скрипт (https://github.com/KstatyStudio/OTUS_PostgreSQL/blob/hw18/demo-small-20170815.sql)

### Решение

**1. - Прямое соединение двух или более таблиц:**  
Список таблиц базы данных _demo_:
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







<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
