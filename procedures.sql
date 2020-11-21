----------------------------------------------------
--Вывести имя функции и типы принимаемых значений
----------------------------------------------------
create or replace procedure show_functions() as
$$
declare 
	cur cursor
	for select proname, proargtypes
	from (
		select proname, pronargs, prorettype, proargtypes
		from pg_proc
		where pronargs > 0
	) AS tmp;
	row record;
begin
	open cur;
	loop
		fetch cur into row;
		exit when not found;
		raise notice '{func_name : %} {args : %}', row.proname, row.proargtypes;
	end loop;
	close cur;
end
$$ language plpgsql;

call show_functions();


----------------------------------------------------
--Создать хранимую процедуру с выходным параметром, которая выводит
--список имен и параметров всех скалярных SQL функций пользователя
--(функции типа 'FN') в текущей базе данных. Имена функций без параметров
--не выводить. Имена и список параметров должны выводиться в одну строку.
--Выходной параметр возвращает количество найденных функций.
--Созданную хранимую процедуру протестировать.
----------------------------------------------------
CREATE PROCEDURE MyTables13 
@cnt int OUTPUT
AS  
BEGIN  
SELECT * FROM sys.all_objects
where type = 'FN'
SELECT @cnt = COUNT(*) FROM sys.all_objects
where type = 'FN'
END
GO

DECLARE @cnt int 
EXEC MyTables13 @cnt output
GO

PRINT 'Êîëè÷åñòâî ôóíêöèé: ' + CONVERT(VARCHAR, @cnt)


----------------------------------------------------
-- Создать хранимую процедуру с входным параметром – имя базы данных,
-- которая выводит имена ограничений CHECK и выражения SQL, которыми
-- определяются эти ограничения CHECK, в тексте которых на языке SQL
-- встречается предикат 'LIKE'. Созданную хранимую процедуру
-- протестировать.
----------------------------------------------------
create extension dblink;
create or replace procedure get_like_constraints(in data_base_name text)
    language plpgsql
as
$$
declare
    constraint_rec record;
begin
    for constraint_rec in select *
                          from dblink(concat('dbname=', data_base_name, ' options=-csearch_path='),
                                      'select conname, consrc
                                      from pg_constraint
                                      where contype = ''c''
                                          and (lower(consrc) like ''% like %'' or consrc like ''% ~~ %'')')
                                   as t1(con_name varchar, con_src varchar)
        loop
            raise info 'Name: %, src: %', constraint_rec.con_name, constraint_rec.con_src;
        end loop;
end
$$;

-- Тестируем
-- Добавили ограничение с like
alter table customers
    add constraint a_in_name check ( name like '%a%');
-- Вызвали процедуру
DO
$$
    begin
        call get_like_constraints('rk2');
    end;
$$;


----------------------------------------------------
-- Создать хранимую процедуру с входным параметром – "имя таблицы",
-- которая удаляет дубликаты записей из указанной таблицы в текущей
-- базе данных. Созданную процедуру протестировать.
----------------------------------------------------
create or replace procedure rem_duplicates(in t_name text)
    language plpgsql
as
$$
declare
    query text;
    col text;
    column_names text[];
begin
    query = 'delete from ' || t_name || ' where id in (' ||
                'select ' || t_name || '.id ' ||
                'from ' || t_name ||
                ' join (select id, row_number() over (partition by ';
    for col in select column_name from information_schema.columns where information_schema.columns.table_name=t_name loop
        query = query || col || ',';
    end loop;
    query = trim(trailing ',' from query);
    query = query || ') as rn from ' || t_name || ') as t on t.id = ' || t_name || '.id' ||
            ' where rn > 1)';
    raise notice '%', query;
    execute query;
end
$$;

-- Тестируем
-- Добавили дубликаты
insert into teacher(id, dep_id, name, grade, job)
select *
    from teacher
    where id < 5;

-- Вызвали процедуру
DO
$$
    begin
        call rem_duplicates('teacher');
    end;
$$;


----------------------------------------------------
﻿--Создать хранимую процедуру с входным параметром – имя таблицы,
--которая выводит сведения об индексах указанной таблицы в текущей базе
--данных. Созданную хранимую процедуру протестировать.
----------------------------------------------------
DROP PROCEDURE IF EXISTS getIdx;
CREATE PROCEDURE getIdx(n VARCHAR(30))
AS $$
DECLARE
	a INT;
	curRow RECORD;
	tblCurs REFCURSOR;
		
BEGIN
	OPEN tblCurs FOR
		EXECUTE 'SELECT indexname FROM pg_indexes WHERE tablename =' || n;
	LOOP
		FETCH tblCurs INTO curRow;
		EXIT WHEN NOT FOUND;

		RAISE NOTICE '%', curRow.indexname;
				
	END LOOP;
	CLOSE tblCurs;
END;
$$ LANGUAGE PLpgSQL;


CALL getIdx('Teacher');
