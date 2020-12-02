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


