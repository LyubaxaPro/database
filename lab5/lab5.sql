-- JSONB — двоичная разновидность формата JSON, у которой пробелы удаляются, сортировка объектов не сохраняется, вместо этого они хранятся наиболее оптимальным
--  образом, и сохраняется только последнее значение для ключей-дубликатов. JSONB обычно является предпочтительным форматом, поскольку требует меньше места для
--   объектов, может быть проиндексирован и обрабатывается быстрее, так как не требует повторного синтаксического анализа.

-- 1)Из таблиц базы данных, созданной в первой лабораторной работе, извлечь
-- данные в XML (MSSQL) или JSON(Oracle, Postgres). 

copy (select to_json(games.*) from games)
to '/tmp/games.json';

copy (select to_json(games.*) from players)
to '/tmp/players.json';

copy (select to_json(games.*) from games_details)
to '/tmp/games_details.json';

copy (select to_json(games.*) from ranking)
to '/tmp/ranking.json';

copy (select to_json(games.*) from teams)
to '/tmp/teams.json';

-- 2)Выполнить загрузку и сохранение XML или JSON файла в таблицу.
-- Созданная таблица после всех манипуляций должна соответствовать таблице
-- базы данных, созданной в первой лабораторной работе.

-- Функции SQL могут быть объявлены как принимающие переменное число аргументов, с условием, что все «необязательные» аргументы имеют один тип данных. 
-- Необязательные аргументы будут переданы такой функции в виде массива.
--  Для этого в объявлении функции последний параметр помечается как VARIADIC; при этом он должен иметь тип массива.
CREATE TABLE players_copy
(
    PLAYER_NAME TEXT CHECK(PLAYER_NAME != ''), 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0)
);

create unlogged table players_import (doc json);
copy players_import from '/tmp/players.json'


CREATE TABLE players_copy
(
    PLAYER_NAME TEXT CHECK(PLAYER_NAME != ''), 
    TEAM_ID INTEGER CHECK(TEAM_ID > 0),
    PLAYER_ID INTEGER CHECK(PLAYER_ID > 0)
);

insert into players_copy (player_name, team_id, player_id)
select p.*
from players_import l
  cross join lateral json_populate_recordset(null::players_copy, doc) as p
on conflict (player_id) do update 
  set player_name = excluded.player_name, 
      team_id = excluded.team_id;



select * from insert_from_json('{"player_name":"Bennet Davis","team_id":"1610612751","player_id":"201834"}',
							   'players_copy');



create or replace function insert_from_json(json text, tablename text)
returns void language plpgsql
as $$
begin
  execute
    replace(
      replace(
        regexp_replace(
          json,
          '("[^"]*"):"([^"]*)"',
          '''\2''', 'g'),
        '{', 
        format('insert into %s values (', tablename)),
      '}',
      ');');
end 
$$;

create or replace function json_parse(tablename text, path text)
returns int
as $$
    file = open(path, "r")
    f = tablename;
    f = chr(39) + f + chr(39)
    for s in file:
        s = chr(39) + s + chr(39)
        plpy.execute('select * from insert_from_json(' + s + ' ,' + f + ');')  
    return 0
$$ language plpython3u;

select * from json_parse('players_copy', '/tmp/players.json');
select * from players_copy