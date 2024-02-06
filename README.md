## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 2 "SQL и реляционные СУБД. Введение в PostgreSQL"

### Домашнее задание
Работа с уровнями изоляции транзакции в PostgreSQL

### Исходные данные
ВМ, Debian 12, PostgreSQL 15, SSH-сессия (2 шт.)

### Решение

**1.** Запускаем _psql_ из-под пользователя _postgres_ и выключаем _auto commit_ в кадой ssh-сессии:
```
root@test:~# su - postgres
root@test:~# psql

postgres=# \set AUTOCOMMIT off
```
Проверяем:
```
postgres=# \echo :AUTOCOMMIT
off
```

**2.** **Сессия #1** - создаём новую таблицу:
```
postgres=# create table persons(id serial, first_name text, second_name text);
CREATE TABLE
```
Заполняем данными:
```
postgres=*# insert into persons(first_name, second_name) values('ivan', 'ivanov');
INSERT 0 1

postgres=*# insert into persons(first_name, second_name) values('petr', 'petrov');
INSERT 0 1

postgres=*# commit;
COMMIT
```
Проверяем:
```
postgres=# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 строки)

postgres=*# commit;
COMMIT
```

Смотрим текущий уровень изоляции:
```
postgres=# show transaction isolation level;
 transaction_isolation
-----------------------
 read committed
(1 строка)

postgres=*# commit;
COMMIT
```

**3.** Начинаем новую транзакцию в каждой ssh-сессии с дефолтным уровнем изоляции:
```
postgres=# begin;
BEGIN
```

**Сессия #1** - добавляем новую запись в таблицу _persons_:
```
postgres=*# insert into persons(first_name, second_name) values('sergey', 'sergeev');
INSERT 0 1
```

**Сессия #2** - выбираем все записи из таблицы _persons_:
```
postgres=*# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
(2 строки)
```

В полученной выборке мы не видим новую строку, добавленную в первой сессии, т.к. текущий уровень изоляции транзакций _read committed_ не позволяет просматривать незафиксированные до начала запроса изменения, внесённые другими транзакциями.

**Сессия #1** - завершаем транзакцию:
```
postgres=*# commit;
COMMIT
```

**Сессия #2** - повторяем выборку всех записей из таблицы _persons_:
```
postgres=*# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  3 | sergey     | sergeev
(3 строки)

postgres=*# commit;
COMMIT
```
Во вновь полученной выборке мы видим новую строку, добавленную в первой сессии, т.к. транзакция в первой сессии завершена (зафиксирована), а в текущей транзакции выполнен новый запрос.

**4**. В каждой ssh-сессии устанавливаем уровень изоляции _repeatable read_ и начинаем новые транзакции:
```
postgres=# set transaction isolation level repeatable read;
SET
```

**Сессия #1** - добавляем новую запись в таблицу _persons_:
```
postgres=*# insert into persons(first_name, second_name) values('sveta', 'svetova');
INSERT 0 1
```

**Сессия #2** - выбираем все записи из таблицы _persons_:
```
postgres=*# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  3 | sergey     | sergeev
(3 строки)
```

В полученной выборке мы не видим новую строку, добавленную в первой сессии, т.к. текущий уровень изоляции транзакций _repeatable read_ не позволяет просматривать незафиксированные до начала транзакции изменения, внесённые другими транзакциями.

**Сессия #1** - завершаем транзакцию:
```
postgres=*# commit;
COMMIT
```

**Сессия #2** - повторяем выборку всех записей из таблицы _persons_:
```
postgres=*# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  3 | sergey     | sergeev
(3 строки)
```

Во вновь полученной выборке мы по прежнему не видим новую строку, добавленную в первой сессии, т.к. транзакция в первой сессии завершена (зафиксирована), а в текущей сессии транзакция продолжается (не зафиксирована).

**Сессия #2** - завершаем транзакцию:
```
postgres=*# commit;
COMMIT
```

**Сессия #2** - повторяем выборку всех записей из таблицы _persons_:
```
postgres=# select* from persons;
 id | first_name | second_name
----+------------+-------------
  1 | ivan       | ivanov
  2 | petr       | petrov
  3 | sergey     | sergeev
  4 | sveta      | svetova
(4 строки)

postgres=*# commit;
COMMIT
```

Во вновь полученной выборке мы уже видим новую строку, добавленную в первой сессии, т.к. транзакция в первой сессии завершена (зафиксирована) и после этого в текущей сессии начата новая транзакция.

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
