--2 вариант
create table work_kind(
	w_id serial primary key,
	name varchar(30) not null,
	expenditures int,
	equipment varchar(30)
);

insert into work_kind(name, expenditures, equipment)
	values 
	('music', 10, 'gitar'),
	('sport', 30, 'boots'), 
	('A_work', 40, 'A_eq'),
	('B_work', 5, 'B_eq'),
	('C_work', 100, 'C_eq'),
	('creator', 50, 'nano_eq'),
	('wild_work', 12, 'nano_cat'),
	('g_work', 1234, 'octocat'),
	('sea_work', 123, 'sea');

create table executor(
	e_id serial primary key,
	name varchar(30) not null,
	b_year int,
	expirience int,
	phone varchar(20) unique
);

insert into executor(name, b_year, expirience, phone)
	values
	('North A. A.', 1987, 10, '89886753420'),
	('Maer A. B.', 1986, 10, '89886753421'),
	('Erer D. B.', 1996,  5, '89886753422'),
	('Olger A. V.', 1976, 20, '89886753423'),
	('Olesar V. E.', 1956, 50, '89886753424'),
	('Wqer S. W.', 1987, 15, '89886753425');

create table w_e(
	w_id int references work_kind(w_id) not null,
	e_id int references executor(e_id) not null
);

insert into w_e(w_id, e_id)
	values
	(3, 6),
	(3, 6),
	(2, 1),
	(2, 2), 
	(1, 4),
	(4, 5),
	(4, 1),
	(5, 5),
	(5, 1),
	(6, 6),
	(6, 1),
	(7, 3),
	(8, 2),
	(9, 4);

create table customer(
	c_id serial primary key,
	name varchar(30) not null,
	b_year int,
	expirience int,
	phone varchar(20) unique
);


insert into customer(name, b_year, expirience, phone)
	values
	('Wert A. A.', 1977, 20, '79886753420'),
	('Aert A. B.', 1976, 10, '79886753421'),
	('Erwe D. B.', 1956,  50, '79886753422'),
	('Olerasf F. F.', 1976, 20, '79886753423'),
	('Olwds V. E.', 1960, 30, '79886753424'),
	('Olrt S. W.', 1967, 15, '79886753425'),
	('Iodl F. F.', 1978, 20, '79886753426'),
	('Forew V. E.', 1950, 13, '79886753427');

create table w_c(
	w_id int references work_kind(w_id) not null,
	c_id int references customer(c_id) not null
);

insert into w_c(w_id, c_id)
	values
	(1, 5),
	(1, 3),
	(1, 7),
	(2, 2), 
	(2, 3),
	(3, 4),
	(4, 5),
	(5, 6),
	(5, 2),
	(6, 4), 
	(6, 7),
	(7, 7),
	(8, 1),
	(9, 8);

create table c_e(
	c_id int references customer(c_id) not null,
	e_id int references executor(e_id) not null 
);

insert into c_e(c_id, e_id)
	values
	(1, 2),
	(1, 3),
	(2, 2),
	(2, 3),
	(3, 1),
	(4, 5),
	(5, 4),
	(6, 6),
	(7, 6);


--Задание 2
--Инструкция SELECT использующая предикат сравнения
--вывести заказчиков у которых стаж > 10
SELECT *
from customer
where expirience > 10;


--инструкция использующая оконную функцию
--вывести информацию и дать уникальные номера опыту исполнителя, который делает каждую работу.

select work_kind.name, work_kind.expenditures, executor.e_id, executor.expirience,
row_number()
over(partition by work_kind.w_id order by executor.expirience) as row_number
from work_kind join w_e on work_kind.w_id = w_e.w_id
join executor on executor.e_id = w_e.e_id

-- select использующая вложенные коррелированные подзапросы в качестве производных таблиц предложения FROM
--вывести такие e_id, заказчики которых имеют опыт > 15 и id заказчиков > 2
select e_id
from c_e join(
	select  customer.name, customer.expirience
	from customer
	where customer.expirience > 15
) as cust_new on c_e.c_id = cust_new.c_id
where cust_new.c_id > 2


--3 задание

create procedure get_index(table_name varchar(30))
AS $$
	declare
		row record;
		cur cursor
		for select indexname from pg_indexes where tablename = table_name;

	begin
		open cur;
		loop
			fetch cur into row;
			exit when not found;

			raise notice '%', row.indexname;
		end loop;
		close cur;
	end;
$$ language plpgsql;

call get_index('work_kind');


--========================================================================
--3 задание другого варианта
--Создать хранимую процедуру, которая не уничтожая базу данных уничтожает все те таблицы текущей базы данных в схеме 'dbo' (в psql - public),
-- имена которых начинаются с фразы 'TableName'.

drop procedure del();

create procedure del()
AS $$
	declare
		row record;
		cur cursor
		for select table_name from information_schema.tables
		where table_schema = 'public' and table_name like 'tablename%';

	begin
		open cur;
		loop
			fetch cur into row;
			exit when not found;
			raise notice '%', row.table_name;
			execute 'drop table ' || row.table_name ;
		end loop;
		close cur;
	end;
$$ language plpgsql;

call del();







































