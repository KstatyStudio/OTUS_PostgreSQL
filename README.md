## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 11 "Настройка PostgreSQL"

### Домашнее задание
Нагрузочное тестирование и тюнинг PostgreSQL

### Исходные данные
ВМ (облако): 2 ядра, 2Гб, HDD 10Гб, Ubuntu 22.04, PostgreSQL 15

### Решение

**1.** - Настроим кластер PostgreSQL 15 на максимальную производительность не обращая внимание на возможные проблемы с надежностью в случае аварийной перезагрузки виртуальной машины.
Увеличим память, буферы и включим асинхронный режим записи на диск журнала предзаписи:
```
devops@vmotus11:~$ sudo -u postgres psql
psql (15.6 (Ubuntu 15.6-1.pgdg22.04+1))
Type "help" for help.

postgres=# alter system set maintenance_work_mem='512MB';
ALTER SYSTEM

postgres=# alter system set work_mem='6553kB';
ALTER SYSTEM

postgres=# alter system set shared_buffers='1GB';
ALTER SYSTEM

postgres=# alter system set wal_buffers='16MB';
ALTER SYSTEM

postgres=# alter system set synchronous_commit=off;
ALTER SYSTEM

postgres=# select pg_reload_conf();
 pg_reload_conf
----------------
 t
(1 row)
postgres=# \q

devops@vmotus11:~$ sudo systemctl restart postgresql 

devops@vmotus11:~$ sudo su postgres
```

**2.** - Проведём нагрузочное тестирование.

Cоздаём базу данных для тестов (инициализируем и заполняем тестовыми данными утилитой _pgbench_):
```
postgres@vmotus09:/home/devops$ pgbench -i postgres
dropping old tables...
creating tables...
generating data (client-side)...
100000 of 100000 tuples (100%) done (elapsed 0.17 s, remaining 0.00 s)
vacuuming...
creating primary keys...
done in 2.88 s (drop tables 1.08 s, create tables 0.49 s, client-side generate 0.28 s, vacuum 0.15 s, primary keys 0.87 s).
```

Запускаем тест на 10 минут:
```

```







<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
