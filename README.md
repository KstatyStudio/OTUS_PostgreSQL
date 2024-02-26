## Курс "PostgreSQL для администраторов баз данных и разработчиков"

## Занятие 7 "Логический уровень PostgreSQL"

### Домашнее задание
Работа с базами данных, пользователями и правами

### Исходные данные
ВМ (облако): Ubuntu 22.04 

### Решение

**1.** - Устанавливаем PostgreSQL 13:
```
devops@vmotus07:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-13
```

**2.** - Запускаем _psql_ под пользователем _postgres_, создаём базу данных _testdb_:
```

```







<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
