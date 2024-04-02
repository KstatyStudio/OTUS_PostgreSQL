## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 15 "Виды индексов. Работа с индексами и оптимизация запросов"

### Домашнее задание
Работа с индексами

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 14 

### Решение

**1.** - Создание индекса:  
Создаём базу данных _indexdb_, таблицу _indextbl_ и заполняем её тестовыми данными:
```
postgres=# create database indexdb;
CREATE DATABASE

postgres=# \c indexdb
You are now connected to database "indexdb" as user "postgres".

indexdb=# create table indextbl (id integer, string text, checkout boolean);
CREATE TABLE

indexdb=# insert into indextbl (id, string, checkout) select s.id, chr((32+random()*94)::integer), random()<0.01 from generate_series(1,10000) as s(id) order by random();
INSERT 0 10000


```

















<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
