CREATE TABLE NEW_DUEL (
    id                SERIAL NOT NULL,
    duel_date         date NOT NULL,
    home_team_id      int4 NOT NULL,
    away_team_id      int4 NOT NULL,
    location_id       int4 NOT NULL,
    competition_id    int4,
    start_time        timestamp NOT NULL,
    sport_category_id int4 NOT NULL,
    home_team_score int4,
    away_team_score int4,
    PRIMARY KEY (id, duel_date)
) PARTITION BY RANGE (duel_date);


CREATE TABLE DUEL_YEARS_RANGES (
    year_start date,
    year_end date,
    PRIMARY KEY (year_start, year_end),
    CONSTRAINT years_c CHECK (year_start < year_end)
);


INSERT INTO DUEL_YEARS_RANGES(year_start, year_end)
SELECT DISTINCT
    make_date(extract(YEAR from start_time)::int, 1, 1) as year_start,
    make_date(extract(YEAR from start_time)::int + 1, 1, 1) as year_end
FROM duel
ORDER BY year_start;


DO $$
DECLARE
    r RECORD;
    partition_name TEXT;
BEGIN
    FOR r IN SELECT year_start, year_end FROM DUEL_YEARS_RANGES LOOP
        partition_name := 'new_duel_' || extract(YEAR from r.year_start);

        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS %I PARTITION OF new_duel FOR VALUES FROM (%L) TO (%L);',
            partition_name, r.year_start, r.year_end
        );
    END LOOP;
END $$;


INSERT INTO new_duel (id, duel_date, home_team_id, away_team_id, location_id, competition_id,
                      start_time, sport_category_id, home_team_score, away_team_score)
SELECT id, date(start_time), home_team_id, away_team_id, location_id, competition_id,
       start_time, sport_category_id, home_team_score, away_team_score
FROM duel;


CREATE TABLE NEW_TEAM_ROSTER (
    player_ssn char(13) NOT NULL,
    team_id    int4 NOT NULL,
    duel_id    int4 NOT NULL,
    duel_date   date NOT NULL,
    start_time time NOT NULL,
    end_time   time
);

INSERT INTO NEW_TEAM_ROSTER (player_ssn, team_id, duel_id, duel_date, start_time, end_time)
SELECT tr.player_ssn, tr.team_id, d.id, d.start_time::date, tr.start_time, tr.end_time
FROM team_roster tr
JOIN duel d ON tr.duel_id = d.id;


CREATE TABLE NEW_REFEREEING_DUEL (
    referee_ssn char(13) NOT NULL,
    duel_id     int4 NOT NULL,
    duel_date   date NOT NULL
);

INSERT INTO NEW_REFEREEING_DUEL (referee_ssn, duel_id, duel_date)
SELECT rd.referee_ssn, d.id, d.start_time::date from refereeing_duel rd
JOIN duel d ON rd.duel_id = d.id;


CREATE TABLE NEW_SCORE (
    id          int4 NOT NULL,
    duel_id     int4 NOT NULL,
    duel_date   date NOT NULL,
    player_ssn  char(13) NOT NULL,
    time_score  time NOT NULL
);

INSERT INTO NEW_SCORE (id, duel_id, duel_date, player_ssn, time_score)
SELECT s.id, d.id, d.start_time::date, s.player_ssn, s.time_score from score s
JOIN duel d ON s.duel_id = d.id;


ALTER TABLE NEW_DUEL
ADD COLUMN duel_time time;

UPDATE NEW_DUEL
SET duel_time = start_time::time;

ALTER TABLE NEW_DUEL
DROP COLUMN start_time,
ADD CONSTRAINT nd_competition_fk FOREIGN KEY (competition_id) REFERENCES COMPETITION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_home_team_fk FOREIGN KEY (home_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_away_team_fk FOREIGN KEY (away_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_location_fk FOREIGN KEY (location_id) REFERENCES LOCATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_different_teams_c CHECK ( home_team_id != away_team_id );


ALTER TABLE NEW_TEAM_ROSTER
ADD PRIMARY KEY (player_ssn, team_id, duel_id, duel_date),
ADD CONSTRAINT ntr_roster_date_check CHECK ( end_time IS NULL OR start_time < end_time),
ADD CONSTRAINT ntr_sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_duel_id FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_REFEREEING_DUEL
ADD PRIMARY KEY (referee_ssn, duel_id, duel_date),
ADD CONSTRAINT nrd_nd_fk FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nrd_referee_fk FOREIGN KEY (referee_ssn) REFERENCES REFEREE (ssn) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_SCORE
ADD PRIMARY KEY (id),
ADD CONSTRAINT ns_player_ssn FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ns_duel_id FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;
