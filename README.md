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
Стоимость выполнения запроса оценивается в 209 условных единиц.

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
Оценка стоимости выполнения запроса при использовании индекса снизилась с 209 до 8.30 - более чем в 25 раз.

**2. - Создание индекса для полнотекстового поиска:**  

Создаём таблицу _commandtbl_ с автоматически заполняющимся полем _content_tsvector_ для полнотекстового поиска и заполняем тестовыми данными:
```
indexdb=# create table commandtbl (id serial primary key, cmd text, content text, content_tsvector tsvector generated always as (to_tsvector('english', content)) stored);
CREATE TABLE

indexdb=# insert into commandtbl (cmd, content) values ('-s, --host host-name-or-IP', 'Specify host name or IP address of a host.'),
('-p, --port port-number', 'Specify port number of agent running on the host. Default is 10050.'),
('-I, --source-address IP-address', 'Specify source IP address.'),
('-t, --timeout seconds', 'Specify timeout. Valid range: 1-30 seconds (default: 30)'),
('-k, --key item-key', 'Specify key of item to retrieve value for.'),
('--tls-connect value', 'How to connect to agent. Values:'),
('unencrypted', 'connect without encryption (default)'),
('psk', 'connect using TLS and a pre-shared key'),
('cert', 'connect using TLS and a certificate'),
('--tls-ca-file CA-file', 'Full pathname of a file containing the top-level CA(s) certificates for peer certificate verification.'),
('--tls-crl-file CRL-file', 'Full pathname of a file containing revoked certificates.'),
('--tls-agent-cert-issuer cert-issuer', 'Allowed agent certificate issuer.'),
('--tls-agent-cert-subject cert-subject', 'Allowed agent certificate subject.'),
('--tls-cert-file cert-file', 'Full pathname of a file containing the certificate or certificate chain.'),
('--tls-key-file key-file', 'Full pathname of a file containing the private key.'),
('--tls-psk-identity PSK-identity', 'PSK-identity string.'),
('--tls-psk-file PSK-file', 'Full pathname of a file containing the pre-shared key.'),
('--tls-cipher13 cipher-string', 'Cipher string for OpenSSL 1.1.1 or newer for TLS 1.3. Override the default ciphersuite selection criteria. This option is not available if OpenSSL version is less than 1.1.1.'),
('--tls-cipher cipher-string', 'GnuTLS priority string (for TLS 1.2 and up) or OpenSSL cipher string (only for TLS 1.2). Override the default ciphersuite selection criteria.'),
('-h, --help', 'Display this help and exit.'),
('-V, --version', 'Output version information and exit.');
INSERT 0 21
```

Проверяем:
```
indexdb=# select id, cmd, content, content_tsvector from commandtbl;
 id |                  cmd                  |                                                                                    content                                                                                     |                                                                                        content_tsvector
----+---------------------------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  1 | -s, --host host-name-or-IP            | Specify host name or IP address of a host.                                                                                                                                     | 'address':6 'host':2,9 'ip':5 'name':3 'specifi':1
  2 | -p, --port port-number                | Specify port number of agent running on the host. Default is 10050.                                                                                                            | '10050':12 'agent':5 'default':10 'host':9 'number':3 'port':2 'run':6 'specifi':1
  3 | -I, --source-address IP-address       | Specify source IP address.                                                                                                                                                     | 'address':4 'ip':3 'sourc':2 'specifi':1
  4 | -t, --timeout seconds                 | Specify timeout. Valid range: 1-30 seconds (default: 30)                                                                                                                       | '-30':6 '1':5 '30':9 'default':8 'rang':4 'second':7 'specifi':1 'timeout':2 'valid':3
  5 | -k, --key item-key                    | Specify key of item to retrieve value for.                                                                                                                                     | 'item':4 'key':2 'retriev':6 'specifi':1 'valu':7
  6 | --tls-connect value                   | How to connect to agent. Values:                                                                                                                                               | 'agent':5 'connect':3 'valu':6
  7 | unencrypted                           | connect without encryption (default)                                                                                                                                           | 'connect':1 'default':4 'encrypt':3 'without':2
  8 | psk                                   | connect using TLS and a pre-shared key                                                                                                                                         | 'connect':1 'key':9 'pre':7 'pre-shar':6 'share':8 'tls':3 'use':2
  9 | cert                                  | connect using TLS and a certificate                                                                                                                                            | 'certif':6 'connect':1 'tls':3 'use':2
 10 | --tls-ca-file CA-file                 | Full pathname of a file containing the top-level CA(s) certificates for peer certificate verification.                                                                         | 'ca':11 'certif':13,16 'contain':6 'file':5 'full':1 'level':10 'pathnam':2 'peer':15 'top':9 'top-level':8 'verif':17
 11 | --tls-crl-file CRL-file               | Full pathname of a file containing revoked certificates.                                                                                                                       | 'certif':8 'contain':6 'file':5 'full':1 'pathnam':2 'revok':7
 12 | --tls-agent-cert-issuer cert-issuer   | Allowed agent certificate issuer.                                                                                                                                              | 'agent':2 'allow':1 'certif':3 'issuer':4
 13 | --tls-agent-cert-subject cert-subject | Allowed agent certificate subject.                                                                                                                                             | 'agent':2 'allow':1 'certif':3 'subject':4
 14 | --tls-cert-file cert-file             | Full pathname of a file containing the certificate or certificate chain.                                                                                                       | 'certif':8,10 'chain':11 'contain':6 'file':5 'full':1 'pathnam':2
 15 | --tls-key-file key-file               | Full pathname of a file containing the private key.                                                                                                                            | 'contain':6 'file':5 'full':1 'key':9 'pathnam':2 'privat':8
 16 | --tls-psk-identity PSK-identity       | PSK-identity string.                                                                                                                                                           | 'ident':3 'psk':2 'psk-ident':1 'string':4
 17 | --tls-psk-file PSK-file               | Full pathname of a file containing the pre-shared key.                                                                                                                         | 'contain':6 'file':5 'full':1 'key':11 'pathnam':2 'pre':9 'pre-shar':8 'share':10
 18 | --tls-cipher13 cipher-string          | Cipher string for OpenSSL 1.1.1 or newer for TLS 1.3. Override the default ciphersuite selection criteria. This option is not available if OpenSSL version is less than 1.1.1. | '1.1.1':5,28 '1.3':10 'avail':21 'cipher':1 'ciphersuit':14 'criteria':16 'default':13 'less':26 'newer':7 'openssl':4,23 'option':18 'overrid':11 'select':15 'string':2 'tls':9 'version':24
 19 | --tls-cipher cipher-string            | GnuTLS priority string (for TLS 1.2 and up) or OpenSSL cipher string (only for TLS 1.2). Override the default ciphersuite selection criteria.                                  | '1.2':6,16 'cipher':11 'ciphersuit':20 'criteria':22 'default':19 'gnutl':1 'openssl':10 'overrid':17 'prioriti':2 'select':21 'string':3,12 'tls':5,15
 20 | -h, --help                            | Display this help and exit.                                                                                                                                                    | 'display':1 'exit':5 'help':3
 21 | -V, --version                         | Output version information and exit.                                                                                                                                           | 'exit':5 'inform':3 'output':1 'version':2
(21 rows)
```

Создаём Gin индекс для столбца _content_tsvector_:
```
indexdb=# create index on commandtbl using gin(content_tsvector);
CREATE INDEX
```

Отключаем последовательное сканирование и проверяем полнотекстовый поиск - найдём команду, описание которой содержит слова _file_ и _Full_:
```
indexdb=# set enable_seqscan = off;
SET

indexdb=# select cmd, content from commandtbl where content_tsvector @@ to_tsquery('english', 'file & Full');
            cmd            |                                                content
---------------------------+--------------------------------------------------------------------------------------------------------
 --tls-ca-file CA-file     | Full pathname of a file containing the top-level CA(s) certificates for peer certificate verification.
 --tls-crl-file CRL-file   | Full pathname of a file containing revoked certificates.
 --tls-cert-file cert-file | Full pathname of a file containing the certificate or certificate chain.
 --tls-key-file key-file   | Full pathname of a file containing the private key.
 --tls-psk-file PSK-file   | Full pathname of a file containing the pre-shared key.
(5 rows)

indexdb=# explain select cmd, content from commandtbl where content_tsvector @@ to_tsquery('english', 'file & Full');
                                          QUERY PLAN
-----------------------------------------------------------------------------------------------
 Bitmap Heap Scan on commandtbl  (cost=12.00..16.01 rows=1 width=64)
   Recheck Cond: (content_tsvector @@ '''file'' & ''full'''::tsquery)
   ->  Bitmap Index Scan on commandtbl_content_tsvector_idx  (cost=0.00..12.00 rows=1 width=0)
         Index Cond: (content_tsvector @@ '''file'' & ''full'''::tsquery)
(4 rows)

indexdb=# set enable_seqscan = on;
SET
```

**3. - Создание индекса для части таблицы:**  

Вернёмся к таблице _indextbl_ и удалим индекс по числовому полю:
```
indexdb=# drop index indextbl_id_idx;
DROP INDEX
```

Посмотрим распределение значений в столбце _checkout_:
```
indexdb=# select checkout, count(id) from indextbl group by 1;
 checkout | count
----------+-------
 f        |  9901
 t        |    99
(2 rows)
```
Из 10 тысяч в 9901 строке поле _checkout_ принимает значение _false_ и только в 99 строках значение _true_. Не имеет смысла индексировать по значению _false_, т.к. эти значения преобладают и с большой долей вероятности PostgeSQL будет применять сплошное сканирование (метод Seq Scan) при выборке по значению _false_.

Проверим это предположение. Проверяем план выполнения запроса по _false_ значениям:
```
indexdb=# explain select count(id) from indextbl where not checkout;
                            QUERY PLAN
-------------------------------------------------------------------
 Aggregate  (cost=208.75..208.76 rows=1 width=8)
   ->  Seq Scan on indextbl  (cost=0.00..184.00 rows=9901 width=4)
         Filter: (NOT checkout)
(3 rows)
```

Создаём индекс по полю _checkout_, при условии значения _false_:
```
indexdb=# create index on indextbl(checkout) where not checkout;
CREATE INDEX
```

Проверяем план выполнения запроса:
```
indexdb=# explain select count(id) from indextbl where not checkout;
                            QUERY PLAN
-------------------------------------------------------------------
 Aggregate  (cost=208.75..208.76 rows=1 width=8)
   ->  Seq Scan on indextbl  (cost=0.00..184.00 rows=9901 width=4)
         Filter: (NOT checkout)
(3 rows)
```
Создание индекса по полю _checkout_ с _false_ значением не привело к повышению производительности.  
Удаляем это вариант индекса:
```
indexdb=# drop index indextbl_checkout_idx;
DROP INDEX
```

Проверяем план выполнения запроса по _true_ значениям:
```
indexdb=# explain select count(id) from indextbl where checkout;
                           QUERY PLAN
-----------------------------------------------------------------
 Aggregate  (cost=184.25..184.26 rows=1 width=8)
   ->  Seq Scan on indextbl  (cost=0.00..184.00 rows=99 width=4)
         Filter: checkout
(3 rows)
```

Создаём индекс по полю _checkout_, при условии значения _true_:
```
indexdb=# create index on indextbl(checkout) where checkout;
CREATE INDEX
```

Проверяем план выполнения запроса:
```
indexdb=# explain select count(id) from indextbl where checkout;
                                          QUERY PLAN
----------------------------------------------------------------------------------------------
 Aggregate  (cost=42.19..42.20 rows=1 width=8)
   ->  Index Scan using indextbl_checkout_idx on indextbl  (cost=0.14..41.94 rows=99 width=4)
(2 rows)
```
После создания индекса по полю _checkout_ с _true_ значениями оценка стоимости выполнения запроса снизилась со 184.26 до 42.20 - более чем в 4 раза. 

**4. - Создание составного индекса:**

Удаляем индекс по полю _checkout_:
```
indexdb=# drop index indextbl_checkout_idx;
DROP INDEX
```

Смотрим планы выполнения запросов:
```
indexdb=# explain select count(id) from indextbl where id > 5000 and checkout;
                           QUERY PLAN
-----------------------------------------------------------------
 Aggregate  (cost=209.12..209.13 rows=1 width=8)
   ->  Seq Scan on indextbl  (cost=0.00..209.00 rows=49 width=4)
         Filter: (checkout AND (id > 5000))
(3 rows)

indexdb=# explain select count(id) from indextbl where id < 300 and not checkout;
                            QUERY PLAN
------------------------------------------------------------------
 Aggregate  (cost=209.74..209.75 rows=1 width=8)
   ->  Seq Scan on indextbl  (cost=0.00..209.00 rows=296 width=4)
         Filter: ((NOT checkout) AND (id < 300))
(3 rows)
```

Создаём индекс по полям _id_ и _checkout_:
```
indexdb=# create index on indextbl(id, checkout);
CREATE INDEX
```

Проверяем планы выполнения запросов:
```
indexdb=# explain select count(id) from indextbl where id > 5000 and checkout;
                                              QUERY PLAN
-------------------------------------------------------------------------------------------------------
 Aggregate  (cost=110.90..110.91 rows=1 width=8)
   ->  Index Only Scan using indextbl_id_checkout_idx on indextbl  (cost=0.29..110.77 rows=49 width=4)
         Index Cond: ((id > 5000) AND (checkout = true))
(3 rows)

indexdb=# explain select count(id) from indextbl where id < 300 and not checkout;
                                              QUERY PLAN
-------------------------------------------------------------------------------------------------------
 Aggregate  (cost=10.97..10.98 rows=1 width=8)
   ->  Index Only Scan using indextbl_id_checkout_idx on indextbl  (cost=0.29..10.23 rows=296 width=4)
         Index Cond: ((id < 300) AND (checkout = false))
(3 rows)
```
После создания составного индекса оценка стоимости выполнения запроса заметно снизилась.

<code><img height="30" src="https://cdn.jsdelivr.net/npm/simple-icons@3.13.0/icons/postgresql.svg"></code>
