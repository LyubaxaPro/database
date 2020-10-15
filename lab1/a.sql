ALTER TABLE players
add constraint PLAYER_NAME
CHECK(PLAYER_NAME ~* '^[^0-9]+$')

DROP TABLE games_details;
DROP TABLE players;

