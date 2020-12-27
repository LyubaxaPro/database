import json
import os
import decimal
from tabulate import tabulate  # это модуль, который позволяет красиво отображать табличные данные.
from dotenv import load_dotenv  # позволяет загружать переменные окружения из файла .env в корневом каталоге приложения.
from sqlalchemy import create_engine, text, MetaData
from sqlalchemy.orm import mapper, Session
from psycopg2 import errors
from sqlalchemy import Column, Integer, String, types, func, over
from sqlalchemy.schema import ForeignKey
from sqlalchemy.ext.declarative import declarative_base

load_dotenv('/home/maksim/lyubaxapro/database/config.env')

connect_string = 'postgresql+psycopg2://' + os.getenv("PG_USER") + ':' + os.getenv("PG_PASSWORD") + '@' + \
                 os.getenv("PG_HOST") + ':5432/' + os.getenv("PG_DBNAME")

engine = create_engine(connect_string)  # Функция sqlalchemy.create_engine() создает новый экземпляр класса sqlalchemy.engine.Engine
# который предоставляет подключение к базе данных.

meta = MetaData()
meta.reflect(bind=engine, schema='public')

# Создать не менее пяти запросов с использованием всех
# ключевых слов выражения запроса.


# Session В самом общем смысле, Sessionустанавливает все диалоги с базой данных и представляет собой «зону хранения»
# для всех объектов, которые вы загрузили или связали с ней в течение
# ее жизненного цикла. Он предоставляет точку входа для получения Queryобъекта, который отправляет запросы в базу данных,
# используя Sessionтекущее соединение объекта с базой данных, заполняя строки результатов в объекты, которые затем сохраняются в
# Sessionструктуре
# Количество игроков заданной команды
def count_players_in_team(con):
    try:
        query = '''select count(*)
                     from players
                     where players.team_id = 1610612762'''
        cnt = con.execute(query).fetchone()[0]
        print(cnt)
    except Exception:
        print("Возникла проблема")


# Названия команд, в аббрвиатуре которых есть "MI"
def teams_with_MI(con):
    try:
        query = '''SELECT DISTINCT team_id, team_abbreviation
        FROM games_details 
        WHERE team_abbreviation LIKE '%MI%'
        '''
        teams = con.execute(query).fetchall()

        print(tabulate(teams, headers=['team_id', 'team_abbreviation']))
    except Exception:
        print("Возникла проблема")


# Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
# Вывести все данные о командах, у которых количество сыгранных игр в сезоне больше среднего количества игр в сезоне(по всем игрокам)
def number_of_games_more_than_avg(con):
    try:
        query = '''SELECT *
        FROM ranking
        WHERE g_i > (SELECT AVG(g_i) FROM ranking) '''

        answ = con.execute(query).fetchall()
        print(tabulate(answ, headers=['team_id', 'season_id', 'team']))
    except Exception:
        print("Возникла проблема")


# Вывести среднее количество побед в 2019 сезоне по восточной и западной конференции
def avg_win_in_2019_west_cost(con):
    try:
        query = '''SELECT CAST(AVG(w) as INT), season_id, conference
        FROM ranking
        GROUP BY conference, season_id
        HAVING season_id = 22019 '''

        answ = con.execute(query).fetchall()
        print(tabulate(answ, headers=['avg', 'season_id', 'conference']))
    except Exception:
        print("Возникла проблема")


# Вывести id команды, сезон, среднее количество побед по сезону(сортровка по w_ptc), минимальное количество победы), номера строк с сортировкой по рекорду дома
def over_partition(con):
    try:
        query = '''SELECT team_id, season_id,
                    AVG(w)
                    OVER (PARTITION BY season_id order by w_pct)as avg_w_team,
                    ROW_NUMBER()
                    OVER (PARTITION BY season_id order by home_record) as row_num
                    FROM ranking'''

        answ = con.execute(query).fetchall()
        print(tabulate(answ, headers=['team_id', 'season_id', 'avg_w_team', 'row_num']))
    except Exception:
        print("Возникла проблема")


#  Создать XML/JSON документ, извлекая его из таблиц
# Вашей базы данных с помощью инструкции SELECT. Создать три запроса:
# 1. Чтение из XML/JSON документа.
# 2. Обновление XML/JSON документа.
# 3. Запись (Добавление) в XML/JSON документ.

# Запись в JSON документ, извлекая его из таблиц
def create_players_json(con):
    try:
        query = '''
        copy(select
        array_to_json(array_agg(row_to_json(t))) as "players"
        from players as t)
        to
        '/tmp/players.json' '''
        con.execute(query)
    except Exception:
        print("Возникла проблема")


# Чтение из JSON документа
def read_from_json(con):
    try:
        query = '''


                create temporary table json_import (values text);
            copy json_import from '/tmp/players.json';

            create temporary table players_json(
                PLAYER_NAME TEXT, 
                TEAM_ID INTEGER CHECK(TEAM_ID > 0),
                PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
            );

            insert into players_json("player_name", "team_id", "player_id")
            select  j->>'player_name' as player_name,
            CAST(j->>'team_id' as integer) as team_id,
            CAST(j->>'player_id' as integer) as player_id
            from   (
                       select json_array_elements(replace(values,'\','\\')::json) as j 
                       from   json_import
                   ) a where j->'player_name' is not null ;
            select * from players_json;

        '''
        answ = con.execute(query).fetchall()
        print(tabulate(answ, headers=['player_name', 'team_id', 'player_id']))

    except Exception:
        print("Возникла проблема")


# Обновление JSON документа
def update_json(con):
    try:
        query = ''' 
                    create temporary table json_import (values text);
                    copy json_import from '/tmp/players.json';

                    create temporary table players_json_frg(
                        PLAYER_NAME TEXT, 
                        TEAM_ID INTEGER CHECK(TEAM_ID > 0),
                        PLAYER_ID INTEGER CHECK(PLAYER_ID > 0) PRIMARY KEY
                    );

                    insert into players_json_frg("player_name", "team_id", "player_id")
                    select  j->>'player_name' as player_name,
                    CAST(j->>'team_id' as integer) as team_id,
                    CAST(j->>'player_id' as integer) as player_id
                    from   (
                               select json_array_elements(replace(values,'\','\\')::json) as j 
                               from   json_import
                           ) a where j->'player_name' is not null;
                    select * from players_json_frg;


                    update players_json_frg
                    set player_name = ' new_name'
                    where player_id = 202711;

                    select * from players_json_frg;


                    '''
        answ = con.execute(query).fetchall()
        print(tabulate(answ, headers=['player_name', 'team_id', 'player_id']))

    except Exception:
        print("Возникла проблема")


# Создать классы сущностей, которые моделируют таблицы
# Вашей базы данных. Создать запросы четырех типов:
# 1. Однотабличный запрос на выборку.
# 2. Многотабличный запрос на выборку.
# 3. Три запроса на добавление, изменение и удаление данных в базе
# данных.
# 4. Получение доступа к данным, выполняя только хранимую
# процедуру.

Base = declarative_base()

class Players(Base):
    __tablename__ = 'players'

    player_name = Column(types.Text())
    team_id = Column(types.Integer())
    player_id = Column(types.Integer(), primary_key=True)



class Games(Base):

    __tablename__ = 'games'
    game_date_est = Column(types.Date())
    game_id = Column(types.Integer(), unique=True, primary_key=True)
    game_status_text = Column(types.Text())
    home_team_id = Column(types.Integer())
    visitor_team_id = Column(types.Integer())
    season = Column(types.SmallInteger())
    team_id_home = Column(types.Integer())
    pts_home = Column(types.Numeric())
    fg_pct_home = Column(types.Numeric())
    ft_pct_home = Column(types.Numeric())
    fg3_pct_home = Column(types.Numeric())
    ast_home = Column(types.Numeric())
    reb_homee = Column(types.Numeric())
    team_id_away = Column(types.Numeric())
    pts_away = Column(types.Numeric())
    fg_pct_away = Column(types.Numeric())
    ft_pct_away = Column(types.Numeric())
    fg3_pct_away = Column(types.Numeric())
    ast_away= Column(types.Numeric())
    reb_away = Column(types.Numeric())
    home_team_wins = Column(types.SmallInteger())


class Teams(Base):
    __tablename__ = 'teams'
    league_id = Column(types.Integer())
    team_id = Column(types.Integer(), primary_key=True)
    min_year = Column(types.SmallInteger())
    max_year = Column(types.SmallInteger())
    abbreviation = Column(types.Text())
    nickname = Column(types.Text())
    yearfounded = Column(types.Integer())
    city = Column(types.Text())
    arena = Column(types.Text())
    arenacapacity = Column(types.Integer())
    com_owner = Column(types.Text())
    generalmanager = Column(types.Text())
    headcoach = Column(types.Text())
    dleagueaffiliation = Column(types.Text())

    def __tuple(self):
        return (self.league_id, self.team_id, self.abbreviation)

class Games_details(Base):
   __tablename__ = 'games_details'
   id = Column(types.Integer(), primary_key=True)
   game_id = Column(types.Integer(), ForeignKey('games.game_id'))
   team_id  = Column(types.Integer(), ForeignKey('teams.team_id'))
   team_abbreviation = Column(types.Text())
   team_city = Column(types.Text())
   player_id = Column(types.Integer())
   player_name = Column(types.Text())
   start_position = Column(types.Text())
   comment_t = Column(types.Text())
   min_time = Column(types.Text())
   fgm = Column(types.Numeric())
   fga = Column(types.Numeric())
   fg_pct = Column(types.Numeric())
   fg3m = Column(types.Numeric())
   fg3a = Column(types.Numeric())
   fg3_pct = Column(types.Numeric())
   ftm = Column(types.Numeric())
   fta = Column(types.Numeric())
   ft_pct = Column(types.Numeric())
   oreb = Column(types.Numeric())
   dreb = Column(types.Numeric())
   reb = Column(types.Numeric())
   ast = Column(types.Numeric())
   stl = Column(types.Numeric())
   blk = Column(types.Numeric())
   t_num = Column(types.Numeric())
   pf = Column(types.Numeric())
   pts = Column(types.Numeric())
   plus_minus = Column(types.Numeric())

   def __tuple(self):
       return (self.team_id, self.team_abbreviation)

class Ranking(Base):
    __tablename__ = 'ranking'
    id = Column(types.Integer(), primary_key=True)
    team_id = Column(types.Integer(), ForeignKey('teams.team_id'))
    league_id = Column(types.Integer())
    season_id = Column(types.Integer())
    standingsdate = Column(types.Date())
    conference = Column(types.Text())
    team = Column(types.Text())
    g_i = Column(types.SmallInteger())
    w = Column(types.SmallInteger())
    l = Column(types.SmallInteger())
    w_pct = Column(types.Numeric())
    home_record = Column(types.Text())
    road_record = Column(types.Text())

class Work_kind(Base):
    __tablename__ = 'work_kind'
    w_id = Column(types.Integer(), primary_key=True)
    name = Column(types.Text())
    expenditures = Column(types.Integer())
    equipment = Column(types.Text())

class W_e(Base):
    __tablename__ = 'w_e'
    id = Column(types.Integer(), primary_key=True)
    w_id = Column(types.Integer(), ForeignKey('work_kind.w_id'))
    Column(types.Integer())

# Добавить игрока
def add_player(conn):
    try:
        player_name = str(input('Player_name >'))
        team_id = str(input('Team_id >'))
        player_id = str(input('Player_id >'))
        new_player = Players(player_name=player_name, team_id=team_id, player_id=player_id)
        conn.add(new_player)
        conn.commit()
    except Exception:
        print("Возникла проблема")

#Изменить игрока
def update_player(conn):
    try:
        old_id = str(input('Player_id to find > '))
        new_player_name = str(input('New player_name >'))
        new_team_id = str(input('New team_id >'))
        new_player_id = str(input('New player_id >'))

        player = conn.query(Players).filter(
            # pylint: disable=no-member
            Players.player_id == old_id
        ).first()

        if player:
            player.player_name = new_player_name
            player.player_id = new_player_id
            player.team_id = new_team_id
            print("Данные об игроке изменены")
        else:
            print("Игрок не найден")

        conn.commit()

    except Exception:
        print("Возникла проблема")


def del_player(conn):
    try:
        player_id_del = str(input('Player_id to find > '))
        player = conn.query(Players).filter(
            # pylint: disable=no-member
            Players.player_id == player_id_del
        ).first()

        if player:
            conn.delete(player)
            print("Игрок удалён")
        else:
            print("Игрок не найден")

        conn.commit()
    except Exception:
        print("Возникла проблема")

#однотабличный запрос
#вывести всех игроков команды 1610612762
def get_players(conn):
    try:
        query = conn.query(Players.player_name, Players.team_id, Players.player_id).filter(text('team_id = 1610612762')).all()
        conn.commit()
        print(tabulate(query, headers=['player_name', 'team_id', 'player_id']))

    except Exception:
        print("Возникла проблема")

def get_teams_with_MI(conn):
    try:
        cname = str('MIL')
        query = conn.query(Games_details.team_abbreviation, Teams.team_id).filter(
            Games_details.team_id == Teams.team_id).filter(text(' games_details.team_abbreviation = :cname ')).params(cname=cname).first()

        print(query[0], query[1])
        conn.commit()
    except Exception:
        print("Возникла проблема")

#вызов хранимой процедуры
def get_procedure(conn):
    try:
        conn.execute(func.update_equipment('c_q', 'AAAAAAAAAAA'))
        conn.commit()
    except Exception:
        print("Возникла проблема")

def print_menu():
    print("\n\
1.  Количество игроков заданной команды 1610612762 \n\
2.  Названия команд, в аббрвиатуре которых есть MI \n\
3.  Вывести все данные о командах, у которых количество сыгранных игр в сезоне больше среднего количества игр в сезоне(по всем игрокам) \n\
4.  Вывести среднее количество побед в 2019 сезоне по восточной и западной конференции \n\
5.  Вывести id команды, сезон, среднее количество побед по сезону(сортровка по w_ptc), минимальное количество победы), номера строк с сортировкой по рекорду дома \n\
6.  Создать players.json\n\
7.  Прочитать из players.json \n\
8.  Обновление документа players.json\n\
9.  Добавить игрока \n\
10. Изменить игрока\n\
11. Удалить игрока\n\
12. Однотабличный запрос\n\
13. Многотабличный запрос\n\
14. Вызов хранимой процедуры\n\
15. Выход")


execute = [
    '__empty__',

    count_players_in_team, teams_with_MI, number_of_games_more_than_avg, avg_win_in_2019_west_cost, over_partition,
    create_players_json, read_from_json, update_json, add_player, update_player, del_player, get_players, get_teams_with_MI, get_procedure,

    lambda: print('Bye!')
]
__exit = len(execute) - 1

if __name__ == '__main__':
    choice = -1
    con = Session(bind=engine)
    while choice != __exit:
        print_menu()
        choice = int(input('> '))
        execute[choice](con)
    con.close()