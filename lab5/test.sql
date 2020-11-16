create or replace function create_table_from_json(json text, tablename text)
returns void language plpgsql
as $$
begin
    execute
        replace(
            replace(
                regexp_replace(
                    json,
                    '("[^"]*"):("[^"]*")',
                    '    \1 text', 'g'),
                '{', 
                format('create table %s (', tablename)),
            '}',
            ');');
end 
$$;

create or replace function json_parse(tablename text, path text)
returns int
as $$
    file = open(path, "r")
    for s in file:
        plpy.execute("create_table_from_json('" + s + "', '" + tablename + ')")
        plpy.execute("insert_from_json('" + s + "', '" + tablename + ')")
    return 0
$$ language plpython3u;

select * from json_parse("\tmp\players.json", "players_copy");


create or replace function json_parse(tablename text, path text, variadic arr text[])
returns int
as $$
    file = open(path, "r")
    for s in file:
        plpy.execute("insert_from_json('" + s + "', '" + tablename + ')")  
    return 0
$$ language plpython3u;