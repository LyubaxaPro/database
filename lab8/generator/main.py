import random
import datetime
import time
import csv

FILENAME = "/home/maksim/lyubaxapro/database/lab1/players.csv"

players_id = []
teams_id = []
with open(FILENAME, "r", newline="") as file:
    reader = csv.reader(file)
    for row in reader:
        players_id.append(row[2])
        teams_id.append(row[1])

names = ['Harry', 'Oliver', 'Jack', 'Charlie', 'Thomas', 'Jacob', 'Alfie', 'Riley', 'William', 'James', 'Daniel', 'Noah']
surnames = ['Abramson', 'Adderiy', 'Atcheson', 'Baldwin', 'Becker', 'Boolman', 'Carrington', 'Daniels']

id = 0
while (1):
    id += 1
    now = datetime.datetime.now()

    f = open(str(id) + '_players_table_' + str(now.year) + '-' + str(now.month) + '-' + str(now.day) + '.csv', 'w')
    f.write(
        'PLAYER_NAME' + ',' + 'TEAM_ID' + ',' + 'PLAYER_ID')

    for i in range(2):
        name = random.choice(names) + ' ' + random.choice(surnames)
        f.write("\n" + name + ',')
        team_id = random.choice(teams_id)
        f.write(team_id + ',')

        player_id = random.randint(1, 100000000)
        while player_id in players_id:
            player_id = random.randint(1, 100000000)

        f.write(str(player_id))

    f.close()
    time.sleep(5)