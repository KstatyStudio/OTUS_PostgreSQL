## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 22 "Хранимые функции и процедуры"

### Домашнее задание
Триггеры, поддержка заполнения витрин

### Исходные данные
ВМ (облако): Ubuntu 22.04, PostgreSQL 16  

База данных "Магазин" (_testmarket_):
```
create database testmarket;
\c testmarket
create schema market;
set search_path=market, public;
```
  
Таблица "Товары" (_goods_):
```
CREATE TABLE goods(
    goods_id    integer PRIMARY KEY,
    good_name   varchar(63) NOT NULL,
    good_price  numeric(12, 2) NOT NULL CHECK (good_price > 0.0));

INSERT INTO goods (goods_id, good_name, good_price)
VALUES  (1, 'Спички хозайственные', .50), (2, 'Автомобиль Ferrari FXX K', 185000000.01);
```
  
Таблица "Продажи" (_sales_):
```
CREATE TABLE sales(
    sales_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    goods_id     integer REFERENCES goods (goods_id),
    sales_time  timestamp with time zone DEFAULT now(),
    sales_qty   integer CHECK (sales_qty > 0));

INSERT INTO sales (goods_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);
```

Отчёт "Товар-Продажи":
```
SELECT G.good_name, sum(G.good_price * S.sales_qty)
FROM goods G
INNER JOIN sales S ON S.goods_id = G.goods_id
GROUP BY G.good_name;
```
    
Денормализованная таблица - витрина "Суммы продаж":
```
CREATE TABLE good_sum_mart(
	good_name   varchar(63) NOT NULL,
	sum_sale	numeric(16, 2)NOT NULL);
```

Триггерная функция, позволяющая автоматически актуализировать данные в витрине "Суммы продаж" при внесении любых изменений в таблицу "Продажи":
```
CREATE OR REPLACE FUNCTION tr_mart()
RETURNS trigger
AS
$$
DECLARE
    v_name      text;
    v_summa_ins numeric(16, 2);
    v_summa_del numeric(16, 2);

BEGIN
    RAISE NOTICE 'TG_OP = %', TG_OP;
    
    CASE TG_OP
        WHEN 'INSERT' THEN
            SELECT G.good_name, (G.good_price * NEW.sales_qty)
            INTO v_name, v_summa_ins
            FROM goods G
            WHERE G.goods_id = NEW.goods_id;
    
            INSERT INTO good_sum_mart (good_name, sum_sale)
            VALUES(v_name, v_summa_ins)
            ON CONFLICT (good_name)
            DO UPDATE 
            SET sum_sale = good_sum_mart.sum_sale + v_summa_ins;
        
            RETURN NEW;
       
        WHEN 'DELETE' THEN
            SELECT G.good_name, (G.good_price * OLD.sales_qty)
            INTO v_name, v_summa_del
            FROM goods G
            WHERE G.goods_id = OLD.goods_id;        
        
            UPDATE good_sum_mart
            SET sum_sale = sum_sale - v_summa_del
            WHERE good_name = v_name;
        
            RETURN NULL;
        
        WHEN 'UPDATE' THEN
            SELECT G.good_name, (G.good_price * NEW.sales_qty), (G.good_price * OLD.sales_qty)
            INTO v_name, v_summa_ins, v_summa_del
            FROM goods G
            WHERE G.goods_id = OLD.goods_id;

            RAISE NOTICE '%  %', v_summa_ins, v_summa_del;
        
            UPDATE good_sum_mart
            SET sum_sale = sum_sale + v_summa_ins - v_summa_del
            WHERE good_name = v_name;
        
            RETURN NEW;

    END CASE;

END;
$$ LANGUAGE plpgsql
    SET search_path = market, public
    SECURITY DEFINER;
```
  
Триггер:
```
CREATE TRIGGER r_mart
AFTER INSERT OR UPDATE OR DELETE
ON sales
FOR ROW
EXECUTE FUNCTION tr_mart();
```
  
### Решение

**1.** Заполняем таблицу "Продажи" тестовыми данными после создания триггерной функции и триггера - для заполнения витрины "Суммы продаж":  
```
testmarket=# INSERT INTO sales (goods_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);
NOTICE:  TG_OP = INSERT
ERROR:  there is no unique or exclusion constraint matching the ON CONFLICT specification
CONTEXT:  SQL statement "INSERT INTO good_sum_mart (good_name, sum_sale)
            VALUES(v_name, v_summa_ins)
            ON CONFLICT (good_name)
            DO UPDATE
            SET sum_sale = good_sum_mart.sum_sale + v_summa_ins"
PL/pgSQL function tr_mart() line 17 at SQL statement
```
   
Изменяем таблицу - витрину "Суммы продаж" - добавляем признак уникальности _good_name_:
```
testmarket=# alter table good_sum_mart add unique(good_name);
ALTER TABLE
```
  
Заполняем:
```
testmarket=# INSERT INTO sales (goods_id, sales_qty) VALUES (1, 10), (1, 1), (1, 120), (2, 1);
NOTICE:  TG_OP = INSERT
NOTICE:  TG_OP = INSERT
NOTICE:  TG_OP = INSERT
NOTICE:  TG_OP = INSERT
INSERT 0 4
```
  
Смотрим содержание всех таблиц:
```
testmarket=# select* from goods;
 goods_id |        good_name         |  good_price
----------+--------------------------+--------------
        1 | Спички хозайственные     |         0.50
        2 | Автомобиль Ferrari FXX K | 185000000.01
(2 rows)

testmarket=# select* from sales;
 sales_id | goods_id |          sales_time           | sales_qty
----------+----------+-------------------------------+-----------
       69 |        1 | 2024-04-27 12:52:23.297787+00 |        10
       70 |        1 | 2024-04-27 12:52:23.297787+00 |         1
       71 |        1 | 2024-04-27 12:52:23.297787+00 |       120
       72 |        2 | 2024-04-27 12:52:23.297787+00 |         1
(4 rows)

testmarket=# select* from good_sum_mart;
        good_name         |   sum_sale
--------------------------+--------------
 Спички хозайственные     |        65.50
 Автомобиль Ferrari FXX K | 185000000.01
(2 rows)
```
  
Формируем отчёт "Товар-Продажи" и смотрим его план выполнения запроса:
```
testmarket=# SELECT G.good_name, sum(G.good_price * S.sales_qty) FROM goods G INNER JOIN sales S ON S.goods_id = G.goods_id GROUP BY G.good_name;
        good_name         |     sum
--------------------------+--------------
 Автомобиль Ferrari FXX K | 185000000.01
 Спички хозайственные     |        65.50
(2 rows)

testmarket=# explain analyze SELECT G.good_name, sum(G.good_price * S.sales_qty) FROM goods G INNER JOIN sales S ON S.goods_id = G.goods_id GROUP BY G.good_name;
                                                       QUERY PLAN
------------------------------------------------------------------------------------------------------------------------
 HashAggregate  (cost=67.96..70.46 rows=200 width=176) (actual time=0.046..0.049 rows=2 loops=1)
   Group Key: g.good_name
   Batches: 1  Memory Usage: 40kB
   ->  Hash Join  (cost=19.45..50.96 rows=1700 width=164) (actual time=0.030..0.032 rows=4 loops=1)
         Hash Cond: (s.goods_id = g.goods_id)
         ->  Seq Scan on sales s  (cost=0.00..27.00 rows=1700 width=8) (actual time=0.007..0.008 rows=4 loops=1)
         ->  Hash  (cost=14.20..14.20 rows=420 width=164) (actual time=0.009..0.009 rows=2 loops=1)
               Buckets: 1024  Batches: 1  Memory Usage: 9kB
               ->  Seq Scan on goods g  (cost=0.00..14.20 rows=420 width=164) (actual time=0.005..0.006 rows=2 loops=1)
 Planning Time: 0.125 ms
 Execution Time: 0.085 ms
(11 rows)
```
Отчёт "Товар-Продажи" формируется за 0,085 миллисекунд и его стоимость оценивается в 70.46 единиц.

Запрашиваем данные из витрины "Суммы продаж":
```
testmarket=# select* from good_sum_mart m order by m.good_name;
        good_name         |   sum_sale
--------------------------+--------------
 Автомобиль Ferrari FXX K | 185000000.01
 Спички хозайственные     |        65.50
(2 rows)

testmarket=# explain analyze select* from good_sum_mart m order by m.good_name;
                                                     QUERY PLAN
--------------------------------------------------------------------------------------------------------------------
 Sort  (cost=32.50..33.55 rows=420 width=162) (actual time=0.021..0.022 rows=2 loops=1)
   Sort Key: good_name
   Sort Method: quicksort  Memory: 25kB
   ->  Seq Scan on good_sum_mart m  (cost=0.00..14.20 rows=420 width=162) (actual time=0.009..0.010 rows=2 loops=1)
 Planning Time: 0.072 ms
 Execution Time: 0.035 ms
(6 rows)
```
Аналогичные данные из витрины получены за 0,035 миллисекунд, стоимость оценивается в 33.55 единиц. Таким образом использование витрины данных вместо запроса-отчёта позволяет значительно снизит накладные расходы на получение запрашиваемых данных.  
  



<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
