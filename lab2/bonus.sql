drop table Table1;
drop table Table2;

create table Table1 
(
	id int,
	var1 char,
	valid_from_dttm date,
	valid_to_dttm date
);

create table Table2 
(
	id int,
	var2 char,
	valid_from_dttm date,
	valid_to_dttm date
);

insert into Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (1, 'A', '20180901', '20180915');
insert into Table1 (id, var1, valid_from_dttm, valid_to_dttm) values (1, 'B', '20180916', '59991231');

insert into Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (1, 'A', '20180901', '20180918');
insert into Table2 (id, var2, valid_from_dttm, valid_to_dttm) values (1, 'B', '20180919', '59991231');

SELECT Table1.id, Table1.var1, Table2.var2, 
	CASE WHEN Table1.valid_from_dttm < Table2.valid_from_dttm THEN Table2.valid_from_dttm
		ELSE Table1.valid_from_dttm
	END valid_from_dttm, 
	
	CASE WHEN Table1.valid_to_dttm > Table2.valid_to_dttm THEN Table2.valid_to_dttm
		ELSE Table1.valid_to_dttm
	END valid_to_dttm
	
FROM Table1 JOIN  TABLE2 ON Table1.id = Table2.id 
AND Table1.valid_from_dttm < Table2.valid_to_dttm
AND Table2.valid_from_dttm < Table1.valid_to_dttm