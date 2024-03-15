## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 13 "Виды и устройство репликации в PostgreSQL. Практика применения"

### Домашнее задание
Репликация

### Исходные данные
ВМ# (облако): Ubuntu 22.04, PostgreSQL 14, PostgreSQL 16

SSH: 4 сессии

### Решение

**1.** - Устанавливаем сервер PostgreSQL 14:
```
devops@vmotus1:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14

      
```


Cоздаем базу данных _repldb_, таблицы _test_ для записи, _test2_ для запросов на чтение



**2.** - Устанавливаем и настраиваем сервер PostgreSQL 14 для запуска репликации:
```
devops@vmotus2:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14




```




















<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
