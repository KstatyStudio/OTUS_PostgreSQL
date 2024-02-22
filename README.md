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

![yc-vm3.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/b04935f6a9e44419f03f63cdeef8661437396b3b/yc-vm3.png)

**4. ВМ №1** - проверяем, что новый диск виден в системе:
```
devops@vmotus:~$ sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME   FSTYPE    SIZE MOUNTPOINT        LABEL
loop0  squashfs 63.9M /snap/core20/2105
loop1  squashfs 63.9M /snap/core20/2182
loop2  squashfs   87M /snap/lxd/26975
loop3  squashfs   87M /snap/lxd/27037
loop4           49.8M /snap/snapd/18357
loop5           40.4M /snap/snapd/20671
vda               18G
├─vda1             1M
└─vda2 ext4       18G /
vdb                5G
```

Новый диск определился как _vdb_.

Создаём раздел на новом диске:
```
devops@vmotus:~$ sudo fdisk /dev/vdb

Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x96f9667a.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1):
First sector (2048-10485759, default 2048):
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-10485759, default 10485759):

Created a new partition 1 of type 'Linux' and of size 5 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

Форматируем новый раздел в EXT4:
```
devops@vmotus:~$ sudo mkfs.ext4 /dev/vdb1
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 1310464 4k blocks and 327680 inodes
Filesystem UUID: 9f2795fc-5b02-4f23-b930-917848b1b26b
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done
Writing inode tables: done
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done
```

Создаём папку _/mnt/pgsql_ и монтируем в неё новый раздел:
```
devops@vmotus:~$ sudo mkdir /mnt/pgsql

devops@vmotus:~$ sudo mount /dev/vdb1 /mnt/pgsql
```

Проверяем:
```
devops@vmotus:~$ sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME   FSTYPE    SIZE MOUNTPOINT        LABEL
loop0  squashfs 63.9M /snap/core20/2105
loop1  squashfs 63.9M /snap/core20/2182
loop2  squashfs   87M /snap/lxd/26975
loop3  squashfs   87M /snap/lxd/27037
loop4           49.8M /snap/snapd/18357
loop5           40.4M /snap/snapd/20671
vda               18G
├─vda1             1M
└─vda2 ext4       18G /
vdb                5G
└─vdb1 ext4        5G /mnt/pgsql
```

Разрешаем запись на диск всем пользователям системы:
```
devops@vmotus:~$ sudo chmod a+w /mnt/pgsql
```

Назаначаем владельцем диска пользователя _postgres_:
```
devops@vmotus:~$ sudo chown -R postgres:postgres /mnt/pgsql/
```

**5. ВМ №1** - переносим папку _/var/lib/postgresql/14_ на новый диск:
```
devops@vmotus:~$ sudo mv /var/lib/postgresql/14 /mnt/pgsql
```

Запускаем кластер PostgreSQL:
```
devops@vmotus:~$ sudo -u postgres pg_ctlcluster 14 main start
Error: /var/lib/postgresql/14/main is not accessible or does not exist
```

В результате получаем ошибку, т.к. PostgreSQL не в курсе того, что служебные каталоги были перемещены, он ищет их по стандартному пути.
Открываеми в текстовом редакторе конфигурационный файл PostgreSQL:
```
devops@vmotus:~$ sudo nano /etc/postgresql/14/main/postgresql.conf
```
В разделе _FILE LOCATIONS_ изменяем путь к каталогу данных:
```
#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------

# The default values of these variables are driven from the -D command-line
# option or PGDATA environment variable, represented here as ConfigDir.

data_directory = '/mnt/pgsql/14/main'           # use data in another directory
                                                # (change requires restart)
```

Сохраняем изменения и перезапускаем PostgreSQL:
```
devops@vmotus:~$ sudo systemctl restart postgresql
```

Запускаем _psql_ под пользователем _postgres_, подключаемся к базе данных _app_ и проверяем наличие ранее созданной таблицы _test_:
```
devops@vmotus:~$ sudo su postgres
postgres@vmotus:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c app
You are now connected to database "app" as user "postgres".
app=# select* from test;
 c1
----
 1
(1 row)

app=# \q

postgres@vmotus:/home/devops$ exit
```

Данные кластера PostgreSQL перенесены на новый диск и доступны для использования.

**6. Яндекс.Облако** - перемонтируем новый диск на ВМ №2 (_vmsecond_):
Останавливаем виртуальные машины ВМ №1 (_vmotus_) и ВМ №2 (_vmsecond_). В свойствах ВМ №1 (_vmotus_) отсоединяем диск _hdd10gb_.
![yc-hdd-vm2.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/0628b9575dfd3e3393d85f023843d0ec8be6356e/yc-hdd-vm2.png)

Высвобожденный диск присоединяем к ВМ №2 (_vmsecond_):

![yc-hdd-vm3.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/0628b9575dfd3e3393d85f023843d0ec8be6356e/yc-hdd-vm3.png)

Запускаем ВМ №2 (_vmsecond_):

![yc-vm4.png](https://raw.githubusercontent.com/KstatyStudio/OTUS_PostgreSQL/0628b9575dfd3e3393d85f023843d0ec8be6356e/yc-vm4.png)

**7. ВМ №2** - проверяем, что новый диск виден в системе:
```
devops@vmsecond:~$ sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME   FSTYPE     SIZE MOUNTPOINT        LABEL
loop0  squashfs  63.3M /snap/core20/1822
loop1  squashfs 111.9M /snap/lxd/24322
loop2  squashfs  63.9M /snap/core20/2182
loop3  squashfs    87M /snap/lxd/27037
loop4  squashfs  49.8M /snap/snapd/18357
loop5  squashfs  40.4M /snap/snapd/20671
vda                10G
├─vda1              1M
└─vda2 ext4        10G /
vdb                 5G
└─vdb1 ext4         5G
```

Подключённый диск определился как _vdb_. Диск содержит раздел _vdb1_ (файловая система EXT4).
Создаём папку _/mnt/pgsql_ и монтируем в неё раздел _vdb1_:
```
devops@vmsecond:~$ sudo mkdir /mnt/pgsql

devops@vmsecond:~$ sudo mount /dev/vdb1 /mnt/pgsql
``` 

Проверяем:
```
devops@vmsecond:~$ sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
NAME   FSTYPE     SIZE MOUNTPOINT        LABEL
loop0  squashfs  63.3M /snap/core20/1822
loop1  squashfs 111.9M /snap/lxd/24322
loop2  squashfs  63.9M /snap/core20/2182
loop3  squashfs    87M /snap/lxd/27037
loop4  squashfs  49.8M /snap/snapd/18357
loop5  squashfs  40.4M /snap/snapd/20671
vda                10G
├─vda1              1M
└─vda2 ext4        10G /
vdb                 5G
└─vdb1 ext4         5G /mnt/pgsql
```

Проверяем содержимое подключённого диска:
```
devops@vmsecond:~$ ls -l /mnt/pgsql
total 20
drwxr-xr-x 3 114 120  4096 Feb 21 13:29 14
drwx------ 2 114 120 16384 Feb 22 06:48 lost+found
devops@vmsecond:~$ sudo ls -l /mnt/pgsql
total 20
drwxr-xr-x 3 114 120  4096 Feb 21 13:29 14
drwx------ 2 114 120 16384 Feb 22 06:48 lost+found
devops@vmsecond:~$ sudo ls -l /mnt/pgsql/14
total 4
drwx------ 19 114 120 4096 Feb 22 07:48 main

devops@vmsecond:~$ sudo ls -l /mnt/pgsql/14/main
total 80
drwx------ 6 114 120 4096 Feb 21 13:37 base
drwx------ 2 114 120 4096 Feb 22 07:25 global
drwx------ 2 114 120 4096 Feb 21 13:29 pg_commit_ts
drwx------ 2 114 120 4096 Feb 21 13:29 pg_dynshmem
drwx------ 4 114 120 4096 Feb 22 07:48 pg_logical
drwx------ 4 114 120 4096 Feb 21 13:29 pg_multixact
drwx------ 2 114 120 4096 Feb 21 13:29 pg_notify
drwx------ 2 114 120 4096 Feb 21 13:29 pg_replslot
drwx------ 2 114 120 4096 Feb 21 13:29 pg_serial
drwx------ 2 114 120 4096 Feb 21 13:29 pg_snapshots
drwx------ 2 114 120 4096 Feb 22 07:48 pg_stat
drwx------ 2 114 120 4096 Feb 21 13:29 pg_stat_tmp
drwx------ 2 114 120 4096 Feb 21 13:29 pg_subtrans
drwx------ 2 114 120 4096 Feb 21 13:29 pg_tblspc
drwx------ 2 114 120 4096 Feb 21 13:29 pg_twophase
-rw------- 1 114 120    3 Feb 21 13:29 PG_VERSION
drwx------ 3 114 120 4096 Feb 21 13:29 pg_wal
drwx------ 2 114 120 4096 Feb 21 13:29 pg_xact
-rw------- 1 114 120   88 Feb 21 13:29 postgresql.auto.conf
-rw------- 1 114 120  121 Feb 22 07:24 postmaster.opts

devops@vmsecond:~$ sudo ls -l /mnt/pgsql/14/main/base
total 16
drwx------ 2 114 120 4096 Feb 22 07:24 1
drwx------ 2 114 120 4096 Feb 21 13:29 13760
drwx------ 2 114 120 4096 Feb 22 07:25 13761
drwx------ 2 114 120 4096 Feb 22 07:25 16384
```

Устанавливаем PostgreSQL:
```
devops@vmsecond:~$ sudo apt update && sudo apt upgrade -y -q && sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add - && sudo apt-get update && sudo apt -y install postgresql-14
```

Проверяем:
```
devops@vmsecond:~$ pg_lsclusters
Ver Cluster Port Status Owner    Data directory              Log file
14  main    5432 online postgres /var/lib/postgresql/14/main /var/log/postgresql/postgresql-14-main.log
```

Останавливаем PostgreSQL:
```
devops@vmsecond:~$ sudo systemctl stop postgresql
```

Изменяем путь к каталогу данных в конфигурации PostgreSQL. Открываем файл _/etc/postgresql/14/main/postgresql.conf_:
```
devops@vmsecond:~$ sudo nano /etc/postgresql/14/main/postgresql.conf
```

Изменяем параметр "data_directory"
```
#------------------------------------------------------------------------------
# FILE LOCATIONS
#------------------------------------------------------------------------------

# The default values of these variables are driven from the -D command-line
# option or PGDATA environment variable, represented here as ConfigDir.

data_directory = '/mnt/pgsql/14/main'           # use data in another directory
                                                # (change requires restart)
```

Сохраняем. Запускаем PostgreSQL:
```
devops@vmsecond:~$ sudo systemctl start postgresql
```

Запускаем _psql_ под пользователем _postgres_, подключаемся к базе данных _app_ и проверяем наличие ранее созданной таблицы _test_ и её содержание:
```
devops@vmsecond:~$ sudo su postgres
postgres@vmsecond:/home/devops$ psql
psql (14.11 (Ubuntu 14.11-1.pgdg22.04+1))
Type "help" for help.

postgres=# \c app
You are now connected to database "app" as user "postgres".
app=# \d
        List of relations
 Schema | Name | Type  |  Owner
--------+------+-------+----------
 public | test | table | postgres
(1 row)

app=# select* from test;
 c1
----
 1
(1 row)

app=# \q
postgres@vmsecond:/home/devops$ exit
```

Данные кластера PostgreSQL перенесены на новую ВМ и доступны для использования.

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>

