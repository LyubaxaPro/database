CREATE EXTENSION plpython3u;

-- 1) Определяемую пользователем скалярную функцию CLR, 
-- Функция выводит 1 если conference = conf, 0 иначе
drop function count_conference(conf text, ranking_tab ranking);
create or replace function count_conference(conf text, ranking_tab ranking) returns int as $$
    s = ranking_tab['conference']
    n = 0
    if s == conf:
        n = 1
    return n
$$ language plpython3u;

select ranking.team_id, count_conference('West', ranking.*) from ranking

-- 2) Пользовательскую агрегатную функцию CLR
-- Функция умножения всех чисел в столбце

-- функция состояния
--Имя функции перехода состояния, вызываемой для каждой входной строки.
--Для обычных агрегатных функций с N аргументами, функция_состояния должна принимать N+1 аргумент, первый должен иметь тип тип_данных_состояния, 
--а остальные — типы соответствующих входных данных. Возвращать она должна значение типа тип_данных_состояния.
-- Эта функция принимает текущее значение состояния и текущие значения входных данных, и возвращает следующее значение состояния.

-- initcond
--Начальное значение переменной состояния. 
--Оно должно задаваться строковой константой в форме, пригодной для ввода в тип_данных_состояния. Если не указано, начальным значением состояния будет NULL.
create or replace function mul(state int, arg int)
returns int
as $$
    return state * arg
$$ language plpython3u;

CREATE AGGREGATE my_agr(int)
(
    sfunc = mul,
    stype = int,
    initcond = 1
);

select test_for_rec.* from test_for_rec

--3) Определяемую пользователем табличную функцию CLR
-- str.rstrip([chars]) Этот метод возвращает копию строки, в которой все символы были вырезаны из конца строки (по умолчанию символ пробел).

--При вызове plpy.execute со строкой запроса и необязательным аргументом, ограничивающим число строк, выполняется заданный запрос, а то,
 --что он выдаёт, возвращается в виде объекта результата.
--Объект результата имитирует список или словарь. Получить из него данные можно по номеру строки и имени столбца

--Вывести имена игроков длина которых находится в интервале (from_l, to_l)
create or replace function my_table_func(from_l int, to_l int) returns table(player_name text, len int)
as $$
    p = plpy.execute("SELECT * FROM players")
    result = []
    for i in range(len(p)):
        s = p[i]["player_name"]
        if (len(s) > from_l and len(s) < to_l):
            result.append({ "player_name": s.rstrip(),  "len": len(s)})
    return result
$$ language plpython3u;

select * from my_table_func(6,15)

--4)Хранимую процедуру CLR
--заменяет var1 в таблице
create or replace function update_var_p (t_name text, p_var char, p_new_var char) returns void
as $$
    plpy.execute("update " + t_name + " set var1 = \'" + str(p_new_var) + "\' where var1 = \'" +  str(p_var) + "\'")
$$ language plpython3u; 

select * from update_var_p('t1', 'B', 'A');
select *
from t1

--5) Триггер CLR
drop table act_tab;

create table act_tab(
    id int,
    act text
);

create or replace function tr_before() returns trigger
as $$
    if TD["event"] == "DELETE":
        old_id = str(TD["old"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + old_id + ", \'delete\')")
        return "OK"
        
    elif TD["event"] == "INSERT":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'insert\')")
        return "OK"
        
    elif TD["event"] == "update":
        new_id = str(TD["new"]["id"])
        plpy.execute("insert into act_tab(id, act) values (" + new_id + ", \'update\')")
        return "OK" 
        
    
$$ language plpython3u;

-- create trigger trig_b before delete or update or insert on test_for_rec
-- for each row execute procedure tr_before();

insert into test_for_rec(id, name) values (6, 'D');

select * from act_tab

-- 6)Определяемый пользователем тип данных CLR.
drop type complex cascade;
CREATE TYPE complex;

CREATE FUNCTION complex_in(cstring)
    RETURNS complex
    AS '/home/lyubaxapro/database/lab4/complex'
    LANGUAGE C IMMUTABLE STRICT;

CREATE FUNCTION complex_out(complex)
    RETURNS cstring
    AS '/home/lyubaxapro/database/lab4/complex'
    LANGUAGE C IMMUTABLE STRICT;

CREATE TYPE complex (
   internallength = 16,
   input = complex_in,
   output = complex_out,
   alignment = double
);




--////////////////////////////////////////////////
--другой способ
CREATE TYPE complex_new AS (
    r       double precision,
    i       double precision
);

create or replace function set_complex_new(r double precision , i double precision )
returns setof complex_new
as $$
    return ([r, i],)
$$ language plpython3u;

select * from set_complex_new(3, 5);