-- 1)Инструкция SELECT, использующая предикат сравнения.
-- Вывести имена игроков из команды с id = 1610612762
SELECT DISTINCT players.player_name
FROM players
WHERE players.team_id = 1610612762

-- 2)Инструкция SELECT, использующая предикат BETWEEN.
-- Вывести названия команд, у которых количество побед(в процентах) находится между 0.6 и 0.7

SELECT DISTINCT team, w_pct
FROM ranking 
WHERE w_pct BETWEEN 0.6 AND 0.7

-- 3)Инструкция SELECT, использующая предикат LIKE.
-- Названия команд, в аббрвиатуре которых есть "MI"

SELECT DISTINCT team, team_abbreviation
FROM games_details JOIN ranking ON games_details.team_id = ranking.team_id
WHERE team_abbreviation LIKE '%MI%'

-- 4) Инструкция SELECT, использующая предикат IN с вложенным подзапросом.
--ID игры и сезон игр проходивших в Далласе
SELECT game_id, season
FROM games
WHERE game_id in 
(
	SELECT game_id
	from games_details
	WHERE team_city ='Dallas'
)

-- 5)Инструкция SELECT, использующая предикат EXISTS(Возвращает значение TRUE, если вложенный запрос содержит хотя бы одну строку.) с вложенным подзапросом.
-- Вывести имена, id, id команды и стартовую позицию игроков, id которых находитс я в интервале [200000, 201577]
SELECT players.player_id, players.player_name, players.team_id, start_position
FROM players JOIN games_details ON (players.player_id = games_details.player_id)
WHERE EXISTS 
(
	SELECT player_id
	from games_details
	WHERE player_id BETWEEN 200000 AND 201577
)

-- 6)Инструкция SELECT, использующая предикат сравнения с квантором.
-- Вывести список игроков, которые набрали больше очков чем другие в команде MIL
SELECT player_id, game_id, pts, team_abbreviation
from games_details
WHERE pts > ALL
(
	SELECT pts
	from games_details
	WHERE team_abbreviation = 'MIL'
)

-- 7)Инструкция SELECT, использующая агрегатные функции в выражениях столбцов.
-- AVG - Эта функция возвращает среднее арифметическое группы значений. Значения NULL она не учитывает.
-- Вывести среднее количество проигрышей за все сезоны у команды с id 1610612763
SELECT AVG(L) AS average_number_of_games_lost
FROM ranking
WHERE ranking.team_id = 1610612763

-- 8)Инструкция SELECT, использующая скалярные подзапросы в выражениях столбцов.
-- Вывести все данные о командах, у которых количество сыгранных игр в сезоне больше среднего количества игр в сезоне(по всем игрокам)
SELECT *
FROM ranking
WHERE g_i > (SELECT AVG(g_i) FROM ranking)

-- 9)Инструкция SELECT, использующая простое выражение CASE
-- Вывод объяснения начальной позиции игрока
SELECT player_name, start_position,
	CASE start_position
		WHEN 'F' THEN 'Position is F'
		WHEN 'G' THEN 'Position is G'
		WHEN 'C' THEN 'Position is C'
		ELSE 'bench spare'
	END position_description
FROM games_details

-- 10)Инструкция SELECT, использующая поисковое выражение CASE.
-- Анализ года создания команды
SELECT team_id, abbreviation, yearfounded,
	CASE 
		WHEN yearfounded < 1990 THEN 'OLD'
		ELSE 'YOUNG'
	END yearfounded_description
FROM teams


-- 11)Создание новой временной локальной таблицы из результирующего набора данных инструкции SELECT.
-- Создать временную таблицу лучших команд в которых количество выйгранных матчей в сезоне больше 40
CREATE TEMP TABLE 
best_teams AS
SELECT team, conference, w
from ranking
WHERE w > 40

-- 12)Инструкция SELECT, использующая вложенные коррелированные подзапросы в качестве производных таблиц в предложении FROM.
--вывести все команды которые набрали дома > 1500 очков
SELECT DISTINCT team_id, team, w
FROM ranking r JOIN LATERAL 
(SELECT team_id_home, pts_home FROM games WHERE r.w * pts_home > 1500) g 
ON r.team_id = g.team_id_home;

-- 13) Инструкция SELECT, использующая вложенные подзапросы с уровнем вложенности 3.
-- Вывести id, имя, id команды игроков, которые в домашнем матче набрали больше очков чем среднее количество очков в западной конференции.
SELECT player_id, player_name, team_id
FROM players
WHERE team_id in 
(
	SELECT home_team_id
	FROM games
	WHERE pts_home >
	(
		SELECT AVG(pts)
		FROM games_details
		WHERE team_id IN
		(
			SELECT team_id
			FROM ranking
			WHERE conference = 'West'
		)
	)
)

-- 14) Инструкция SELECT, консолидирующая данные с помощью предложения GROUP BY, но без предложения HAVING.
-- Вывести среднее количество побед в 2019 сезоне по восточной и западной конференции
SELECT CAST(AVG(w) as INT),  conference
FROM ranking
WHERE season_id = 22019
GROUP BY conference


-- 15)Инструкция SELECT, консолидирующая данные с помощью предложения
-- Вывести среднее количество побед в 2019 сезоне по восточной и западной конференции
GROUP BY и предложения HAVING.
SELECT CAST(AVG(w) as INT), season_id, conference
FROM ranking
GROUP BY conference, season_id
HAVING season_id = 22019

-- 16) Однострочная инструкция INSERT, выполняющая вставку в таблицу одной строки значений.
-- добавить строчку в таблицу игроков
INSERT INTO players VALUES ('Ali Horfooord', 1610342555, 221133);

-- 17) Многострочная инструкция INSERT, выполняющая вставку в таблицу результирующего набора данных вложенного подзапроса.
INSERT INTO players 
SELECT player_name, player_id, fgm
FROM games_details
WHERE team_abbreviation = 'MIL'
LIMIT 5

-- 18) Простая инструкция UPDATE.
UPDATE players
SET player_name = 'Mil Horfooord'
WHERE player_id = 221133

--19)Инструкция UPDATE со скалярным подзапросом в предложении SET
UPDATE ranking
SET w =
(
SELECT AVG(w)
FROM ranking
WHERE team_id = 1610612749
)
WHERE team_id = 1610612749

-- 20) Простая инструкция DELETE.
DELETE FROM games_details
WHERE team_abbreviation = 'ATL'

--21)Инструкция DELETE с вложенным коррелированным подзапросом в предложении WHERE
DELETE FROM games_details
WHERE pts in (SELECT pts_home FROM games WHERE pts_home <100)

-- 22) Инструкция SELECT, использующая простое обобщенное табличное выражение
Выбрать из таблицы среднее количество проигрышей и выйгрышей по командам
WITH results(avg_w, avg_l, team)
AS 
(
	SELECT CAST(AVG(w) as INT), CAST(AVG(l) as INT), team
	FROM ranking
	GROUP BY team
	
)
SELECT *
FROM results

--23)Инструкция SELECT, использующая рекурсивное обобщенное табличное выражение
--Найдём все пары ментор-игрок
WITH RECURSIVE subordinates AS (
	SELECT
		player_name,
		player_id,
		mentor_id
	FROM
		players
	WHERE
		player_id = 202711
	UNION
		SELECT
			players.player_name, players.player_id, players.mentor_id
		FROM
			players
		JOIN subordinates ON subordinates.player_id = players.mentor_id
) SELECT
	*
FROM
	subordinates;

-- 24)Оконные функции. Использование конструкций MIN/MAX/AVG OVER()
--Order by

--Оператор Order by выполняет сортировку выходных значений, т.е. сортирует извлекаемое значение по определенному столбцу. Сортировку также можно применять по псевдониму столбца, который определяется с помощью оператора.

--Сортировка по возрастанию применяется по умолчанию. Если хотите отсортировать столбцы по убыванию — используйте дополнительный оператор DESC.

--OVER PARTITION BY(столбец для группировки) — это свойство для задания размеров окна. Здесь можно указывать дополнительную информацию, давать служебные команды, например добавить номер строки. Синтаксис оконной функции вписывается прямо в выборку столбцов.

-- Вывести id команды, сезон, среднее количество побед по сезону(сортровка по w_ptc), минимальное количество победы), номера строк с сортировкой по рекорду дома
SELECT team_id, season_id,
AVG(w)
OVER (PARTITION BY season_id order by w_pct)as avg_w_team,
ROW_NUMBER()
OVER (PARTITION BY season_id order by home_record) as row_num
FROM ranking


--25)Оконные фнкции для устранения дублей
CREATE TABLE test( name VARCHAR NOT NULL, surname VARCHAR NOT NULL, age INTEGER);
INSERT INTO test (name, surname, age) VALUES 
('Ann', 'Kosenko', 12), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Brian', 'Shaw', 22), ('Ann', 'Kosenko', 12);

WITH test_deleted AS(DELETE FROM test RETURNING *),
test_inserted AS(SELECT name, surname, age, ROW_NUMBER() OVER(PARTITION BY name, surname, age ORDER BY name, surname, age) 
 				 rownum FROM test_deleted)INSERT INTO test SELECT name, surname, age
				 FROM test_inserted WHERE rownum = 1;
SELECT *
FROM test
