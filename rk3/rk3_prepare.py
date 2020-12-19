import os
from tabulate import tabulate  # это модуль, который позволяет красиво отображать табличные данные.
from dotenv import load_dotenv  # позволяет загружать переменные окружения из файла .env в корневом каталоге приложения.
import psycopg2
from psycopg2 import OperationalError
from py_linq import Enumerable
from psycopg2.extras import DictConnection, DictCursor
from datetime import time
load_dotenv('/home/maksim/lyubaxapro/database/config.env')

###############################################################################

def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            host=os.getenv("PG_HOST"),
            database=os.getenv("PG_DBNAME"),
            user=os.getenv("PG_USER"),
            password=os.getenv("PG_PASSWORD"),
            connection_factory=DictConnection,
            cursor_factory=DictCursor)

        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print("The error '{e}' occurred")
    return connection

connection = connect()

# обработка на уровне БД
#Найти отделы в которых хоть один сотрудник опаздывает больше трёх раз в неделю
def department_1_1():
    cursor = connection.cursor()
    query = '''
            select distinct department
        from employee
        where id in (
            select id_employee
            from(
                select id_employee, count(*) as nlate
                from record
                where rtype = 1  and rdate between date_trunc('week', rdate)::date and (date_trunc('week', rdate) + '6 days'::interval)::date and rtime > '9:00'
                group by id_employee
            ) as temp
        where temp.nlate > 2
);
    '''
    cursor.execute(query)
    connection.commit()

    answer = cursor.fetchall()
    print("\nНайти отделы в которых хоть один сотрудник опаздывает больше трёх раз в неделю \n")
    print("Результат :")
    print(tabulate(answer, headers=['Отдел']))
    cursor.close()

# обработка на уровне БД
# Средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
def mid_age_2_1():
    cursor = connection.cursor()
    query = '''
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

    '''
    cursor.execute(query)
    connection.commit()

    answer = cursor.fetchall()
    print("\nСредний возраст сотрудников, не находящихся на рабочем месте 8 часов в день \n")
    print("Результат :")
    print(tabulate(answer, headers=['Возраст']))
    cursor.close()

# обработка на уровне приложения
#Средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день
def query2_2():


    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from record")
    record = cursor.fetchall()

    cursor.execute('select * from employee')
    employee = cursor.fetchall()
    cursor.close()

    date_list = []
    for r in record:
        if (r['rdate']) not in date_list:
            date_list.append(r['rdate'])
    id = []
    age = []

    for empl in employee:
        flag = True
        for current_date in date_list:
            if flag:
                info = Enumerable(record).where(lambda x: x['rdate'] == current_date and x['id_employee'] == empl['id'])
                # if len(info) != 0:
                #     t1_sum = 0
                #     t1 = info.where(lambda x: x['rtype'] == 1).select(lambda y: y['rtime']).to_list()
                #     for t in t1:
                #         t1_sum += (t.hour * 60 + t.minute) * 60 + t.second
                #
                #     t2_sum = 0
                #     t2 = info.where(lambda x: x['rtype'] == 2).select(lambda y: y['rtime']).to_list()
                #     for t in t2:
                #         t2_sum += (t.hour * 60 + t.minute) * 60 + t.second
                #
                #     if ((t2_sum - t1_sum) / 3600 < 8):
                #         if empl['id'] not in id:
                #             id.append(empl['id'])
                #             age.append(2020 - empl['birthdate'].year)
                #             flag = False
                if len(info) != 0:
                    sum = 0
                    t1 = info.select(lambda y: y['rtime']).to_list()
                    t1.sort()
                    for i in range(len(t1), 2):
                        print(i)
                        sum += ((t1[i + 1].hour * 60 + t1[i + 1].minute) * 60 + t1[i + 2].second - (t1[i].hour * 60 + t1[i].minute) * 60 + t1[i].second)
                    if((sum) / 3600 < 8):
                            if empl['id'] not in id:
                                id.append(empl['id'])
                                age.append(2020 - empl['birthdate'].year)
                                flag = False



    print('Средний возраст сотрудников, не находящихся на рабочем месте 8 часов в день')
    if (len(age)) == 0:
        print("Нет таких сотрудников")
    else:
        sum_age = 0
        for i in age:
            sum_age += i
        print(sum_age / len(age))




# # обработка на уровне БД
#Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю работы
def dep_count_late_3_1():
    cursor = connection.cursor()
    query = '''
        select w_dep, count(w_id) 
        from ( 
        select distinct employee.id as w_id, 
        employee.department as w_dep 
        from ( 
        select id_employee, rdate, 
        min(rtime) as intime
        from record
        where rtype = 1 
        group by id_employee, rdate 
        ) as tmp join employee on employee.id = tmp.id_employee 
        where intime > '09:00' 
        ) as tmp2 
        group by w_dep;
 
    '''
    cursor.execute(query)
    connection.commit()

    answer = cursor.fetchall()
    print("\nВывести все отделы и количество сотрудников хоть раз опоздавших за всю историю работы \n")
    print("Результат :")
    print(tabulate(answer, headers=['Количество','Отдел']))
    cursor.close()

## обработка на уровне приложения
# Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю работы
def query3_2():
    check_date_time = time(9, 0)
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from record")
    record = cursor.fetchall()

    cursor.execute('select * from employee')
    employee = cursor.fetchall()
    cursor.close()

    date_list = []
    for r in record:
        if (r['rdate']) not in date_list:
            date_list.append(r['rdate'])

    late = {}
    for empl in employee:
        if empl['department'] not in late.keys():
            d = {str(empl['department']) : []}
            late.update(d)

    for index_emp in range(len(employee)):
        current_id = employee[index_emp]['id']
        current_department = employee[index_emp]['department']
        flag = True
        for current_date in date_list:
            if flag:
                info = Enumerable(record).where(lambda x: x['rdate'] == current_date and x['id_employee'] == current_id)
                if len(info) != 0:
                    min_time = info.min(lambda x: x['rtime'])

                    if min_time > check_date_time:
                        if current_id not in late[current_department]:
                            late[current_department].append(current_id)
                            flag = False

    print("Отделы и количество сотрудников хоть раз опоздавших за всю историю работы")
    for k in late.keys():
        print(k, len(late[k]))


 #################################################################################


def print_menu():
    print("\n\
 1. Найти отделы в которых хоть один сотрудник опаздывает больше трёх раз в неделю (на стороне БД)  \n\
 2. Средний возраст людей которые провели меньше 8 часов на работе \n\
 3. Вывести все отделы и количество сотрудников хоть раз опоздавших за всю историю работы \n\
 4. 3_2 \n\
 5. 2_2 \n\
 6. Выход")


execute = [
    '__empty__',

    department_1_1, mid_age_2_1, dep_count_late_3_1, query3_2, query2_2,

    lambda: print('Bye!')
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()