-- JSONB — двоичная разновидность формата JSON, у которой пробелы удаляются, сортировка объектов не сохраняется, вместо этого они хранятся наиболее оптимальным
--  образом, и сохраняется только последнее значение для ключей-дубликатов. JSONB обычно является предпочтительным форматом, поскольку требует меньше места для
--   объектов, может быть проиндексирован и обрабатывается быстрее, так как не требует повторного синтаксического анализа.

-- 1)Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). 

copy (select to_json(players.*) from players)
to '/tmp/players.json';

copy(select array_to_json(array_agg(row_to_json(t))) as "players"
    from players as t)
  to '/tmp/players.json';

-- 2)Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.
create temporary table json_import (values text);
copy json_import from '/tmp/players.json';

create table players_json(
    PLAYER_NAME TEXT, 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
);

insert into players_json("player_name", "team_id", "player_id")
select  j->>'player_name' as player_name,
CAST(j->>'team_id' as integer) as team_id,
CAST(j->>'player_id' as integer) as player_id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'player_name' is not null ;
select * from players_json;

'

-- 3) Создать таблицу, в которой будет атрибут(-ы) с типом XML или JSON, или
-- добавить атрибут с типом XML или JSON к уже существующей таблице.
-- Заполнить атрибут правдоподобными данными с помощью команд INSERT
-- или UPDATE. 

drop table json_table;
create table json_table(
    player_id serial primary key,
    name varchar(40) not null,
    json_column json
);

insert into json_table(name, json_column) values 
    ('Leo Tomson', '{"age": 22, "team": "MIL"}'::json),
    ('Stive Accer', '{"age": 30, "team": "MIL"}'::json),
    ('Sandro Qwerty', '{"age": 19, "team": "ALW"}'::json);

select * from json_table;

-- 4. Выполнить следующие действия:
-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- 3. Выполнить проверку существования узла или атрибута
-- 4. Изменить XML/JSON документ
-- 5. Разделить XML/JSON документ на несколько строк по узлам

-- 1. Извлечь XML/JSON фрагмент из XML/JSON документа
--Извлекаю всех игроков, чьё имя начинается на A
drop table json_import;
drop table players_json_frg;

create temporary table json_import (values text);
copy json_import from '/tmp/players.json';

create table players_json_frg(
    PLAYER_NAME TEXT, 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
);

insert into players_json_frg("player_name", "team_id", "player_id")
select  j->>'player_name' as player_name,
CAST(j->>'team_id' as integer) as team_id,
CAST(j->>'player_id' as integer) as player_id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'player_name' is not null and j->>'player_name' like 'A%';
select * from players_json_frg;

'

-- 2. Извлечь значения конкретных узлов или атрибутов XML/JSON документа
-- 3. Выполнить проверку существования узла или атрибута
--проверяет на null 
-- данные о игроке c id 1628372
drop table players_json_frg;
create table players_json_frg(
    PLAYER_NAME TEXT, 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
);

insert into players_json_frg("player_name", "team_id", "player_id")
select  j->>'player_name' as player_name,
CAST(j->>'team_id' as integer) as team_id,
CAST(j->>'player_id' as integer) as player_id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'player_name' is not null and j->>'player_id' = '1628372';
select * from players_json_frg;

'

-- 4. Изменить XML/JSON документ

drop table json_import;
drop table players_json_frg;

create temporary table json_import (values text);
copy json_import from '/tmp/players.json';

create table players_json_frg(
    PLAYER_NAME TEXT, 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
);

insert into players_json_frg("player_name", "team_id", "player_id")
select  j->>'player_name' as player_name,
CAST(j->>'team_id' as integer) as team_id,
CAST(j->>'player_id' as integer) as player_id
from   (
           select json_array_elements(replace(values,'\','\\')::json) as j 
           from   json_import
       ) a where j->'player_name' is not null;
select * from players_json_frg;


update players_json_frg
set player_name = ' new_name'
where player_id = 202711;

select * from players_json_frg;

'

copy(select array_to_json(array_agg(row_to_json(t))) as "players"
    from players_json_frg as t)
  to '/tmp/players.json';

-- 5. Разделить XML/JSON документ на несколько строк по узлам
drop table json_table;
drop table parsed;
create table json_table(
    player_id serial primary key,
    name varchar(40) not null,
    json_column json
);


create table parsed(
    player_id serial primary key,
    name varchar(40) not null,
    age int,
    test json
);
insert into json_table(name, json_column) values 
    ('Leo Tomson', '[{"age": 22, "team": "MIL"}]'::json),
    ('Stive Accer', '[{"age": 30, "team": "MIL"}]'::json),
    ('Sandro Qwerty', '[{"age": 19, "team": "ALW"}]'::json);

select * from json_table;


insert into parsed (name, age, test)
select name, (j.items->>'age')::integer, items #- '{age}'
from json_table, jsonb_array_elements(json_column::jsonb) j(items);
select * from parsed;