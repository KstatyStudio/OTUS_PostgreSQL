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

Отчёт Товар-Продажи:
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
   
Изменяем триггерную функцию:
```

```
  

Смотрим содержание всех таблиц




<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
