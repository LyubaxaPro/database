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