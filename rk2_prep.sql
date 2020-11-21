
--==============================================================================================================================================================
CREATE TABLE employees (
	employee_id serial PRIMARY KEY,
	full_name VARCHAR NOT NULL,
	manager_id INT
);

INSERT INTO employees (
	employee_id,
	full_name,
	manager_id
)
VALUES
	(1, 'Michael North', NULL),
	(2, 'Megan Berry', 1),
	(3, 'Sarah Berry', 1),
	(4, 'Zoe Black', 1),
	(5, 'Tim James', 1),
	(6, 'Bella Tucker', 2),
	(7, 'Ryan Metcalfe', 2),
	(8, 'Max Mills', 2),
	(9, 'Benjamin Glover', 2),
	(10, 'Carolyn Henderson', 3),
	(11, 'Nicola Kelly', 3),
	(12, 'Alexandra Climo', 3),
	(13, 'Dominic King', 3),
	(14, 'Leonard Gray', 4),
	(15, 'Eric Rampling', 4),
	(16, 'Piers Paige', 7),
	(17, 'Ryan Henderson', 7),
	(18, 'Frank Tucker', 8),
	(19, 'Nathan Ferguson', 8),
	(20, 'Kevin Rampling', 8);
--==========================================================================

create table director(
	director_id serial not null primary key,
	director_name VARCHAR(30) not null,
	birth_year INTEGER,
	experience INTEGER,
	phone_num VARCHAR(15) unique
);

insert into director(director_name, birth_year, experience, phone_num)
values ('AAAA a', 1976, 20, '79876751240');

insert into director(director_name, birth_year, experience, phone_num)
values ('BBB A', 1980, 20, '79876751241');

insert into director(director_name, birth_year, experience, phone_num)
values ('CC a', 1976, 30, '79876751242');

insert into director(director_name, birth_year, experience, phone_num)
values ('DDD d', 1970, 15, '79876751243');

insert into director(director_name, birth_year, experience, phone_num)
values ('Ann Wqwer', 1950, 50, '79876751244');

insert into director(director_name, birth_year, experience, phone_num)
values ('AWer Aqwe', 1980, 10, '79876751245');

insert into director(director_name, birth_year, experience, phone_num)
values ('Aaa A', 1966, 30, '79876751246');

create table workshop(
	workshop_id serial not null primary key,
	director_id integer references director(director_id) not null,
	workshop_name varchar(30),
	found_year int,
	description varchar(50)
);

insert into workshop(director_id, workshop_name, found_year, description)
values (3, 'Crafty', 1920, 'Best of all time');

insert into workshop(director_id, workshop_name, found_year, description)
values (2, 'Craf', 1926, 'Aksksm');

insert into workshop(director_id, workshop_name, found_year, description)
values (1, 'Wood', 1929, 'best DB');

insert into workshop(director_id, workshop_name, found_year, description)
values (1, 'Musical school', 1830, 'Music inside');

insert into workshop(director_id, workshop_name, found_year, description)
values (2, 'Wert', 1940, 'AaaaBBB');

insert into workshop(director_id, workshop_name, found_year, description)
values (3, 'Ceramic', 1940, 'Wwer');

insert into workshop(director_id, workshop_name, found_year, description)
values (4, 'Gitar', 1980, 'Best of all time');

insert into workshop(director_id, workshop_name, found_year, description)
values (5, 'Crafty', 1920, 'Best of all time');

insert into workshop(director_id, workshop_name, found_year, description)
values (6, 'The star', 2000, ' all time');

insert into workshop(director_id, workshop_name, found_year, description)
values (6, 'AAAA', 2000, ' all time');

insert into workshop(director_id, workshop_name, found_year, description)
values (7, 'BBB', 2000, ' all time');


create table customer(
	customer_id serial not null primary key,
	customer_name varchar(30),
	adress varchar(30) unique,
	email varchar(30) unique
);

insert into customer(customer_name, adress, email)
values ('AAAAA', 'ASdd', 'AAAAA@mail.ru');

insert into customer(customer_name, adress, email)
values ('Anna C', 'Big R 4', 'anna@mail.ru');


insert into customer(customer_name, adress, email)
values ('Cabi', 'Rivers 4', 'cabit@mail.ru');


insert into customer(customer_name, adress, email)
values ('Eva Ser', 'Wqwrt 41', 'serevs@mail.ru');


insert into customer(customer_name, adress, email)
values('Mikle Nie', 'Ballwq 28', 'mikkle@mail.ru');

create table rel_work_cust(
	workshop_id integer references workshop(workshop_id) not null,
	customer_id integer references customer(customer_id) not null
);

insert into rel_work_cust(workshop_id, customer_id)
values (1, 1);


insert into rel_work_cust(workshop_id, customer_id)
values (2, 1);


insert into rel_work_cust(workshop_id, customer_id)
values (3, 1);


insert into rel_work_cust(workshop_id, customer_id)
values (4, 3);


insert into rel_work_cust(workshop_id, customer_id)
values (4, 2);


insert into rel_work_cust(workshop_id, customer_id)
values (5, 2);


insert into rel_work_cust(workshop_id, customer_id)
values (6, 3);


insert into rel_work_cust(workshop_id, customer_id)
values (8, 4);


insert into rel_work_cust(workshop_id, customer_id)
values (7, 5);


insert into rel_work_cust(workshop_id, customer_id)
values (9, 5);


insert into rel_work_cust(workshop_id, customer_id)
values (10, 1);


insert into rel_work_cust(workshop_id, customer_id)
values (11, 2);


--====================================================================================================================================================

-- 4) Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--Вывести названия кружков в которые ходили посетители в имени которых есть буква a.

SELECT workshop_name, found_year
From workshop
where workshop_name in(
	select workshop_name
	from workshop join rel_work_cust on workshop.workshop_id = rel_work_cust.workshop_id
	join customer on rel_work_cust.customer_id = customer.customer_id
	where customer_name like '%a%')

-- 5)Инструкция SELECT, использующая предикат EXISTS(Возвращает значение TRUE, если вложенный запрос содержит хотя бы одну строку.) с вложенным подзапросом.
SELECT * 
from workshop
where EXISTS(
	select *
	from workshop join rel_work_cust on workshop.workshop_id = rel_work_cust.workshop_id
	where rel_work_cust.customer_id <= 2
)

 --6)Инструкция SELECT, использующая предикат сравнения с квантором.
--вывести информацию о кружках где дата основания больше чем дата основания у кружка с id = 6
SELECT found_year, workshop_name 
from workshop
where found_year > ALL(
	select found_year
	from workshop
	where workshop_id = 6
)

--7)Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- AVG - Эта функция возвращает среднее арифметическое группы значений. Значения NULL она не учитывает.
--вывести средний стаж директоров
select AVG(experience) as avg_experience
from director

-- 8)Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
--вывести всех у кого опыт больше среднего арифметического
select *
from director
where experience > (select AVG(experience) from director)

-- 9)Инструкция SELECT, использующая простое выражение CASE
select *, 
	case experience
		WHEN '20' then 'Twentee'
		WHEN '30' then 'Old'
		ELSE 'ddd'
	end experience_description
from director

-- 10)Инструкция SELECT, использующая поисковое выражение CASE.
select *, 
	case
		WHEN experience <= 20 then 'Yong'
		WHEN experience > 30 then 'Old'
		ELSE 'Thirty'
	end experience_description
from director

-- 11)Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
create temp table
best_dir as
select *
from director

-- 12)Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
--Вывести информацию из rel_work_cust и customer_id, customer_name из customer гду customer_id < 3
select *
from rel_work_cust left join
(
select customer_id, customer_name
from customer
where customer_id < 3
) as cust_new on rel_work_cust.customer_id = cust_new.customer_id
where cust_new.customer_id is not null

--13) Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- вывести информацию о посетителях которые побывали в кружках, у директора которых стаж больше 20 лет

select *
from customer
where customer_id in(

	select customer_id
	from rel_work_cust
	where workshop_id in(

		select workshop_id
		from workshop
		where director_id in (

			select director_id
			from director
			where experience > 20
			)
		)
	)

-- 14) Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
--Вывести средний год основания кружков, посещённых посетителем с id >= 3.
select CAST(AVG(found_year) as INT), customer.customer_id
from workshop join rel_work_cust on rel_work_cust.workshop_id = workshop.workshop_id
join customer on customer.customer_id = rel_work_cust.customer_id
WHERE customer.customer_id >= 3
GROUP by customer.customer_id

-- 15)Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без HAVING.
select CAST(AVG(found_year) as INT), customer.customer_id
from workshop join rel_work_cust on rel_work_cust.workshop_id = workshop.workshop_id
join customer on customer.customer_id = rel_work_cust.customer_id
GROUP by customer.customer_id
HAVING customer.customer_id >= 3


--19)Инструкция UPDATE со скалярным подзапросом в предложении SET
UPDATE ranking
SET w =
(
SELECT AVG(w)
FROM ranking
WHERE team_id = 1610612749
)
WHERE team_id = 1610612749

-- 22) Инструкция SELECT, использующая простое обобщенное табличное выражение
--вывести средний год открытия посещённых посетителем кружков
with results(avg_year, customer_id)
as (
	select CAST(AVG(found_year) as INT), customer.customer_id
	FROM customer join rel_work_cust on rel_work_cust.customer_id = customer.customer_id
	join workshop on workshop.workshop_id = rel_work_cust.workshop_id
	GROUP BY customer.customer_id
)
select *
from results


----23)Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
-- Найти все пары кружок - посетитель начиня со второго кружка

with recursive rec_tab as (
	select customer_id, workshop_id
	from rel_work_cust
	where rel_work_cust.workshop_id = 2

	UNION
		select rel_work_cust.customer_id, rel_work_cust.workshop_id
		from rel_work_cust 
		join rec_tab ON rec_tab.workshop_id = rel_work_cust.customer_id
)
select *
from rec_tab

-- 24)Оконные функции. Использование конструкций MIN/MAX/AVG OVER()

-- Вывести информацию и номера строк с сортировкой по дате открытия каждого посещённого кружка каждого из посетителей.
SELECT workshop.workshop_name, customer.customer_name,  workshop.found_year,
ROW_NUMBER()
OVER (PARTITION BY customer.customer_id order by workshop.found_year) as row_num
FROM workshop join rel_work_cust on workshop.workshop_id = rel_work_cust.workshop_id
join customer on customer.customer_id = rel_work_cust.customer_id


--25)Оконные фнкции для устранения дублей
CREATE TABLE test( name VARCHAR NOT NULL, surname VARCHAR NOT NULL, age INTEGER);
INSERT INTO test (name, surname, age) VALUES 
('Ann', 'Kosenko', 12), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Ann', 'Kosenko', 12);

WITH test_deleted AS(DELETE FROM test RETURNING *),
test_inserted AS(SELECT name, surname, age, ROW_NUMBER() OVER(PARTITION BY name, surname, age ORDER BY name, surname, age) 
 				 rownum FROM test_deleted)INSERT INTO test SELECT name, surname, age
				 FROM test_inserted WHERE rownum = 1;
SELECT *
FROM test

--==============================================================
-- Хранимую процедуру доступа к метаданным  (название таблицы и размер)
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


--==============================================================
Создать хранимую процедуру с выходным параметром, которая выводит
список имен и параметров всех скалярных SQL функций пользователя
(функции типа 'FN') в текущей базе данных. Имена функций без параметров
не выводить. Имена и список параметров должны выводиться в одну строку.
Выходной параметр возвращает количество найденных функций.
Созданную хранимую процедуру протестировать. 

-- Получаем информацию о всех функциях
select proname, pronargs, prorettype, proargtypes
from pg_proc
where pronargs > 0; -- кол-во принимаемых аргументов

-- Хранимая процедура доступа к метаданным
-- Вывести имя функции и типы принимаемых значений
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


--=====================================================================
Создать хранимую процедуру с входным параметром – имя базы данных,
которая выводит имена ограничений CHECK и выражения SQL, которыми
определяются эти ограничения CHECK, в тексте которых на языке SQL
встречается предикат 'LIKE'. Созданную хранимую процедуру
протестировать. 



(не работает)
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

--delete from employees  where  full_name like '%a%';

-- Тестируем
-- Добавили ограничение с like 
alter table employees 
    add constraint a_in_name check ( full_name like '%a%');
-- Вызвали процедуру
DO
$$
    begin
        call get_like_constraints('rk2');
    end;
$$;
--=======================================================================================================
-- Создать хранимую процедуру с входным параметром – "имя таблицы",
-- которая удаляет дубликаты записей из указанной таблицы в текущей
-- базе данных. Созданную процедуру протестировать.

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

--================================================================================================
-- Создать хранимую процедуру с входным параметром – имя базы данных,
-- которая выводит имена ограничений CHECK и выражения SQL, которыми
-- определяются эти ограничения CHECK, в тексте которых на языке SQL
-- встречается предикат 'LIKE'. Созданную хранимую процедуру
-- протестировать.
create extension dblink;
create procedure likes_constraints(in db text) language plpgsql as $$
declare
	record_of_constraints record;
begin
	for record_of_constraints in
		select *
		from dblink(
			concat('dbname=', db, ' options=-csearch_path='),
			'select conname, consrc
			from pg_constraint
			where contype = ''c'' and (lower(consrc) like ''% like %'' or consrc like ''% ~~ %'')'
		)
		as t1(conname varchar, consrc varchar)
	loop
		raise info 'Name: %, src: %', record_of_constraints.conname, record_of_constraints.consrc;
	end loop;
end
$$;

-- test
alter table customers
	add constraint fullname_contains_e check (fullname like '%e%');

do $$ begin
		call likes_constraints('rk2');
end; $$;

