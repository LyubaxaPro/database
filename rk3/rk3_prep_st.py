import os
from tabulate import tabulate  # это модуль, который позволяет красиво отображать табличные данные.
from dotenv import load_dotenv  # позволяет загружать переменные окружения из файла .env в корневом каталоге приложения.
import psycopg2
from psycopg2 import OperationalError
from py_linq import Enumerable
from psycopg2.extras import DictConnection, DictCursor
load_dotenv('/home/maksim/lyubaxapro/database/config.env')

###############################################################################
#Обработка на уровне БД

def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            host=os.getenv("PG_HOST"),
            database=os.getenv("PG_DBNAME"),
            user=os.getenv("PG_USER"),
            password=os.getenv("PG_PASSWORD"),
            connection_factory = DictConnection,
            cursor_factory = DictCursor)

        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection

connection = connect()

#Вывести факультет на с наибольшим количеством неопределившихся с преподавателем студентов
def departament_1_1():
    cursor = connection.cursor(cursor_factory=DictCursor)
    query = '''
            select department
        from (
           select department, count(id) as c 
           from students
           where teacher_id is null
           group by department 
        ) as dc
        order by c desc 
        limit 1 '''
    cursor.execute(query)
    connection.commit()

    answer = cursor.fetchall()
    print("\nВывести факультет на с наибольшим количеством неопределившихся с преподавателем студентов \n")
    print("Результат :")
    print(tabulate(answer, headers=['Отдел']))
    cursor.close()


def query1_2():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from students")

    filtered = Enumerable(cursor.fetchall()) \
        .where(lambda s: s["teacher_id"] is None).to_list()

    departments_freq = {}
    for student in filtered:
        if student["department"] in departments_freq:
            departments_freq[student["department"]] += 1
        else:
            departments_freq[student["department"]] = 1
    if len(departments_freq) == 0:
        print('Таких отделов нет')
    else:
        list_for_sort = list(departments_freq.items())
        list_for_sort.sort(key=lambda x: x[1])
        print('Отдел')
        print(list_for_sort[-1][0])
    cursor.close()

def departament_2_1():
    cursor = connection.cursor(cursor_factory=DictCursor)
    query = '''
    select students.* 
from students 
join teachers on teacher_id = teachers.id 
where teachers.name = 'Рудаков Игорь Владимирович' 
and extract(year from birthday) = 1990
            '''
    cursor.execute(query)
    connection.commit()

    answer = cursor.fetchall()
    print("\nСтудент Рудакова и родился в 1990 \n")
    print("Результат :")
    print(tabulate(answer, headers=['ID', 'name', 'birthday', 'departament', 'teacher_id']))
    cursor.close()

def query2_2():
    cursor = connection.cursor(cursor_factory=DictCursor)
    cursor.execute("select * from students")
    students = cursor.fetchall()

    cursor.execute('select * from teachers')
    teachers = cursor.fetchall()
    cursor.close()

    res =  Enumerable(students).join(Enumerable(teachers),
              lambda s: s['teacher_id'],
              lambda t: t['id'],
              lambda r: r) \
        .where(lambda r: r[1]['name'] == 'Рудаков Игорь Владимирович') \
        .where(lambda r: r[0]['birthday'].year == 1990) \
        .select(lambda r: r[0])
    print(res)






def print_menu():
    print("\n\
 1. Вывести факультет на с наибольшим количеством неопределившихся с преподавателем студентов.(на стороне БД)  \n\
 2. Вывести факультет на с наибольшим количеством неопределившихся с преподавателем студентов.\n\
 3. Студент Рудакова и родился в 1990 БД \n\
 4. Студент Рудакова и родился в 1990   \n\
5. Выход")


execute = [
    '__empty__',

    departament_1_1, query1_2, departament_2_1, query2_2,

    lambda: print('Bye!')
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice]()