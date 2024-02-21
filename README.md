## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 6 "Физический уровень PostgreSQL"

### Домашнее задание
Установка и настройка PostgreSQL

### Исходные данные

Яндекс.Облако

Рабочая машина Windows10, MobaXterm


### Решение

**1. Яндекс.Облако** - создаём две виртуальные машины (Ubuntu 22.04):

ВМ №1 - vmotus

ВМ №2 - vmsecond

![yc-vm2.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/be2963fe0968e0e493fc82eadfc41fba6575a43d/yc-vm2.png)


**2. ВМ №1** - устанавливаем PostgreSQL:
```
devops@vmotus:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14
```

Проверяем:
```
devops@vmotus:~$ sudo -u postgres pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```

Запускаем _psql_ под пользователем _postgres_:
```
devops@vmotus:~$ sudo su postgres

postgres@vmotus:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.
```

Создаём базу данных _app_ и подключаемся к ней:
```
postgres=# create database app;
CREATE DATABASE

postgres=# \c app
You are now connected to database "app" as user "postgres".
```

Создаём таблицу _test_ и заполняем её, выходим из _psql_:
```
app=# create table test (c1 text);
CREATE TABLE

app=# insert into test values ('1');
INSERT 0 1

app=# \q

postgres@vmotus:/home/devops$ exit
exit
```

Останавливаем PostgreSQL:
```
devops@vmotus:~$ sudo -u postgres pg_ctlcluster 14 main stop
Warning: stopping the cluster using pg_ctlcluster will mark the systemd unit as failed. Consider using systemctl:
  sudo systemctl stop postgresql@14-main

devops@vmotus:~$ sudo systemctl stop postgresql@14-main
```

Проверяем:
```
devops@vmotus:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 down   postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```

**3. Яндекс.Облако** - создаём новый диск HDD 10 Gb:
![yc-hdd.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/268b8bbc03ce84bc19458d5cd27d7b68b7c5118f/yc-hdd.png)

Останавливаем ВМ №1 (_vmotus_) и подключаем новый диск:

![yc-hdd-vm.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/268b8bbc03ce84bc19458d5cd27d7b68b7c5118f/yc-hdd-vm.png)

Запускаем ВМ №1 (_vmotus_).










<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>

