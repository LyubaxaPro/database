
--Вариант 1
create table employee (
	id serial not null primary key,
	name text,
	birthdate date, 
	department text
);

create table record(
	id_employee int references employee(id) not null,
	rdate date,
	day text,
	rtime time,
	rtype int
)


insert into employee(name, birthdate, department)
	values ('Qwer Inna A', '25-09-1995', 'IT'),
	('Qas Inna A', '30-09-1999', 'IT'),
	('B Ee W', '25-09-1990', 'Fin'),
	('Qwer A Q', '15-09-1997', 'Fin');

insert into record(id_employee, rdate, day, rtime, rtype)
	values
	(1, '21-12-2019', 'Понедельник', '09:01', 1),
	(1, '21-12-2019', 'Понедельник', '09:12', 2),
	(1, '21-12-2019', 'Понедельник', '09:40', 1),
	(1, '21-12-2019', 'Понедельник', '20:01', 2),

	(3, '21-12-2019', 'Понедельник', '09:01', 1),
	(3, '21-12-2019', 'Понедельник', '09:12', 2),
	(3, '21-12-2019', 'Понедельник', '09:40', 1),
	(3, '21-12-2019', 'Понедельник', '20:01', 2),

	(2, '21-12-2019', 'Понедельник', '08:51', 1),
	(2, '21-12-2019', 'Понедельник', '20:31', 2),

	(4, '21-12-2019', 'Понедельник', '09:51', 1),
	(4, '21-12-2019', 'Понедельник', '20:31', 2),

	(1, '23-12-2019', 'Среда', '09:11', 1),
	(1, '23-12-2019', 'Среда', '09:12', 2),
	(1, '23-12-2019', 'Среда', '09:40', 1),
	(1, '23-12-2019', 'Среда', '20:01', 2),

	(3, '23-12-2019', 'Среда', '09:01', 1),
	(3, '23-12-2019', 'Среда', '09:12', 2),
	(3, '23-12-2019', 'Среда', '09:50', 1),
	(3, '23-12-2019', 'Среда', '20:01', 2),

	(2, '23-12-2019', 'Среда', '08:41', 1),
	(2, '23-12-2019', 'Среда','20:31', 2),

	(4, '23-12-2019', 'Среда', '09:51', 1),
	(4, '23-12-2019', 'Среда', '20:31', 2);

--Написать скалярную функцию, возвращающую количество сотрудников в возрасте от 18 до
--40, выходивших более 3х раз.

create or replace function latters_cnt(target_date date) returns int as $$
	BEGIN
	RETURN(
		select count(*)
		from(
			select distinct id
			from employee
			where EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM birthdate) BETWEEN 18 and 40 and 
			id in(
				select id_employee
				from(
					select id_employee, rdate, rtype, count(*)
					from record
					where rdate = target_date
					group by id_employee, rdate, rtype
					having rtype = 2 and count(*) > 3
					) as tmp0
				)
			) as tmp1
		);
	END;
	$$ language plpgsql;

select * from latters_cnt('23-12-2019')


--------------------------------------------------------
--Найти все отделы, в которых работает более 10 сотрудников
select department
from employee
group by department
having count(id) > 10;

--Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
select id
from employee
where id not in(
	select id_employee
	from (
		select id_employee, rdate, rtype, count(*)
		from record
		group by id_employee, rdate, rtype
		having rtype=2 and count(*) > 1
		) as tmp
);

--Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры
select distinct department
from employee
where id in 
(
	select id_employee
	from
	(
		select id_employee, min(rtime)
		from record
		where rtype = 1 and rdate = '23-12-2019'
		group by id_employee
		having min(rtime) > '9:00'
	) as tmp
);


















