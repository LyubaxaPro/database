import psycopg2
from psycopg2 import OperationalError
#
# fetchall() – возвращает число записей в виде упорядоченного списка;
# fetchmany(size) – возвращает число записей не более size;
# fetchone() – возвращает первую запись.

# Важно! Стандартный курсор забирает все данные с сервера сразу, не зависимо от того, используем мы .fetchall() или .fetchone()

text = '''
1)Выполнить скалярный запрос
2)Выполнить запрос с несколькими join
3)Выполнить запрос с ОТВ и оконными функциями
4)Выполнить запрос к метаданным
5)Вызвать скалярную функцию(написанную в третьей л.р.)
6)Вызвать многооператорную или табличную функцию(написанную в 3 л.р.)
7)Вызвать хранимую процедуру(написанную 3 л.р.)
8)Вызвать системную функцию или процедуру
9)Создать таблицу в базе данных, соответствующую теме бд
10)Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY
'''

# получение игрока c id = 980
scalarRequest = '''
select player_name, player_id from players where player_id = 980;
'''

# получить имена игроков, аббревиатуру команды, дату игры для команды 'ATL'
multJoinRequest = '''
select players.player_name, games_details.team_abbreviation, games.GAME_DATE_EST
from players join games_details on players.player_id = games_details.player_id
join games on games.game_id = games_details.game_id
where games_details.team_abbreviation = 'ATL'
'''

#Получить средний MIN_YEAR команд для каждого города:
OTV = '''
WITH CTE(min_year, city) AS
(
	SELECT min_year, city
	from teams
)

SELECT DISTINCT cyty, AVG(min_year) OVER(PARTITION by city)
from CTE;
'''

# Получить все данные из public
metadataRequest = '''
select * from pg_tables where schemaname = 'public';
'''

#  Получить минимальный год основания командых
scalarFunc = '''
select * from older_team();
'''

# Вывести информацию о комндах, созданых позже 1990 года
tableFunc = '''
select * from get_teams(1990);
'''

#--Заменить в таблице Table1 все A на C
storedProc = '''
select * from update_var('A', 'C');
select *
from table1
'''

# Создать таблицу
tableCreation = '''
create table if not exists players_score(
	player_id int,
	score int
);
'''

# Вставить данные в таблицу
tableInsertion = '''
insert into players_score values
(202711, 5),
(1629680, 3),
(1628391, 4),
(1629632, 1);

select * from players_score;
'''

# Вывести имя текущей базы данных
systemFunc = '''
select current_catalog;
'''

def output(cur, func):
    if func == 1:
        answer = cur.fetchall()
        print("\nВывести игрока c id = 980 : \n")
        print("Результат :")
        print("player_name", "player_id")
        print(answer[0][0])

    elif func == 2:
        answer = cur.fetchall()

        print("\nПолучить имена игроков, аббревиатуру команды, дату игры для команды 'ATL' : \n")
        print("Результат :")
        print("player_name team_abbreviation game_date_est")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2])

    elif func == 3:
        answer = cur.fetchall()

        print("\nПолучить средний MIN_YEAR команд для каждого города: \n")
        print("Результат :")
        print("city avg")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1])

    elif func == 4:
        answer = cur.fetchall()

        print("\n Получить все данные из public: \n")
        print("Результат :")
        print("shemaname tablename tableowner tablespace hasIndexes hasrules hastriggers")
        for i in range(len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2],  answer[i][3],  answer[i][4],  answer[i][5], answer[i][6])

    elif func == 5:
        answer = cur.fetchall()

        print("\n Получить минимальный год основания командых: \n")
        print("Результат :")
        print("older team")
        print(answer[0][0])

    elif func == 6:
        answer = cur.fetchall()

        print("\n Вывести информацию о комндах, созданых позже 1990 года: \n")
        print("Результат :")
        print("LEAGUE_ID,TEAM_ID,MIN_YEAR,MAX_YEAR,ABBREVIATION,NICKNAME,YEARFOUNDED,CITY,ARENA,ARENACAPACITY,COM_OWNER,GENERALMANAGER,HEADCOACH,DLEAGUEAFFILIATION")
        for i in range (len(answer)):
            print(answer[i])

    elif func == 7:
        answer = cur.fetchall()

        print("\n Заменить в таблице Table1 все A на C: \n")
        print("Результат :")
        print("id, var1, valid_from_dttm, valid_to_dttm")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1], answer[i][2], answer[i][3])

    elif func == 8:
        answer = cur.fetchall()


        print("\n Вывести имя текущей базы данных: \n")
        print("Результат :")
        print("current catalog")
        print(answer[0][0])

    elif func == 9:
        print("\n Создать таблицу: \n")
        print("Результат :")
        print("Table created")

    elif func == 10:
        answer = cur.fetchall()

        print("\n Вставить данные в таблицу: \n")
        print("Результат :")
        print("player_id, score")
        for i in range (len(answer)):
            print(answer[i][0], answer[i][1])

def requestPgQuery(connection, query, func):
    cursor = connection.cursor()
    cursor.execute(query)
    # Если мы не просто читаем, но и вносим изменения в базу данных - необходимо сохранить транзакцию
    connection.commit()
    output(cursor, func)
    cursor.close()



def connect():
    connection = None
    try:
        connection = psycopg2.connect(
            host="localhost",
            database="MyDB",
            user="postgres",
            password="newpassword")


        print("Connection to PostgreSQL DB successful")

    except OperationalError as e:
        print(f"The error '{e}' occurred")
    return connection


def menu(connection):
    print(text)
    print("Выберите действие:")
    choice = int(input())
    while(choice):
        if (choice == 1):
            requestPgQuery(connection, scalarRequest, 1)
        elif choice == 2:
            requestPgQuery(connection, multJoinRequest, 2)
        elif choice == 3:
            requestPgQuery(connection, OTV, 3)
        elif choice == 4:
            requestPgQuery(connection, metadataRequest, 4)
        elif choice == 5:
            requestPgQuery(connection, scalarFunc, 5)
        elif choice == 6:
            requestPgQuery(connection, tableFunc, 6)
        elif choice == 7:
            requestPgQuery(connection, storedProc, 7)
        elif choice == 8:
            requestPgQuery(connection, systemFunc, 8)
        elif choice == 9:
            requestPgQuery(connection, tableCreation, 9)
        elif choice == 10:
            requestPgQuery(connection, tableInsertion, 10)
        print("\nВыберите действие:")
        choice = int(input())


connection = connect()

if __name__ == '__main__':
    menu(connection)
    connection.close()