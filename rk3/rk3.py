import os
from tabulate import tabulate
from dotenv import load_dotenv
import psycopg2
from psycopg2 import OperationalError
from psycopg2.extras import  DictConnection, DictCursor
from py_linq import Enumerable
from datetime import time

load_dotenv('/home/maksim/lyubaxapro/database/config.env')

def connect():
    connection = None

    try:
        connection = psycopg2.connect(
            host=os.getenv("PG_HOST"),
            database=os.getenv("PG_DBNAME"),
            user=os.getenv("PG_USER"),
            password=os.getenv("PG_PASSWORD"),
            connection_factory=DictConnection,
            cursor_factory=DictCursor

        )

        print("connection succes")
        return connection
    except OperationalError as e:
        print("The error '{e}' ")

connection = connect()

#Найти все отделы, в которых работает более 10 сотрудников
def find_dep_1():
    # try:
    cursor = connection.cursor(cursor_factory=DictCursor)
    query = '''
        select department
        from employee
        group by department
        having count(id) > 10;
    '''
    cursor.execute(query)
    answ = cursor.fetchall()
    print("Найти все отделы, в которых работает более 10 сотрудников")
    print(tabulate(answ, headers=['Отдел']))
    cursor.close()
    # except Exception:
    #     print("Error")

def find_dep_2():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from employee')
    employee = Enumerable(cursor.fetchall())
    cursor.close()

    dep = (employee.group_by(key_names=['department'], key = lambda x: x['department']))\
        .select(lambda g: {'department': g.key.department, 'cnt':g.count()}).where(lambda g: g['cnt'] > 10)\
        .to_list()
    print(dep)

#Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня
def find_right_empl_1():
    try:
        cursor = connection.cursor(cursor_factory=DictCursor)
        query = '''
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
        '''
        cursor.execute(query)
        answ = cursor.fetchall()
        print("Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня")
        print(tabulate(answ, headers=['ID сотрудника']))
        cursor.close()
    except Exception:
        print("Error")

def find_right_empl_2():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from record')
    record = Enumerable(cursor.fetchall())
    cursor.close()

    bad_workers = (record.group_by(key_names=['id_employee', 'rdate', 'rtype'], key=lambda x: (x['id_employee'],
                                   str(x['rdate']), x['rtype'])). select(lambda g: {'rtype' : g.key.rtype,
                                    'id_employee': g.key.id_employee, 'cnt':g.count()})\
                   .where(lambda g:g['rtype'] == 2 and g['cnt'] > 1).to_list())
    cursor =connection.cursor(cursor_factory=DictCursor)
    cursor.execute('select * from employee')
    employee = Enumerable(cursor.fetchall())
    cursor.close()

    good_w = []
    for w in employee:
        if w not in bad_workers and w not in good_w:
            good_w.append(w)
    print(good_w)


#Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры
def find_dep_with_latters_in_data():
    try:
        target_data = input('Введите дату: ')
        cursor = connection.cursor(cursor_factory=DictCursor)
        query = '''
                select distinct department
                from employee
                where id in 
                (
                    select id_employee
                    from
                    (
                        select id_employee, min(rtime)
                        from record
                        where rtype = 1 and rdate = target_data
                        group by id_employee
                        having min(rtime) > '9:00'
                    ) as tmp
                );
        '''
        cursor.execute(query)
        answ = cursor.fetchall()
        print("Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры")
        print(tabulate(answ, headers=['Отдел']))
        cursor.close()
    except Exception:
        print("Error")



def print_menu():
    print('\n\
          1. Найти все отделы, в которых работает более 10 сотрудников (Обработка на уровне БД)\n\
          2. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (Обработка на уровне БД) \n\
          3. Найти все отделы, в которых есть сотрудники, опоздавшие в определенную дату. Дату передавать с клавиатуры \n\
          4. Найти все отделы, в которых работает более 10 сотрудников (Обработка на уровне приложения)\n\
          5. Найти сотрудников, которые не выходят с рабочего места в течение всего рабочего дня (Обработка на уровне приложения) \n\
          6. Выход \n\  ')

execute = [
    '__empty__',
    find_dep_1, find_right_empl_1, find_dep_with_latters_in_data, find_dep_2, find_right_empl_2,
    lambda: print("Bye")
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()













