drop table employee;
create table if not exists employee (
	id serial not null primary key,
	name varchar(50) not null,
	birthdate date,
	department varchar(15)
);

insert into employee(name, birthdate, department)
values ('A A A', '23-09-1990', 'IT'), 
('B B B', '25-07-1995', 'Finance'), 
('C C C', '15-09-1980', 'Finance'), 
('D D D', '22-08-1993', 'IT'), 
('E E E', '15-05-1987', 'Finance');


create table if not exists record (
	id_employee int references employee(id) not null,
	rdate date,
	weekday varchar(15),
	rtime time,
	rtype int
);

insert into record(id_employee, rdate, weekday, rtime, rtype)
values
(1, '21-12-2019', 'Понедельник', '09:01', 1), 
(2, '21-12-2019', 'Понедельник', '09:05', 1), 
(3, '21-12-2019', 'Понедельник', '09:20', 1), 
(4, '21-12-2019', 'Понедельник', '10:00', 1), 
(5, '21-12-2019', 'Понедельник', '09:10', 1), 

(1, '21-12-2019', 'Понедельник', '19:01', 2), 
(2, '21-12-2019', 'Понедельник', '18:05', 2), 
(3, '21-12-2019', 'Понедельник', '10:20', 2), 
(3, '21-12-2019', 'Понедельник', '11:20', 1), 
(3, '21-12-2019', 'Понедельник', '19:20', 2), 
(4, '21-12-2019', 'Понедельник', '17:00', 2), 
(5, '21-12-2019', 'Понедельник', '18:10', 2), 

(1, '22-12-2019', 'Вторник', '09:01', 1), 
(2, '22-12-2019', 'Вторник', '09:05', 1), 
(3, '22-12-2019', 'Вторник', '09:20', 1), 
(4, '22-12-2019', 'Вторник', '10:00', 1), 
(5, '22-12-2019', 'Вторник', '09:10', 1), 

(1, '22-12-2019', 'Вторник', '19:01', 2), 
(2, '22-12-2019', 'Вторник', '18:05', 2), 
(3, '22-12-2019', 'Вторник', '10:20', 2), 
(3, '22-12-2019', 'Вторник', '11:20', 1), 
(3, '22-12-2019', 'Вторник', '19:20', 2), 
(4, '22-12-2019', 'Вторник', '17:00', 2), 
(5, '22-12-2019', 'Вторник', '18:10', 2), 

(1, '23-12-2019', 'Среда', '09:01', 1), 
(2, '23-12-2019', 'Среда', '09:05', 1), 
(3, '23-12-2019', 'Среда', '09:20', 1), 
(4, '23-12-2019', 'Среда', '10:00', 1), 
(5, '23-12-2019', 'Среда', '09:10', 1), 

(1, '23-12-2019', 'Среда', '19:01', 2), 
(2, '23-12-2019', 'Среда', '18:05', 2), 
(3, '23-12-2019', 'Среда', '10:20', 2), 
(3, '23-12-2019', 'Среда', '11:20', 1), 
(3, '23-12-2019', 'Среда', '19:20', 2), 
(4, '23-12-2019', 'Среда', '17:00', 2), 
(5, '23-12-2019', 'Среда', '18:10', 2), 

(1, '24-12-2019', 'Четверг', '09:01', 1), 
(2, '24-12-2019', 'Четверг', '09:05', 1), 
(3, '24-12-2019', 'Четверг', '09:20', 1), 
(4, '24-12-2019', 'Четверг', '10:00', 1), 
(5, '24-12-2019', 'Четверг', '09:10', 1), 

(1, '24-12-2019', 'Четверг', '19:01', 2), 
(2, '24-12-2019', 'Четверг', '18:05', 2), 
(3, '24-12-2019', 'Четверг', '10:20', 2), 
(3, '24-12-2019', 'Четверг', '11:20', 1), 
(3, '24-12-2019', 'Четверг', '19:20', 2), 
(4, '24-12-2019', 'Четверг', '17:00', 2), 
(5, '24-12-2019', 'Четверг', '18:10', 2), 

(1, '28-12-2019', 'Понедельник', '9:01', 1), 
(2, '29-12-2019', 'Среда', '9:05', 1), 
(3, '30-12-2019', 'Чтеверг', '9:20', 1), 
(4, '31-12-2019', 'Пятница', '10:00', 1), 
(5, '01-01-2020', 'Понедельник', '9:10', 1), 

(1, '28-12-2019', 'Понедельник', '19:01', 2), 
(2, '29-12-2019', 'Среда', '18:05', 2), 
(3, '30-12-2019', 'Чтеверг', '10:20', 2), 
(3, '30-12-2019', 'Чтеверг', '11:20', 1), 
(3, '30-12-2019', 'Чтеверг', '19:20', 2), 
(4, '31-12-2019', 'Пятница', '17:00', 2), 
(5, '01-01-2020', 'Понедельник', '18:10', 2), 

(1, '02-01-2020', 'Вторник', '09:01', 1), 
(2, '02-01-2020', 'Вторник', '09:05', 1), 
(3, '02-01-2020', 'Вторник', '09:20', 1), 
(4, '02-01-2020', 'Вторник', '10:00', 1), 
(5, '02-01-2020', 'Вторник', '09:10', 1), 

(1, '02-01-2020', 'Вторник', '19:01', 2), 
(2, '02-01-2020', 'Вторник', '18:05', 2), 
(3, '02-01-2020', 'Вторник', '10:20', 2), 
(3, '02-01-2020', 'Вторник', '11:20', 1), 
(3, '02-01-2020', 'Вторник', '19:20', 2), 
(4, '02-01-2020', 'Вторник', '17:00', 2), 
(5, '02-01-2020', 'Вторник', '18:10', 2);

# Посчитать количество опоздавших сотрудников. Дата опоздания и время к которому нужно прийти как аргумент. 
create or replace function check_delay(check_date date) RETURNS int AS $$
    BEGIN
        RETURN (select count(*)
from(
	select id_employee
	from record
	where rdate = check_date and rtype = 1 
	group by id_employee
	having min(rtime) > '9:00') as temp);
    END;
$$ LANGUAGE plpgsql;


# Найти отделы в которых хотябы 1 сотрудник опаздывает больше трёх раз в неделю
select distinct department
from employee
where id in (
	select id_employee
	from(
		select id_employee, count(*) as nlate, min(rtime)
		from record
		where rtype = 1  and rdate between date_trunc('week', rdate)::date and (date_trunc('week', rdate) + '6 days'::interval)::date
		group by id_employee
		having min(rtime) > '9:00'
	) as temp
where temp.nlate > 2
);

--средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день 
--(не находившихся хотя бы один раз) 
SELECT AVG(age) 
FROM ( 
	SELECT EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM birthdate) AS age 
	FROM employee 
	WHERE id IN ( 
		select distinct id_employee 
		from( 
			select id_employee , rdate, 
			sum( 
			(EXTRACT(EPOCH FROM outtime - intime) / 3600)::Integer 
			) AS work_time --— время между каждыми двумя последовательными приходом-уходом суммируется 
			from 
			( 
				select id_employee, rdate, intime, outtime 
				from 
				( 
					select id_employee, rdate, rtype, rtime as intime, 
					lead(rtime, -1) over (partition by id_employee, rdate) as outtime 
					from record
				) as tmp0 
				where rtype=1 and intime is not null and outtime is not null 
			) as tmp1 
			group by id_employee, rdate -- для каждого сотрудника каждого дня 
			having sum( 
			(EXTRACT(EPOCH FROM outtime - intime) / 3600)::Integer 
			) < 8 --- оставляем только те дни, когда сотрудник провел меньше 8 часов 
		) as tmp2 
	)
) as tmp3

# Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю работы 
-- отделы, количество опоздавших хоть раз за весь учет 
select w_dep, count(w_id) 
from ( 
select distinct employee.id as w_id,-- — distinct, тк кол-во опозданий не важно, только факт опоздания 
employee.department as w_dep 
from ( 
select id_employee, rdate, 
min(rtime) as intime --— время прихода каждого работника в каждую дату 
from record
where rtype = 1 
group by id_employee, rdate 
) as tmp join employee on employee.id = tmp.id_employee --— нужно поле отдела их таблицы workers 
where intime > '09:00' --— время прихода на работу > 9:00 
) as tmp2 
group by w_dep;
 
--========================================================================================================================================================================
-- rk про студентов и преподавателей
create table teachers (
	id           serial primary key,
	name         text,
	department   text,
	max_students smallint
);

create table students (
	id         serial primary key,
	name       text,
	birthday   date,
	department text,
	teacher_id int references teachers (id) null
);

insert into teachers
	(name, department, max_students)
values
	('Рудаков Игорь Владимирович', 'ИУ7', 6),
	('Строганов Юрий Владимирович', 'ИУ7', 5),
	('Куров Андрей Владимирович', 'ИУ7', 6),
	('Скориков Татьяна Петровна', 'Л', 1);

insert into students
	(name, birthday, department, teacher_id)
values
	('Иванов Иван Иванович', '1990-09-25', 'ИУ', 1),
	('Петров Петр Петрович', '1987-11-12', 'Л', null),
	('Попов Поп Попович', '1998-01-02', 'ИУ', 3),
	('Попов Иван Иванович', '1998-01-03', 'РК', 2),
	('Иванов Петр Иванович', '1998-10-10', 'ИБМ', 1),
	('Иванов Иван Петрович', '1998-01-01', 'АК', null),
	('Керимов Иван Иванович', '1989-01-03', 'МТ', null),
	('Иванов Керим Иванович', '1988-01-10', 'МТ', null),
	('Иванов Иван Керимович', '1987-01-04', 'СК', 3),
	('Андреев Иван Иванович', '1986-04-01', 'Э', 1),
	('Иванов Андрей Иванович', '1985-03-01', 'Э', 1),
	('Иванов Иван Андреевич', '1984-02-01', 'Э', null);

-- Создать табличную функцию, подбирающу научного руководителя
-- не определившимся студентам, с учетом уже имеющейся занятости преподователя.

create or replace procedure get_teachers_to_students() language plpgsql as $$
declare
	student record;
	teacher int;
begin
	for student in
		select *
		from students
		where teacher_id is null
	loop
		select teachers.id into teacher
		from teachers
			join students s on teachers.id = s.teacher_id
		group by teachers.id, max_students
		having count(s.id) < max_students
		limit 1;

		update students set teacher_id = teacher where id = student.id;
	end loop;
end
$$;
call get_teachers_to_students()


-- Вывести факультет на с наибольшим количеством неопределившихся с преподавателем студентов.
select department
from (
   select department, count(id) as c 
   from students
   where teacher_id is null
   group by department 
) as dc
order by c desc 
limit 1