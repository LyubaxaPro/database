-- A
-- 1) Скалярная функция
--Пользовательские функции, которые возвращают одно значение(для каждого набора данных). 

create or replace function increment(i int) RETURNS int AS $$
        BEGIN
                RETURN i + 1;
        END;
$$ LANGUAGE plpgsql;

SELECT increment(id)
FROM Table1

create or replace function older_team() RETURNS int AS $$
    BEGIN
        RETURN (SELECT min(yearfounded) FROM teams);
    END;
$$ LANGUAGE plpgsql;




-- 2) Подставляемая табличная функция
--принимает входные параметры и в зависимости от этих параметров запускается обработка данных, которая возращает тот или иной набор данных. Нельзя использовать внутри функции операции обработки данных (Insert, Update, Delete) над физическими таблицами. Для хранения промежуточных результатов обработки данных можно использовать табличную переменную.
 --Временную таблицу нельзя создавать. Над табличной переменной можно выполнять действия INSERT, UPDATE, DELETE.

--Для функций на PL/pgSQL, возвращающих SETOF некий_тип, нужно действовать несколько по-иному.
--Отдельные элементы возвращаемого значения формируются командами RETURN NEXT или RETURN QUERY, а финальная команда RETURN без аргументов завершает выполнение функции.
  --RETURN NEXT используется как со скалярными, так и с составными типами данных.
 --Для составного типа результат функции возвращается в виде таблицы. RETURN QUERY добавляет результат выполнения запроса к результату функции.
  --RETURN NEXT и RETURN QUERY можно свободно смешивать в теле функции, в этом случае их результаты будут объединены.

--RETURN NEXT и RETURN QUERY не выполняют возврат из функции. Они просто добавляют строки в результирующее множество.
 --Затем выполнение продолжается со следующего оператора в функции. Успешное выполнение RETURN NEXT и RETURN QUERY формирует множество строк результата.
  --Для выхода из функции используется RETURN, обязательно без аргументов (или можно просто дождаться окончания выполнения функции).

-- Вывести информацию о комндах, созданых позже 1990 года
create or replace function get_teams(int) RETURNS SETOF teams  AS $$
    BEGIN
        RETURN QUERY( 
            SELECT *
            FROM teams
            WHERE teams.yearfounded > $1);
    END;
$$ LANGUAGE plpgsql;

SELECT *
FROM get_teams(1990);

-- 3) Многооператорная табличная функция
--Выведем команды, которые были собраны раньше всех(самые старые)
--Тело подставляемой табличной функции состоит из единственного оператора SELECT, 
--в то время как многооператорная табличная функция может состоять из любого числа операторов
-- CREATE_FUNCTION get_old_teams()
-- RETURNS TABLE(min_year SMALLINT, max_year SMALLINT, abbreviation text, nickname text, yearfounded int)
-- as $$
--     DECLARE
--         min int;
--     BEGIN
--     min := older_team();
--     insert into test_for_rec(id, name) values (12, "E");
--     return query (SELECT teams.in_year, teams.max_year, teams.abbreviation, teams.nickname, teams.yearfounded)
--             FROM teams
--             WHERE teams.yearfounded = min);
--     END
--     $$ language 'plpgsql';

-- SELECT * 
-- FROM get_old_teams()

--Выведем команды которые были собраны после 1990 года

drop function get_old_teams;
CREATE or replace FUNCTION get_old_teams()
RETURNS TABLE(min_year SMALLINT, max_year SMALLINT, abbreviation text, nickname text, yearfounded int)
as $$
    BEGIN
        CREATE TEMP table temp_tab(min_year SMALLINT, max_year SMALLINT, abbreviation text, nickname text, yearfounded int);

        insert into temp_tab(min_year, max_year, abbreviation, nickname, yearfounded)
        SELECT teams.min_year, teams.max_year, teams.abbreviation, teams.nickname, teams.yearfounded
                FROM teams
                WHERE teams.yearfounded > 1990;
        return query
        select * from temp_tab;
    END;
$$ language 'plpgsql';

SELECT * 
FROM get_old_teams()

--4) рекурсивная функция 
--вывести команды с интервалом в 10 лет по дате основания

drop function year_recursive(year int);
create or replace function year_recursive(year int)
returns setof teams
as $$
    begin
    return query (select *
    from teams
        where teams.yearfounded = year);
    if (year > 11) then
        return query
        select *
        from year_recursive(year - 10);
    end if;
    end
    $$ language 'plpgsql';

select * from year_recursive(2000);

-- Б - хранимые процедуры
-- 5) Хранимую процедуру без параметров или с параметрами
--Заменить в таблице t1 все A на C
create or replace function update_var (p_var char, p_new_var char) returns void
    as $$
    begin 
    update t1 
    set var1 = p_new_var
    where var1 = p_var;
    end;
    $$ language 'plpgsql';  

select * from update_var('A', 'C');
select *
from t1

-- 6) Рекурсивную хранимую процедуру или хранимую процедур с рекурсивным ОТВ

-- Вспомогательная таблица
create table test_for_rec 
(
    id int,
    name text
);

insert into test_for_rec  (id, name) values (1, 'A');
insert into test_for_rec  (id, name) values (2, 'B');
insert into test_for_rec  (id, name) values (3, 'c');
insert into test_for_rec  (id, name) values (4, 'D');
insert into test_for_rec  (id, name) values (5, 'A');
insert into test_for_rec  (id, name) values (6, 'B');
insert into test_for_rec  (id, name) values (7, 'c');
insert into test_for_rec  (id, name) values (8, 'D');

create or replace function recurse_update_name (p_id int, p_new_name text) returns void
    as $$
    begin 
    update test_for_rec 
    set name = p_new_name
    where test_for_rec.id = p_id;

    if (p_id > 2) then perform * 
    from recurse_update_name(p_id - 2, p_new_name);
    end if;
    end;
    $$ language 'plpgsql';  

select * from recurse_update_name(8, 'NEW_NAME');
select *
from test_for_rec

-- 7)Хранимую процедуру с курсором
-- Курсор PL / pgSQL позволяет инкапсулировать запрос и обрабатывать каждую отдельную строку за раз.
--Заменим одну аббревиатуру на другую
create or replace function update_abbreviation_cursor(p_abbreviation text, p_new_abbreviation text) returns void
as $$
    declare
        abbr_row record;
        cur cursor for
        select * from teams
        where teams.abbreviation = p_abbreviation;
    begin
        open cur;
        loop
            fetch cur into abbr_row;
            exit when not found;
            update teams 
            set abbreviation = p_new_abbreviation
            where teams.team_id = abbr_row.team_id;
        end loop;
        close cur;
    end;
    $$ language 'plpgsql';


select * from update_abbreviation_cursor('ATL','MIIIIL');
select * from teams

--8) Хранимую процедуру доступа к метаданным
-- Информационная схема состоит из набора представлений, содержащих информацию об объектах, определенных в текущей базе данных.
-- pg_relation_size принимает OID или имя таблицы, индекса или TOAST-таблицы и возвращает размер одного слоя этого отношения (в байтах). (Заметьте, что в большинстве случаев удобнее использовать более высокоуровневые функции pg_total_relation_size и pg_table_size, которые суммируют размер всех слоёв.)
 --С одним аргументом она возвращает размер основного слоя для данных заданного отношения.
-- desc - сортировка в порядке убывания
select table_name, count(*) as size
into my_tables
from information_schema.tables
where table_schema = 'public'
group by table_name;

select * from my_tables;

create or replace function table_size() returns void as
$$
declare
    cur cursor
    for select table_name, size
    from (
        select table_name,
        pg_relation_size(cast(table_name as varchar)) as size
        from information_schema.tables
        where table_schema = 'public'
        order by size desc
    ) AS tmp;
         row record;
begin
    open cur;
    loop
        fetch cur into row;
        exit when not found;
        raise notice '{table : %} {size : %}', row.table_name, row.size;
        update my_tables
        set size = row.size
        where my_tables.table_name = row.table_name;
    end loop;
    close cur;
end
$$ language plpgsql;

select * from  table_size();
select * from my_tables;


-- Триггеры
 --9) Триггер AFTER
create or replace function proc_after_trigger() returns trigger
    as $$
    begin 
    RAISE NOTICE 'Запись в таблицу test_for_rec: id(%), name(%)', new.id, new.name;
    return new;
    end;
    $$ language 'plpgsql';  
 
CREATE TRIGGER check_insert
after insert ON test_for_rec
for each row
EXECUTE PROCEDURE proc_after_trigger();

insert into test_for_rec(id, name)
values(6, 'ZZZ');

select * from test_for_rec

--10) Триггер INSTEAD OF
-- CREATE VIEW создаёт представление запроса. 
-- Создаваемое представление лишено физической материализации, поэтому указанный запрос будет выполняться при каждом обращении к представлению.
-- (Триггер INSTEAD OF доступен только для view)

create view test_view as
select *
from test_for_rec;

create or replace function proc_instead_of_trigger() returns trigger as
    $$
    begin
            
    insert into test_for_rec(id, name)
    values(new.id, new.name);
    RAISE NOTICE 'Запись в таблицу test_for_rec: id(%), name(%)', new.id, new.name;
        return new;
    end;
    $$ language 'plpgsql' ;


CREATE TRIGGER instead_of_ins_tr
INSTEAD OF INSERT ON test_view
FOR EACH ROW
EXECUTE PROCEDURE proc_instead_of_trigger();

insert into test_view (id, name)
values(12, 'dd');

--ЗАЩИТА
--мягкое удаление

create table test_soft_delete(
    id int,
    name char, 
    exists int
    );

insert into test_soft_delete(id, name, exists) values (1, 'A', 1);
insert into test_soft_delete(id, name, exists) values (2, 'B', 1);
insert into test_soft_delete(id, name, exists) values (3, 'A', 1);

create view test_soft_view as
select *
from test_soft_delete;

create or replace function soft_instead_of_trigger() returns trigger as
    $$
    begin
            
        update test_soft_delete
        set exists = 0
        where test_soft_delete.id = old.id;
        return old;
    end;
    $$ language 'plpgsql' ;


CREATE TRIGGER inst_of_del
INSTEAD OF DELETE ON test_soft_view
FOR EACH ROW
EXECUTE PROCEDURE soft_instead_of_trigger();

delete from test_soft_view where id = 1;
