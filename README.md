## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 15 "Виды индексов. Работа с индексами и оптимизация запросов"

### Домашнее задание
Работа с индексами

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 14 

### Решение

**1. - Создание индекса:**  
Создаём базу данных _indexdb_, таблицу _indextbl_ и заполняем её тестовыми данными:
```
postgres=# create database indexdb;
CREATE DATABASE

postgres=# \c indexdb
You are now connected to database "indexdb" as user "postgres".

indexdb=# create table indextbl (id integer, string text, checkout boolean);
CREATE TABLE

indexdb=# insert into indextbl (id, string, checkout) select s.id, md5(random()::text)::char(32), random()<0.01 from generate_series(1,10000) as s(id) order by random();
INSERT 0 10000

indexdb=# select id, string, checkout from indextbl limit 10;
  id  |              string              | checkout
------+----------------------------------+----------
 5789 | 30fbb16b5ed3746d4b1084775429945d | t
 8800 | dfa8d5ed6ec36906c85a15447563ee7e | t
 3810 | f809f4b9147399f4a43a268316bf0cf9 | t
 4278 | 089a72ef64d6f525b02f18a62f54958f | t
 1882 | c99895b329667a004ea990bcb13ce00b | t
 2064 | 556ed17b8222e4b4392aec89b34ad2d9 | t
 6835 | 76cd1caa0860feafecc99cfe8c32a905 | t
 2161 | a892799021b0c7acb1e8dc7a581c2719 | t
 2852 | 95740f46450289d6b6513bed453753bb | t
  551 | a9fe0e0d7a1f8af01227fa0b8a64bcda | t
(10 rows)
```

Смотрим план выполнения запроса:
```
indexdb=# explain select id, string, checkout from indextbl where id=551;
                        QUERY PLAN
-----------------------------------------------------------
 Seq Scan on indextbl  (cost=0.00..209.00 rows=1 width=38)
   Filter: (id = 551)
(2 rows)
```
Стоимость выполнения запроса оценивается в диапазоне 0 - 209.

Создаём индекс по числовому полю:
```
indexdb=# create index on indextbl (id);
CREATE INDEX
```

Сравниваем план выполнения запроса:
```
indexdb=# explain select id, string, checkout from indextbl where id=551;
                                   QUERY PLAN
---------------------------------------------------------------------------------
 Index Scan using indextbl_id_idx on indextbl  (cost=0.29..8.30 rows=1 width=38)
   Index Cond: (id = 551)
(2 rows)
```
Максимальная оценка стоимости выполнения запроса снизилась с 209 до 8.30 - более чем в 25 раз.

**2. - Создание индекса для полнотекстового поиска:**












<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
