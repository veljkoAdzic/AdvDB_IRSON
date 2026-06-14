CREATE TABLE NEW_DUEL (
    id                SERIAL NOT NULL,
    duel_date         date NOT NULL,
    home_team_id      int4 NOT NULL,
    away_team_id      int4 NOT NULL,
    location_id       int4 NOT NULL,
    competition_id    int4,
    duel_time         time NOT NULL,
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

INSERT INTO NEW_DUEL (
    id, duel_date, home_team_id,
    away_team_id, location_id, competition_id, duel_time, 
    sport_category_id, home_team_score, away_team_score
    )
SELECT
    d.id,
    d.start_time::date as duel_date,
    d.home_team_id,
    d.away_team_id,
    d.location_id,
    d.competition_id,
    d.start_time::time as duel_time,
    d.sport_category_id,
    d.home_team_score,
    d.away_team_score
FROM DUEL d
ORDER BY d.start_time;

-- Migracija na id sekvenca
SELECT
    setval(
        pg_get_serial_sequence('new_duel', 'id'),
        (SELECT last_value FROM pg_sequences WHERE
        schemaname || '.' || sequencename = pg_get_serial_sequence('duel', 'id'))
    )
;



CREATE TABLE NEW_TEAM_ROSTER (
    player_ssn char(13) NOT NULL,
    team_id    int4 NOT NULL,
    duel_id    int4 NOT NULL,
    duel_date  date NOT NULL,
    start_time time NOT NULL,
    end_time   time
);

CREATE TABLE NEW_REFEREEING_DUEL (
    referee_ssn char(13) NOT NULL,
    duel_id     int4 NOT NULL,
    duel_date   date NOT NULL
);

CREATE TABLE NEW_SCORE (
    id          SERIAL NOT NULL,
    duel_id     int4 NOT NULL,
    duel_date   date NOT NULL,
    player_ssn  char(13) NOT NULL,
    time_score  time NOT NULL
);


INSERT INTO NEW_TEAM_ROSTER (player_ssn, team_id, duel_id, duel_date, start_time, end_time)
SELECT
    tr.player_ssn,
    tr.team_id,
    nd.id,
    nd.duel_date,
    tr.start_time,
    tr.end_time
FROM team_roster tr
JOIN duel d ON tr.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.id;

INSERT INTO NEW_REFEREEING_DUEL (referee_ssn, duel_id, duel_date)
SELECT
    rd.referee_ssn,
    nd.id,
    nd.duel_date
FROM refereeing_duel rd
JOIN duel d ON rd.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.id;

INSERT INTO NEW_SCORE (id, duel_id, duel_date, player_ssn, time_score)
SELECT
    s.id,
    nd.id,
    nd.duel_date,
    s.player_ssn,
    s.time_score
FROM score s
JOIN duel d ON s.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.id;

-- Migracija na id sekvenca
SELECT
    setval(
        pg_get_serial_sequence('new_score', 'id'),
        (SELECT last_value FROM pg_sequences WHERE
        schemaname || '.' || sequencename = pg_get_serial_sequence('score', 'id'))
    )
;

ALTER TABLE NEW_DUEL
ADD CONSTRAINT nd_competition_fk FOREIGN KEY (competition_id) REFERENCES COMPETITION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_home_team_fk FOREIGN KEY (home_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_away_team_fk FOREIGN KEY (away_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_location_fk FOREIGN KEY (location_id) REFERENCES LOCATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_different_teams_c CHECK (home_team_id != away_team_id);


ALTER TABLE NEW_TEAM_ROSTER
ADD PRIMARY KEY (player_ssn, team_id, duel_id, duel_date),
ADD CONSTRAINT ntr_roster_date_check CHECK (end_time IS NULL OR start_time < end_time),
ADD CONSTRAINT ntr_sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_duel_fk FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_REFEREEING_DUEL
ADD PRIMARY KEY (referee_ssn, duel_id, duel_date),
ADD CONSTRAINT nrd_nd_fk FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nrd_referee_fk FOREIGN KEY (referee_ssn) REFERENCES REFEREE (ssn) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_SCORE
ADD PRIMARY KEY (id),
ADD CONSTRAINT ns_player_ssn FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ns_duel_fk FOREIGN KEY (duel_id, duel_date) REFERENCES NEW_DUEL (id, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;


-- NOTE: Dali da se ima triger za avtomatska migracija pri sluchajno INSERT/UPDATE vo duel?

CREATE OR REPLACE FUNCTION migrate_to_new_duel()
RETURNS TRIGGER AS $$
DECLARE

BEGIN
    IF NOT EXISTS(SELECT 1 FROM NEW_DUEL WHERE id = NEW.id) THEN
        INSERT INTO NEW_DUEL (
        id, duel_date, home_team_id,
        away_team_id, location_id, competition_id, duel_time,
        sport_category_id, home_team_score, away_team_score
        )VALUES
         (
            NEW.id,
            NEW.start_time::date,
            NEW.home_team_id,
            NEW.away_team_id,
            NEW.location_id,
            NEW.competition_id,
            NEW.start_time::time,
            NEW.sport_category_id,
            NEW.home_team_score,
            NEW.away_team_score
        );
    ELSE
        UPDATE NEW_DUEL
        SET duel_date = NEW.start_time::date,
            home_team_id = NEW.home_team_id,
            away_team_id = NEW.away_team_id,
            location_id = NEW.location_id,
            competition_id = NEW.competition_id,
            duel_time = NEW.start_time::time,
            sport_category_id = NEW.sport_category_id,
            home_team_score = NEW.home_team_score,
            away_team_score = NEW.away_team_score
        WHERE id = NEW.id;
    END IF;

    RETURN NEW;
END $$;
CREATE TRIGGER trg_migrate_to_new_duel
AFTER INSERT OR UPDATE ON duel
FOR EACH ROW
EXECUTE FUNCTION migrate_to_new_duel();

---------------- TRIGGER MIGRATION -----------------------

CREATE OR REPLACE FUNCTION check_new_team_roster_contract()
RETURNS trigger AS $$
DECLARE
    team_club_id    INT;
    max_capacity    INT;
    active_players  INT;
BEGIN
    SELECT club_id
    INTO team_club_id
    FROM sport_team
    WHERE id = NEW.team_id;

    SELECT sc.team_capacity
    INTO max_capacity
    FROM duel d
    JOIN sport_category sc ON sc.id = d.sport_category_id
    WHERE d.id = NEW.duel_id;

    SELECT COUNT(*)
    INTO active_players
    FROM new_team_roster
    WHERE team_id = NEW.team_id
      AND duel_id = NEW.duel_id
      AND end_time IS NULL
      AND player_ssn <> NEW.player_ssn;

    IF active_players >= max_capacity THEN
        RAISE EXCEPTION 'Cannot exceed team capacity of % active players for this duel', max_capacity;
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM sportsperson_contract c
        JOIN new_duel d ON d.id = NEW.duel_id
        WHERE c.player_ssn = NEW.player_ssn
          AND c.club_id = team_club_id
          AND c.start_date <= d.duel_date
          AND COALESCE(c.end_date, 'infinity'::date) >= d.duel_date
    ) THEN
        RAISE EXCEPTION 'Player must have an active contract with the club on the duel date';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM new_team_roster
        WHERE player_ssn = NEW.player_ssn
          AND duel_id = NEW.duel_id
          AND team_id <> NEW.team_id
    ) THEN
        RAISE EXCEPTION 'Player is already rostered in another team for this duel';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_new_team_roster
BEFORE INSERT OR UPDATE ON team_roster
FOR EACH ROW
EXECUTE FUNCTION check_new_team_roster_contract();

-----------------------

CREATE OR REPLACE FUNCTION check_new_duel_validity()
RETURNS TRIGGER AS $$
DECLARE
    match_date DATE;
    home_club_id INT;
    away_club_id INT;
    home_is_rep BOOLEAN;
    away_is_rep BOOLEAN;
    home_federation_active BOOLEAN;
    away_federation_active BOOLEAN;
BEGIN
    match_date := NEW.duel_date;

    IF NEW.sport_category_id IS NULL THEN
        RAISE EXCEPTION 'Invalid sport category ID: %', NEW.sport_category_id;
    END IF;

    SELECT t.club_id, c.is_national_representation
    INTO home_club_id, home_is_rep
    FROM sport_team t
    JOIN sport_club c ON c.id = t.club_id
    WHERE t.id = NEW.home_team_id;

    SELECT t.club_id, c.is_national_representation
    INTO away_club_id, away_is_rep
    FROM sport_team t
    JOIN sport_club c ON c.id = t.club_id
    WHERE t.id = NEW.away_team_id;

    IF home_club_id IS NULL OR away_club_id IS NULL THEN
        RAISE EXCEPTION 'Invalid home or away team.';
    END IF;

    IF home_is_rep <> away_is_rep THEN
        RAISE EXCEPTION 'Teams must have the same representation status.';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM club_federation
        WHERE club_id = home_club_id
          AND start_date <= match_date
          AND (end_date IS NULL OR end_date >= match_date)
    )
    INTO home_federation_active;

    IF NOT home_federation_active THEN
        RAISE EXCEPTION
            'Home team club does not have an active federation participation on the match date.';
    END IF;

    SELECT EXISTS (
        SELECT 1
        FROM club_federation
        WHERE club_id = away_club_id
          AND start_date <= match_date
          AND (end_date IS NULL OR end_date >= match_date)
    )
    INTO away_federation_active;

    IF NOT away_federation_active THEN
        RAISE EXCEPTION
            'Away team club does not have an active federation participation on the match date.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        from sport_team st
        where st.club_id = home_club_id
            and st.sport_category_id=NEW.sport_category_id
    ) THEN
        RAISE EXCEPTION
            'Home team must play the same sport as the duel.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        from sport_team st
        where st.club_id = away_club_id
            and st.sport_category_id=NEW.sport_category_id
    ) THEN
        RAISE EXCEPTION
            'Away team must play the same sport as the duel.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_new_check_team_sport_and_rep
BEFORE INSERT OR UPDATE ON NEW_DUEL
FOR EACH ROW
EXECUTE FUNCTION check_new_duel_validity();

----------------------------------------------------------

CREATE VIEW new_upcoming_duels AS
SELECT
    nd.duel_date::date AS match_date,
    nd.duel_time::time AS kickoff,
    home.name AS home_team,
    away.name AS away_team,
    scat.name AS sport,
    l.name AS venue,
    l.capacity,
    c.name AS country,
    nd.competition_id,
    com.name AS competiton_name
FROM new_duel nd
JOIN sport_team home ON home.id = nd.home_team_id
JOIN sport_team away ON away.id = nd.away_team_id
JOIN sport_category scat ON scat.id = nd.sport_category_id
JOIN location l ON l.id = nd.location_id
JOIN country c ON c.id = l.country_id
LEFT JOIN competition com
    on com.id = nd.competition_id
WHERE nd.duel_date > CURRENT_DATE
   OR (nd.duel_date = CURRENT_DATE AND nd.duel_time > CURRENT_TIME);


DISCARD ALL;

--indeksot e dropnat
-- EXPLAIN (ANALYZE, BUFFERS)
EXPLAIN ANALYZE
SELECT * FROM upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

-- Sort  (cost=336310.46..336339.55 rows=11635 width=217) (actual time=1656.565..1661.213 rows=1384.00 loops=1)
-- "  Sort Key: ((d.start_time)::date), ((d.start_time)::time without time zone), l.capacity DESC"
--   Sort Method: quicksort  Memory: 402kB
--   Buffers: shared hit=16653 read=153628
--   ->  Gather Merge  (cost=334169.65..335524.74 rows=11635 width=217) (actual time=1649.680..1657.409 rows=1384.00 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         Buffers: shared hit=16642 read=153628
--         ->  Sort  (cost=333169.63..333181.75 rows=4848 width=217) (actual time=1583.010..1583.085 rows=461.33 loops=3)
--               Sort Key: com.name
--               Sort Method: quicksort  Memory: 97kB
--               Buffers: shared hit=16642 read=153628
--               Worker 0:  Sort Method: quicksort  Memory: 167kB
--               Worker 1:  Sort Method: quicksort  Memory: 163kB
--               ->  Nested Loop Left Join  (cost=1563.76..332872.85 rows=4848 width=217) (actual time=35.504..1581.008 rows=461.33 loops=3)
--                     Buffers: shared hit=16626 read=153628
--                     ->  Hash Join  (cost=1563.33..330627.31 rows=4848 width=164) (actual time=35.482..1572.587 rows=461.33 loops=3)
--                           Hash Cond: (d.sport_category_id = scat.id)
--                           Buffers: shared hit=11593 read=153143
--                           ->  Nested Loop  (cost=1550.75..330601.85 rows=4848 width=138) (actual time=34.423..1571.071 rows=461.33 loops=3)
--                                 Buffers: shared hit=11581 read=153140
--                                 ->  Nested Loop  (cost=1550.33..328336.37 rows=4848 width=97) (actual time=34.375..1565.186 rows=461.33 loops=3)
--                                       Buffers: shared hit=6322 read=152863
--                                       ->  Hash Join  (cost=1549.91..326070.90 rows=4848 width=56) (actual time=32.988..1557.061 rows=461.33 loops=3)
--                                             Hash Cond: (d.location_id = l.id)
--                                             Buffers: shared hit=1040 read=152607
--                                             ->  Parallel Seq Scan on duel d  (cost=0.00..322972.57 rows=399980 width=28) (actual time=2.238..1545.549 rows=75461.67 loops=3)
--                                                   Filter: ((start_time > now()) AND ((start_time)::date <= (CURRENT_DATE + 7)))
--                                                   Rows Removed by Filter: 5376621
--                                                   Buffers: shared read=152595
--                                             ->  Hash  (cost=1533.73..1533.73 rows=1294 width=36) (actual time=1.064..1.067 rows=433.00 loops=3)
--                                                   Buckets: 2048  Batches: 1  Memory Usage: 49kB
--                                                   Buffers: shared hit=1040 read=12
--                                                   ->  Nested Loop  (cost=0.42..1533.73 rows=1294 width=36) (actual time=0.660..0.952 rows=433.00 loops=3)
--                                                         Buffers: shared hit=1040 read=12
--                                                         ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.568..0.577 rows=1.00 loops=3)
--                                                               Filter: ((name)::text ~~ '%Macedonia'::text)
--                                                               Rows Removed by Filter: 164
--                                                               Buffers: shared hit=3
--                                                         ->  Index Scan using unique_name_per_country on location l  (cost=0.42..758.87 rows=647 width=32) (actual time=0.082..0.293 rows=433.00 loops=3)
--                                                               Index Cond: (country_id = c.id)
--                                                               Index Searches: 3
--                                                               Buffers: shared hit=1037 read=12
--                                       ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.47 rows=1 width=49) (actual time=0.016..0.016 rows=1.00 loops=1384)
--                                             Index Cond: (id = d.home_team_id)
--                                             Index Searches: 1384
--                                             Buffers: shared hit=5282 read=256
--                                 ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.47 rows=1 width=49) (actual time=0.012..0.012 rows=1.00 loops=1384)
--                                       Index Cond: (id = d.away_team_id)
--                                       Index Searches: 1384
--                                       Buffers: shared hit=5259 read=277
--                           ->  Hash  (cost=8.37..8.37 rows=337 width=34) (actual time=1.038..1.039 rows=337.00 loops=3)
--                                 Buckets: 1024  Batches: 1  Memory Usage: 31kB
--                                 Buffers: shared hit=12 read=3
--                                 ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=34) (actual time=0.424..0.952 rows=337.00 loops=3)
--                                       Buffers: shared hit=12 read=3
--                     ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.46 rows=1 width=53) (actual time=0.017..0.017 rows=1.00 loops=1384)
--                           Index Cond: (id = d.competition_id)
--                           Index Searches: 1379
--                           Buffers: shared hit=5033 read=485
-- Planning:
--   Buffers: shared hit=310 read=80
-- Planning Time: 16.338 ms
-- Execution Time: 1662.082 ms


DISCARD ALL;


EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM new_upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

-- Gather Merge  (cost=416332.29..417244.34 rows=7831 width=217) (actual time=308.689..314.420 rows=1384.00 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=16665 read=34185
--   ->  Sort  (cost=415332.27..415340.42 rows=3263 width=217) (actual time=240.837..240.884 rows=461.33 loops=3)
-- "        Sort Key: nd.duel_date, nd.duel_time, l.capacity DESC"
--         Sort Method: quicksort  Memory: 78kB
--         Buffers: shared hit=16665 read=34185
--         Worker 0:  Sort Method: quicksort  Memory: 263kB
--         Worker 1:  Sort Method: quicksort  Memory: 87kB
--         ->  Nested Loop Left Join  (cost=2693.99..415141.84 rows=3263 width=217) (actual time=46.022..239.981 rows=461.33 loops=3)
--               Buffers: shared hit=16617 read=34185
--               ->  Hash Join  (cost=2693.56..413617.95 rows=3263 width=168) (actual time=45.972..234.242 rows=461.33 loops=3)
--                     Hash Cond: (nd.sport_category_id = scat.id)
--                     Buffers: shared hit=11587 read=33697
--                     ->  Nested Loop  (cost=2680.98..413596.69 rows=3263 width=142) (actual time=45.381..233.411 rows=461.33 loops=3)
--                           Buffers: shared hit=11577 read=33692
--                           ->  Nested Loop  (cost=2680.56..412028.62 rows=3263 width=101) (actual time=45.331..229.938 rows=461.33 loops=3)
--                                 Buffers: shared hit=6305 read=33428
--                                 ->  Hash Join  (cost=2680.14..410460.56 rows=3263 width=60) (actual time=45.037..225.826 rows=461.33 loops=3)
--                                       Hash Cond: (nd.location_id = l.id)
--                                       Buffers: shared hit=1040 read=33155
--                                       ->  Parallel Append  (cost=1130.23..407868.40 rows=269230 width=32) (actual time=44.076..217.769 rows=75460.33 loops=3)
--                                             Buffers: shared read=33143
--                                             Subplans Removed: 10
--                                             ->  Parallel Seq Scan on new_duel_2026 nd_1  (cost=0.00..80065.88 rows=267239 width=32) (actual time=44.073..211.965 rows=75460.33 loops=3)
--                                                   Filter: ((duel_date <= (CURRENT_DATE + 7)) AND ((duel_date > CURRENT_DATE) OR ((duel_date = CURRENT_DATE) AND ((duel_time)::time with time zone > CURRENT_TIME))))
--                                                   Rows Removed by Filter: 997063
--                                                   Buffers: shared read=33143
--                                       ->  Hash  (cost=1533.73..1533.73 rows=1294 width=36) (actual time=0.910..0.912 rows=433.00 loops=3)
--                                             Buckets: 2048  Batches: 1  Memory Usage: 49kB
--                                             Buffers: shared hit=1040 read=12
--                                             ->  Nested Loop  (cost=0.42..1533.73 rows=1294 width=36) (actual time=0.575..0.815 rows=433.00 loops=3)
--                                                   Buffers: shared hit=1040 read=12
--                                                   ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.310..0.318 rows=1.00 loops=3)
--                                                         Filter: ((name)::text ~~ '%Macedonia'::text)
--                                                         Rows Removed by Filter: 164
--                                                         Buffers: shared hit=3
--                                                   ->  Index Scan using unique_name_per_country on location l  (cost=0.42..758.87 rows=647 width=32) (actual time=0.257..0.431 rows=433.00 loops=3)
--                                                         Index Cond: (country_id = c.id)
--                                                         Index Searches: 3
--                                                         Buffers: shared hit=1037 read=12
--                                 ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.48 rows=1 width=49) (actual time=0.008..0.008 rows=1.00 loops=1384)
--                                       Index Cond: (id = nd.home_team_id)
--                                       Index Searches: 1384
--                                       Buffers: shared hit=5265 read=273
--                           ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.48 rows=1 width=49) (actual time=0.007..0.007 rows=1.00 loops=1384)
--                                 Index Cond: (id = nd.away_team_id)
--                                 Index Searches: 1384
--                                 Buffers: shared hit=5272 read=264
--                     ->  Hash  (cost=8.37..8.37 rows=337 width=34) (actual time=0.581..0.582 rows=337.00 loops=3)
--                           Buckets: 1024  Batches: 1  Memory Usage: 31kB
--                           Buffers: shared hit=10 read=5
--                           ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=34) (actual time=0.462..0.539 rows=337.00 loops=3)
--                                 Buffers: shared hit=10 read=5
--               ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.47 rows=1 width=53) (actual time=0.012..0.012 rows=1.00 loops=1384)
--                     Index Cond: (id = nd.competition_id)
--                     Index Searches: 1379
--                     Buffers: shared hit=5030 read=488
-- Planning:
--   Buffers: shared hit=1035 read=110 dirtied=1
-- Planning Time: 17.475 ms
-- Execution Time: 314.849 ms

CREATE INDEX IF NOT EXISTS duel_upcoming_indexes ON
    duel(
         start_time,
         home_team_id,
        away_team_id,
        sport_category_id,
        location_id,
        competition_id
    );

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

-- Sort  (cost=128670.53..128699.62 rows=11635 width=217) (actual time=593.282..605.742 rows=1384.00 loops=1)
-- "  Sort Key: ((d.start_time)::date), ((d.start_time)::time without time zone), l.capacity DESC"
--   Sort Method: quicksort  Memory: 402kB
--   Buffers: shared hit=295914 read=18540
--   ->  Gather Merge  (cost=126529.72..127884.81 rows=11635 width=217) (actual time=588.603..603.018 rows=1384.00 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         Buffers: shared hit=295903 read=18540
--         ->  Sort  (cost=125529.70..125541.82 rows=4848 width=217) (actual time=545.745..545.811 rows=461.33 loops=3)
--               Sort Key: com.name
--               Sort Method: quicksort  Memory: 188kB
--               Buffers: shared hit=295903 read=18540
--               Worker 0:  Sort Method: quicksort  Memory: 118kB
--               Worker 1:  Sort Method: quicksort  Memory: 121kB
--               ->  Nested Loop Left Join  (cost=1564.32..125232.92 rows=4848 width=217) (actual time=1.539..543.164 rows=461.33 loops=3)
--                     Buffers: shared hit=295887 read=18540
--                     ->  Hash Join  (cost=1563.90..122987.38 rows=4848 width=164) (actual time=1.523..538.181 rows=461.33 loops=3)
--                           Hash Cond: (d.sport_category_id = scat.id)
--                           Buffers: shared hit=290854 read=18055
--                           ->  Nested Loop  (cost=1551.31..122961.92 rows=4848 width=138) (actual time=0.902..537.258 rows=461.33 loops=3)
--                                 Buffers: shared hit=290802 read=18052
--                                 ->  Nested Loop  (cost=1550.89..120696.44 rows=4848 width=97) (actual time=0.889..533.962 rows=461.33 loops=3)
--                                       Buffers: shared hit=285545 read=17773
--                                       ->  Hash Join  (cost=1550.47..118430.95 rows=4848 width=56) (actual time=0.859..530.342 rows=461.33 loops=3)
--                                             Hash Cond: (d.location_id = l.id)
--                                             Buffers: shared hit=280261 read=17519
--                                             ->  Parallel Index Only Scan using duel_upcoming_indexes on duel d  (cost=0.56..115332.68 rows=399966 width=28) (actual time=0.359..523.618 rows=75461.67 loops=3)
--                                                   Index Cond: (start_time > now())
--                                                   Filter: ((start_time)::date <= (CURRENT_DATE + 7))
--                                                   Rows Removed by Filter: 892947
--                                                   Heap Fetches: 0
--                                                   Index Searches: 1
--                                                   Buffers: shared hit=279221 read=17507
--                                             ->  Hash  (cost=1533.73..1533.73 rows=1294 width=36) (actual time=0.443..0.445 rows=433.00 loops=3)
--                                                   Buckets: 2048  Batches: 1  Memory Usage: 49kB
--                                                   Buffers: shared hit=1040 read=12
--                                                   ->  Nested Loop  (cost=0.42..1533.73 rows=1294 width=36) (actual time=0.221..0.382 rows=433.00 loops=3)
--                                                         Buffers: shared hit=1040 read=12
--                                                         ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.183..0.188 rows=1.00 loops=3)
--                                                               Filter: ((name)::text ~~ '%Macedonia'::text)
--                                                               Rows Removed by Filter: 164
--                                                               Buffers: shared hit=3
--                                                         ->  Index Scan using unique_name_per_country on location l  (cost=0.42..758.87 rows=647 width=32) (actual time=0.034..0.153 rows=433.00 loops=3)
--                                                               Index Cond: (country_id = c.id)
--                                                               Index Searches: 3
--                                                               Buffers: shared hit=1037 read=12
--                                       ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.47 rows=1 width=49) (actual time=0.007..0.007 rows=1.00 loops=1384)
--                                             Index Cond: (id = d.home_team_id)
--                                             Index Searches: 1384
--                                             Buffers: shared hit=5284 read=254
--                                 ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.47 rows=1 width=49) (actual time=0.006..0.006 rows=1.00 loops=1384)
--                                       Index Cond: (id = d.away_team_id)
--                                       Index Searches: 1384
--                                       Buffers: shared hit=5257 read=279
--                           ->  Hash  (cost=8.37..8.37 rows=337 width=34) (actual time=0.613..0.614 rows=337.00 loops=3)
--                                 Buckets: 1024  Batches: 1  Memory Usage: 31kB
--                                 Buffers: shared hit=52 read=3
--                                 ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=34) (actual time=0.300..0.570 rows=337.00 loops=3)
--                                       Buffers: shared hit=52 read=3
--                     ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.46 rows=1 width=53) (actual time=0.010..0.010 rows=1.00 loops=1384)
--                           Index Cond: (id = d.competition_id)
--                           Index Searches: 1379
--                           Buffers: shared hit=5033 read=485
-- Planning:
--   Buffers: shared hit=355 read=81 dirtied=1
-- Planning Time: 10.261 ms
-- Execution Time: 606.300 ms

----------------------

CREATE INDEX IF NOT EXISTS new_duel_upcoming_indexes ON
    new_duel(
             duel_date,
         duel_time,
         home_team_id,
        away_team_id,
        sport_category_id,
        location_id,
        competition_id
    );

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM new_upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

-- Gather Merge  (cost=86807.79..87719.49 rows=7828 width=217) (actual time=163.625..169.786 rows=1384.00 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=16707 read=6611
--   ->  Sort  (cost=85807.77..85815.92 rows=3262 width=217) (actual time=122.615..122.641 rows=461.33 loops=3)
-- "        Sort Key: nd.duel_date, nd.duel_time, l.capacity DESC"
--         Sort Method: quicksort  Memory: 85kB
--         Buffers: shared hit=16707 read=6611
--         Worker 0:  Sort Method: quicksort  Memory: 172kB
--         Worker 1:  Sort Method: quicksort  Memory: 170kB
--         ->  Nested Loop Left Join  (cost=1698.30..85617.41 rows=3262 width=217) (actual time=75.930..122.063 rows=461.33 loops=3)
--               Buffers: shared hit=16659 read=6611
--               ->  Hash Join  (cost=1697.88..84093.94 rows=3262 width=168) (actual time=75.477..117.741 rows=461.33 loops=3)
--                     Hash Cond: (nd.sport_category_id = scat.id)
--                     Buffers: shared hit=11629 read=6123
--                     ->  Nested Loop  (cost=1685.30..84072.68 rows=3262 width=142) (actual time=74.535..116.571 rows=461.33 loops=3)
--                           Buffers: shared hit=11579 read=6118
--                           ->  Nested Loop  (cost=1684.88..82505.03 rows=3262 width=101) (actual time=74.489..113.736 rows=461.33 loops=3)
--                                 Buffers: shared hit=6322 read=5839
--                                 ->  Hash Join  (cost=1684.45..80937.38 rows=3262 width=60) (actual time=73.727..110.236 rows=461.33 loops=3)
--                                       Hash Cond: (nd.location_id = l.id)
--                                       Buffers: shared hit=1042 read=5581
--                                       ->  Parallel Append  (cost=134.55..78345.72 rows=269100 width=32) (actual time=72.401..104.062 rows=75460.33 loops=3)
--                                             Buffers: shared hit=2 read=5569
--                                             Subplans Removed: 10
--                                             ->  Parallel Index Only Scan using new_duel_2026_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2026 nd_1  (cost=0.43..37213.93 rows=267239 width=32) (actual time=72.398..99.624 rows=75460.33 loops=3)
--                                                   Index Cond: (duel_date <= (CURRENT_DATE + 7))
--                                                   Filter: ((duel_date > CURRENT_DATE) OR ((duel_date = CURRENT_DATE) AND ((duel_time)::time with time zone > CURRENT_TIME)))
--                                                   Rows Removed by Filter: 184240
--                                                   Heap Fetches: 0
--                                                   Index Searches: 1
--                                                   Buffers: shared hit=2 read=5569
--                                       ->  Hash  (cost=1533.73..1533.73 rows=1294 width=36) (actual time=1.190..1.192 rows=433.00 loops=3)
--                                             Buckets: 2048  Batches: 1  Memory Usage: 49kB
--                                             Buffers: shared hit=1040 read=12
--                                             ->  Nested Loop  (cost=0.42..1533.73 rows=1294 width=36) (actual time=0.520..1.083 rows=433.00 loops=3)
--                                                   Buffers: shared hit=1040 read=12
--                                                   ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.439..0.446 rows=1.00 loops=3)
--                                                         Filter: ((name)::text ~~ '%Macedonia'::text)
--                                                         Rows Removed by Filter: 164
--                                                         Buffers: shared hit=3
--                                                   ->  Index Scan using unique_name_per_country on location l  (cost=0.42..758.87 rows=647 width=32) (actual time=0.075..0.568 rows=433.00 loops=3)
--                                                         Index Cond: (country_id = c.id)
--                                                         Index Searches: 3
--                                                         Buffers: shared hit=1037 read=12
--                                 ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.48 rows=1 width=49) (actual time=0.007..0.007 rows=1.00 loops=1384)
--                                       Index Cond: (id = nd.home_team_id)
--                                       Index Searches: 1384
--                                       Buffers: shared hit=5280 read=258
--                           ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.48 rows=1 width=49) (actual time=0.006..0.006 rows=1.00 loops=1384)
--                                 Index Cond: (id = nd.away_team_id)
--                                 Index Searches: 1384
--                                 Buffers: shared hit=5257 read=279
--                     ->  Hash  (cost=8.37..8.37 rows=337 width=34) (actual time=0.933..0.934 rows=337.00 loops=3)
--                           Buckets: 1024  Batches: 1  Memory Usage: 31kB
--                           Buffers: shared hit=50 read=5
--                           ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=34) (actual time=0.816..0.901 rows=337.00 loops=3)
--                                 Buffers: shared hit=50 read=5
--               ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.47 rows=1 width=53) (actual time=0.009..0.009 rows=1.00 loops=1384)
--                     Index Cond: (id = nd.competition_id)
--                     Index Searches: 1379
--                     Buffers: shared hit=5030 read=488
-- Planning:
--   Buffers: shared hit=1415 read=163
-- Planning Time: 24.252 ms
-- Execution Time: 170.207 ms
-------------------------------------------------------------------------------------------------------------------------------DRUGO VIEW
CREATE OR REPLACE VIEW new_season_standing AS
SELECT
    t.id AS team_id,
    t.name AS team_name,
    c.id AS competition_id,
    c.season_id,
    c.name AS league_name,
    c.start_date,
    c.end_date,
    COUNT(*) AS matches_played,
    SUM(
        CASE
            WHEN (
                t.id = d.home_team_id
                AND d.home_team_score > d.away_team_score
            )
            OR (
                t.id = d.away_team_id
                AND d.away_team_score > d.home_team_score
            )
                THEN sc.points_per_win

            WHEN d.home_team_score = d.away_team_score
                THEN sc.points_per_draw

            ELSE sc.points_per_losing
        END
    ) AS total_points,
    SUM(
        CASE
            WHEN t.id = d.home_team_id
                THEN d.home_team_score
            ELSE d.away_team_score
        END
    ) AS scored,
    SUM(
        CASE
            WHEN t.id = d.home_team_id
                THEN d.away_team_score
            ELSE d.home_team_score
        END
    ) AS scores_conceded
FROM sport_team t
JOIN new_duel d
    ON t.id IN (d.home_team_id, d.away_team_id)
--    AND (
--         d.duel_date < CURRENT_DATE
--         OR (
--             d.duel_date = CURRENT_DATE
--             AND d.duel_time < CURRENT_TIME
--         )
--    )
JOIN competition c
    ON d.competition_id = c.id and d.duel_date>= c.start_date and d.duel_date<=coalesce(c.end_date, CURRENT_DATE)
JOIN sport_category sc
    ON sc.id = d.sport_category_id
WHERE d.home_team_score IS NOT NULL
  AND d.away_team_score IS NOT NULL
GROUP BY
    t.id,
    t.name,
    c.id,
    c.season_id,
    c.name
--     c.start_date,
--     c.end_date
ORDER BY
    total_points DESC,
    (
        SUM(
            CASE
                WHEN t.id = d.home_team_id
                    THEN d.home_team_score
                ELSE d.away_team_score
            END
        )
        -
        SUM(
            CASE
                WHEN t.id = d.home_team_id
                    THEN d.away_team_score
                ELSE d.home_team_score
            END
        )
    )DESC;

DISCARD ALL;

-- bez indeks mora da se dropne ako ne e duel_season_standing_indexes
EXPLAIN (ANALYZE, BUFFERS)
select * from season_standing where season_id = 1;
-- Subquery Scan on season_standing  (cost=275648.37..275649.58 rows=97 width=146) (actual time=1613.591..1620.211 rows=7.00 loops=1)
--   Buffers: shared hit=141 read=156193
--   ->  Sort  (cost=275648.37..275648.61 rows=97 width=154) (actual time=1613.588..1620.203 rows=7.00 loops=1)
-- "        Sort Key: (sum(CASE WHEN (((t.id = d.home_team_id) AND (d.home_team_score > d.away_team_score)) OR ((t.id = d.away_team_id) AND (d.away_team_score > d.home_team_score))) THEN sc.points_per_win WHEN (d.home_team_score = d.away_team_score) THEN sc.points_per_draw ELSE sc.points_per_losing END)) DESC, ((sum(CASE WHEN (t.id = d.home_team_id) THEN d.home_team_score ELSE d.away_team_score END) - sum(CASE WHEN (t.id = d.home_team_id) THEN d.away_team_score ELSE d.home_team_score END))) DESC"
--         Sort Method: quicksort  Memory: 26kB
--         Buffers: shared hit=141 read=156193
--         ->  Finalize GroupAggregate  (cost=275629.64..275645.17 rows=97 width=154) (actual time=1613.539..1620.160 rows=7.00 loops=1)
-- "              Group Key: t.id, c.id"
--               Buffers: shared hit=138 read=156193
--               ->  Gather Merge  (cost=275629.64..275642.52 rows=96 width=146) (actual time=1613.513..1620.126 rows=7.00 loops=1)
--                     Workers Planned: 2
--                     Workers Launched: 2
--                     Buffers: shared hit=138 read=156193
--                     ->  Partial GroupAggregate  (cost=274629.61..274631.41 rows=40 width=146) (actual time=1569.211..1569.223 rows=2.33 loops=3)
-- "                          Group Key: t.id, c.id"
--                           Buffers: shared hit=138 read=156193
--                           ->  Sort  (cost=274629.61..274629.71 rows=40 width=142) (actual time=1569.203..1569.211 rows=8.00 loops=3)
-- "                                Sort Key: t.id, c.id"
--                                 Sort Method: quicksort  Memory: 25kB
--                                 Buffers: shared hit=138 read=156193
--                                 Worker 0:  Sort Method: quicksort  Memory: 28kB
--                                 Worker 1:  Sort Method: quicksort  Memory: 25kB
--                                 ->  Nested Loop  (cost=5048.63..274628.55 rows=40 width=142) (actual time=1067.542..1569.174 rows=8.00 loops=3)
--                                       Buffers: shared hit=124 read=156193
--                                       ->  Nested Loop  (cost=5048.21..274610.51 rows=20 width=93) (actual time=1067.520..1569.112 rows=4.00 loops=3)
--                                             Buffers: shared hit=27 read=156193
--                                             ->  Parallel Hash Join  (cost=5048.06..274607.21 rows=20 width=85) (actual time=1067.492..1569.078 rows=4.00 loops=3)
--                                                   Hash Cond: (d.competition_id = c.id)
--                                                   Buffers: shared hit=2 read=156193
--                                                   ->  Parallel Seq Scan on duel d  (cost=0.00..254821.54 rows=5614241 width=24) (actual time=0.927..1108.938 rows=4483678.33 loops=3)
--                                                         Filter: (now() > start_time)
--                                                         Rows Removed by Filter: 968404
--                                                         Buffers: shared read=152595
--                                                   ->  Parallel Hash  (cost=5048.05..5048.05 rows=1 width=65) (actual time=22.806..22.807 rows=0.33 loops=3)
--                                                         Buckets: 1024  Batches: 1  Memory Usage: 40kB
--                                                         Buffers: shared hit=2 read=3598
--                                                         ->  Parallel Seq Scan on competition c  (cost=0.00..5048.05 rows=1 width=65) (actual time=0.678..22.267 rows=0.33 loops=3)
--                                                               Filter: (season_id = 1)
--                                                               Rows Removed by Filter: 92675
--                                                               Buffers: shared hit=2 read=3598
--                                             ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..0.17 rows=1 width=16) (actual time=0.006..0.006 rows=1.00 loops=12)
--                                                   Index Cond: (id = d.sport_category_id)
--                                                   Index Searches: 12
--                                                   Buffers: shared hit=25
--                                       ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..0.88 rows=2 width=49) (actual time=0.009..0.014 rows=2.00 loops=12)
-- "                                            Index Cond: (id = ANY (ARRAY[d.home_team_id, d.away_team_id]))"
--                                             Index Searches: 24
--                                             Buffers: shared hit=97
-- Planning:
--   Buffers: shared hit=404 read=16
-- Planning Time: 14.896 ms
-- Execution Time: 1620.826 ms


DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
select * from new_season_standing where season_id = 1;
-- Subquery Scan on new_season_standing  (cost=81171.20..81171.33 rows=10 width=146) (actual time=660.298..660.595 rows=7.00 loops=1)
--   Buffers: shared hit=3743 read=22806
--   ->  Sort  (cost=81171.20..81171.23 rows=10 width=154) (actual time=660.296..660.589 rows=7.00 loops=1)
-- "        Sort Key: (sum(CASE WHEN (((t.id = d.home_team_id) AND (d.home_team_score > d.away_team_score)) OR ((t.id = d.away_team_id) AND (d.away_team_score > d.home_team_score))) THEN sc.points_per_win WHEN (d.home_team_score = d.away_team_score) THEN sc.points_per_draw ELSE sc.points_per_losing END)) DESC, ((sum(CASE WHEN (t.id = d.home_team_id) THEN d.home_team_score ELSE d.away_team_score END) - sum(CASE WHEN (t.id = d.home_team_id) THEN d.away_team_score ELSE d.home_team_score END))) DESC"
--         Sort Method: quicksort  Memory: 26kB
--         Buffers: shared hit=3743 read=22806
--         ->  GroupAggregate  (cost=81170.56..81171.04 rows=10 width=154) (actual time=660.221..660.534 rows=7.00 loops=1)
-- "              Group Key: t.id, c.id"
--               Buffers: shared hit=3740 read=22806
--               ->  Sort  (cost=81170.56..81170.59 rows=10 width=142) (actual time=660.195..660.489 rows=24.00 loops=1)
-- "                    Sort Key: t.id, c.id"
--                     Sort Method: quicksort  Memory: 28kB
--                     Buffers: shared hit=3740 read=22806
--                     ->  Gather  (cost=1000.99..81170.40 rows=10 width=142) (actual time=4.351..660.386 rows=24.00 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           Buffers: shared hit=3737 read=22806
--                           ->  Nested Loop  (cost=0.98..80169.40 rows=4 width=142) (actual time=12.574..231.146 rows=8.00 loops=3)
--                                 Buffers: shared hit=3737 read=22806
--                                 ->  Nested Loop  (cost=0.56..80167.59 rows=2 width=93) (actual time=12.554..230.971 rows=4.00 loops=3)
--                                       Buffers: shared hit=3641 read=22806
--                                       ->  Nested Loop  (cost=0.41..80167.26 rows=2 width=85) (actual time=12.545..230.881 rows=4.00 loops=3)
--                                             Buffers: shared hit=3617 read=22806
--                                             ->  Parallel Seq Scan on competition c  (cost=0.00..5048.05 rows=1 width=65) (actual time=11.741..11.753 rows=0.33 loops=3)
--                                                   Filter: (season_id = 1)
--                                                   Rows Removed by Filter: 92675
--                                                   Buffers: shared hit=3600
--                                             ->  Append  (cost=0.41..75118.78 rows=43 width=28) (actual time=2.401..657.337 rows=12.00 loops=1)
--                                                   Buffers: shared hit=17 read=22806
--                                                   ->  Index Scan using new_duel_2021_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2021 d_1  (cost=0.41..143.97 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2022_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2022 d_2  (cost=0.43..14765.87 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2023_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2023 d_3  (cost=0.43..14766.70 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2024_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2024 d_4  (cost=0.43..14766.90 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2025_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2025 d_5  (cost=0.43..14767.12 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2026_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2026 d_6  (cost=0.43..14771.37 rows=1 width=28) (actual time=2.383..652.500 rows=12.00 loops=1)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Rows Removed by Filter: 30
--                                                         Index Searches: 1
--                                                         Buffers: shared hit=17 read=22636
--                                                   ->  Index Scan using new_duel_2027_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2027 d_7  (cost=0.42..263.15 rows=1 width=28) (actual time=4.783..4.783 rows=0.00 loops=1)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 1
--                                                         Buffers: shared read=170
--                                                   ->  Index Scan using new_duel_2028_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2028 d_8  (cost=0.42..252.90 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2029_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2029 d_9  (cost=0.42..253.01 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2030_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2030 d_10  (cost=0.42..252.61 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2031_duel_date_duel_time_home_team_id_away_team_id_idx on new_duel_2031 d_11  (cost=0.29..114.95 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                       ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..0.17 rows=1 width=16) (actual time=0.012..0.012 rows=1.00 loops=12)
--                                             Index Cond: (id = d.sport_category_id)
--                                             Index Searches: 12
--                                             Buffers: shared hit=24
--                                 ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..0.88 rows=2 width=49) (actual time=0.023..0.034 rows=2.00 loops=12)
-- "                                      Index Cond: (id = ANY (ARRAY[d.home_team_id, d.away_team_id]))"
--                                       Index Searches: 24
--                                       Buffers: shared hit=96
-- Planning:
--   Buffers: shared hit=1459 read=24 dirtied=2
-- Planning Time: 36.547 ms
-- Execution Time: 661.360 ms

--------DODAVANJE IDEKSI

DISCARD ALL;

CREATE INDEX IF NOT EXISTS duel_season_standing_indexes ON
    duel(competition_id, start_time, home_team_id, away_team_id, sport_category_id);

EXPLAIN (ANALYZE, BUFFERS)
select * from season_standing where season_id = 1;
-- Subquery Scan on season_standing  (cost=6531.91..6533.12 rows=97 width=146) (actual time=111.417..119.755 rows=7.00 loops=1)
--   Buffers: shared hit=123 read=3619
--   ->  Sort  (cost=6531.91..6532.15 rows=97 width=154) (actual time=111.414..119.749 rows=7.00 loops=1)
-- "        Sort Key: (sum(CASE WHEN (((t.id = d.home_team_id) AND (d.home_team_score > d.away_team_score)) OR ((t.id = d.away_team_id) AND (d.away_team_score > d.home_team_score))) THEN sc.points_per_win WHEN (d.home_team_score = d.away_team_score) THEN sc.points_per_draw ELSE sc.points_per_losing END)) DESC, ((sum(CASE WHEN (t.id = d.home_team_id) THEN d.home_team_score ELSE d.away_team_score END) - sum(CASE WHEN (t.id = d.home_team_id) THEN d.away_team_score ELSE d.home_team_score END))) DESC"
--         Sort Method: quicksort  Memory: 26kB
--         Buffers: shared hit=123 read=3619
--         ->  Finalize GroupAggregate  (cost=6513.17..6528.70 rows=97 width=154) (actual time=111.352..119.617 rows=7.00 loops=1)
-- "              Group Key: t.id, c.id"
--               Buffers: shared hit=120 read=3619
--               ->  Gather Merge  (cost=6513.17..6526.05 rows=96 width=146) (actual time=111.319..119.585 rows=7.00 loops=1)
--                     Workers Planned: 2
--                     Workers Launched: 2
--                     Buffers: shared hit=120 read=3619
--                     ->  Partial GroupAggregate  (cost=5513.15..5514.95 rows=40 width=146) (actual time=28.621..28.635 rows=2.33 loops=3)
-- "                          Group Key: t.id, c.id"
--                           Buffers: shared hit=120 read=3619
--                           ->  Sort  (cost=5513.15..5513.25 rows=40 width=142) (actual time=28.608..28.612 rows=8.00 loops=3)
-- "                                Sort Key: t.id, c.id"
--                                 Sort Method: quicksort  Memory: 28kB
--                                 Buffers: shared hit=120 read=3619
--                                 Worker 0:  Sort Method: quicksort  Memory: 25kB
--                                 Worker 1:  Sort Method: quicksort  Memory: 25kB
--                                 ->  Nested Loop  (cost=1.13..5512.08 rows=40 width=142) (actual time=0.946..28.556 rows=8.00 loops=3)
--                                       Buffers: shared hit=106 read=3619
--                                       ->  Nested Loop  (cost=0.71..5494.04 rows=20 width=93) (actual time=0.464..26.445 rows=4.00 loops=3)
--                                             Buffers: shared hit=28 read=3601
--                                             ->  Nested Loop  (cost=0.56..5490.74 rows=20 width=85) (actual time=0.449..26.412 rows=4.00 loops=3)
--                                                   Buffers: shared hit=4 read=3601
--                                                   ->  Parallel Seq Scan on competition c  (cost=0.00..5048.05 rows=1 width=65) (actual time=0.412..26.370 rows=0.33 loops=3)
--                                                         Filter: (season_id = 1)
--                                                         Rows Removed by Filter: 92675
--                                                         Buffers: shared read=3600
--                                                   ->  Index Scan using duel_season_standing_indexes on duel d  (cost=0.56..440.28 rows=242 width=24) (actual time=0.095..0.102 rows=12.00 loops=1)
--                                                         Index Cond: ((competition_id = c.id) AND (start_time < now()))
--                                                         Index Searches: 1
--                                                         Buffers: shared hit=4 read=1
--                                             ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..0.17 rows=1 width=16) (actual time=0.006..0.006 rows=1.00 loops=12)
--                                                   Index Cond: (id = d.sport_category_id)
--                                                   Index Searches: 12
--                                                   Buffers: shared hit=24
--                                       ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..0.88 rows=2 width=49) (actual time=0.328..0.524 rows=2.00 loops=12)
-- "                                            Index Cond: (id = ANY (ARRAY[d.home_team_id, d.away_team_id]))"
--                                             Index Searches: 24
--                                             Buffers: shared hit=78 read=18
-- Planning:
--   Buffers: shared hit=367 read=88 dirtied=2
-- Planning Time: 60.367 ms
-- Execution Time: 120.070 ms

DISCARD ALL;

CREATE INDEX IF NOT EXISTS new_duel_season_standing_indexes ON
    new_duel(duel_date, competition_id, duel_time, home_team_id, away_team_id, sport_category_id);

EXPLAIN (ANALYZE, BUFFERS)
select * from new_season_standing where season_id = 1;
-- Subquery Scan on new_season_standing  (cost=7855.52..7855.65 rows=10 width=146) (actual time=64.969..71.381 rows=7.00 loops=1)
--   Buffers: shared hit=4399 read=488
--   ->  Sort  (cost=7855.52..7855.55 rows=10 width=154) (actual time=64.966..71.374 rows=7.00 loops=1)
-- "        Sort Key: (sum(CASE WHEN (((t.id = d.home_team_id) AND (d.home_team_score > d.away_team_score)) OR ((t.id = d.away_team_id) AND (d.away_team_score > d.home_team_score))) THEN sc.points_per_win WHEN (d.home_team_score = d.away_team_score) THEN sc.points_per_draw ELSE sc.points_per_losing END)) DESC, ((sum(CASE WHEN (t.id = d.home_team_id) THEN d.home_team_score ELSE d.away_team_score END) - sum(CASE WHEN (t.id = d.home_team_id) THEN d.away_team_score ELSE d.home_team_score END))) DESC"
--         Sort Method: quicksort  Memory: 26kB
--         Buffers: shared hit=4399 read=488
--         ->  GroupAggregate  (cost=7854.88..7855.35 rows=10 width=154) (actual time=64.919..71.354 rows=7.00 loops=1)
-- "              Group Key: t.id, c.id"
--               Buffers: shared hit=4399 read=488
--               ->  Sort  (cost=7854.88..7854.90 rows=10 width=142) (actual time=64.900..71.309 rows=24.00 loops=1)
-- "                    Sort Key: t.id, c.id"
--                     Sort Method: quicksort  Memory: 28kB
--                     Buffers: shared hit=4399 read=488
--                     ->  Gather  (cost=1000.99..7854.71 rows=10 width=142) (actual time=1.996..71.279 rows=24.00 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           Buffers: shared hit=4399 read=488
--                           ->  Nested Loop  (cost=0.98..6853.71 rows=4 width=142) (actual time=0.134..19.039 rows=8.00 loops=3)
--                                 Buffers: shared hit=4399 read=488
--                                 ->  Nested Loop  (cost=0.56..6851.91 rows=2 width=93) (actual time=0.110..18.965 rows=4.00 loops=3)
--                                       Buffers: shared hit=4303 read=488
--                                       ->  Nested Loop  (cost=0.41..6851.58 rows=2 width=85) (actual time=0.106..18.953 rows=4.00 loops=3)
--                                             Buffers: shared hit=4279 read=488
--                                             ->  Parallel Seq Scan on competition c  (cost=0.00..5048.05 rows=1 width=65) (actual time=0.005..14.495 rows=0.33 loops=3)
--                                                   Filter: (season_id = 1)
--                                                   Rows Removed by Filter: 92675
--                                                   Buffers: shared hit=3600
--                                             ->  Append  (cost=0.41..1803.10 rows=43 width=28) (actual time=0.292..13.353 rows=12.00 loops=1)
--                                                   Buffers: shared hit=679 read=488
--                                                   ->  Index Scan using new_duel_2021_duel_date_competition_id_duel_time_home_team__idx on new_duel_2021 d_1  (cost=0.41..99.54 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2022_duel_date_competition_id_duel_time_home_team__idx on new_duel_2022 d_2  (cost=0.43..182.47 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2023_duel_date_competition_id_duel_time_home_team__idx on new_duel_2023 d_3  (cost=0.43..186.91 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2024_duel_date_competition_id_duel_time_home_team__idx on new_duel_2024 d_4  (cost=0.43..182.47 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2025_duel_date_competition_id_duel_time_home_team__idx on new_duel_2025 d_5  (cost=0.43..178.02 rows=9 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2026_duel_date_competition_id_duel_time_home_team__idx on new_duel_2026 d_6  (cost=0.43..186.91 rows=1 width=28) (actual time=0.278..9.590 rows=12.00 loops=1)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Rows Removed by Filter: 30
--                                                         Index Searches: 229
--                                                         Buffers: shared hit=394 read=341
--                                                   ->  Index Scan using new_duel_2027_duel_date_competition_id_duel_time_home_team__idx on new_duel_2027 d_7  (cost=0.42..179.30 rows=1 width=28) (actual time=3.719..3.719 rows=0.00 loops=1)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 144
--                                                         Buffers: shared hit=285 read=147
--                                                   ->  Index Scan using new_duel_2028_duel_date_competition_id_duel_time_home_team__idx on new_duel_2028 d_8  (cost=0.42..175.29 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2029_duel_date_competition_id_duel_time_home_team__idx on new_duel_2029 d_9  (cost=0.42..175.29 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2030_duel_date_competition_id_duel_time_home_team__idx on new_duel_2030 d_10  (cost=0.42..175.29 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                                   ->  Index Scan using new_duel_2031_duel_date_competition_id_duel_time_home_team__idx on new_duel_2031 d_11  (cost=0.41..81.41 rows=1 width=28) (never executed)
-- "                                                        Index Cond: ((duel_date >= c.start_date) AND (duel_date <= COALESCE(c.end_date, CURRENT_DATE)) AND (competition_id = c.id))"
--                                                         Filter: ((home_team_score IS NOT NULL) AND (away_team_score IS NOT NULL))
--                                                         Index Searches: 0
--                                       ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..0.17 rows=1 width=16) (actual time=0.002..0.002 rows=1.00 loops=12)
--                                             Index Cond: (id = d.sport_category_id)
--                                             Index Searches: 12
--                                             Buffers: shared hit=24
--                                 ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..0.88 rows=2 width=49) (actual time=0.009..0.017 rows=2.00 loops=12)
-- "                                      Index Cond: (id = ANY (ARRAY[d.home_team_id, d.away_team_id]))"
--                                       Index Searches: 24
--                                       Buffers: shared hit=96
-- Planning:
--   Buffers: shared hit=1528 read=43
-- Planning Time: 45.284 ms
-- Execution Time: 71.954 ms

---------------------------------------------------

-- NOTE: Ne se menja pogledot free_locations, samo kako go koristime

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
from free_locations
WHERE
    capacity >= 10000
    and country LIKE '%Macedonia'
    and not exists(
        select 1
        from duel d
        join sport_category cat
            on cat.id = d.sport_category_id
        WHERE d.location_id = venue_id
          AND d.start_time < '2026-05-10 21:00:00'::timestamp -- end od range
          AND d.start_time +
              (interval '1 minute' * cat.duration_minutes) >
              '2026-05-10 16:00:00'::timestamp -- start of range
    );
-- Gather  (cost=3002.36..262177.68 rows=710 width=57) (actual time=6422.877..6427.984 rows=589 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=1435 read=152344
--   ->  Parallel Hash Right Anti Join  (cost=2002.36..261106.68 rows=296 width=57) (actual time=6405.440..6405.595 rows=196 loops=3)
--         Hash Cond: (d.location_id = l.id)
--         Buffers: shared hit=1435 read=152344
--         ->  Hash Join  (cost=12.58..252192.62 rows=1818758 width=4) (actual time=166.016..6343.669 rows=10 loops=3)
--               Hash Cond: (d.sport_category_id = cat.id)
--               Join Filter: ((d.start_time + ('00:01:00'::interval * (cat.duration_minutes)::double precision)) > '2026-05-10 16:00:00'::timestamp without time zone)
--               Rows Removed by Join Filter: 4305445
--               Buffers: shared hit=240 read=152344
--               ->  Parallel Seq Scan on duel d  (cost=0.00..237743.31 rows=5456272 width=16) (actual time=0.069..3055.039 rows=4305454 loops=3)
--                     Filter: (start_time < '2026-05-10 21:00:00'::timestamp without time zone)
--                     Rows Removed by Filter: 1145701
--                     Buffers: shared hit=225 read=152344
--               ->  Hash  (cost=8.37..8.37 rows=337 width=8) (actual time=0.516..0.518 rows=337 loops=3)
--                     Buckets: 1024  Batches: 1  Memory Usage: 22kB
--                     Buffers: shared hit=15
--                     ->  Seq Scan on sport_category cat  (cost=0.00..8.37 rows=337 width=8) (actual time=0.026..0.251 rows=337 loops=3)
--                           Buffers: shared hit=15
--         ->  Parallel Hash  (cost=1982.28..1982.28 rows=600 width=57) (actual time=61.123..61.130 rows=196 loops=3)
--               Buckets: 1024  Batches: 1  Memory Usage: 104kB
--               Buffers: shared hit=1077
--               ->  Hash Join  (cost=3.09..1982.28 rows=600 width=57) (actual time=47.384..60.862 rows=196 loops=3)
--                     Hash Cond: (l.country_id = c.id)
--                     Buffers: shared hit=1077
--                     ->  Parallel Seq Scan on location l  (cost=0.00..1845.94 rows=49490 width=49) (actual time=19.258..41.114 rows=28097 loops=3)
--                           Filter: (capacity >= 10000)
--                           Rows Removed by Filter: 6898
--                           Buffers: shared hit=1074
--                     ->  Hash  (cost=3.06..3.06 rows=2 width=12) (actual time=0.077..0.079 rows=1 loops=3)
--                           Buckets: 1024  Batches: 1  Memory Usage: 9kB
--                           Buffers: shared hit=3
--                           ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.055..0.060 rows=1 loops=3)
--                                 Filter: ((name)::text ~~ '%Macedonia'::text)
--                                 Rows Removed by Filter: 164
--                                 Buffers: shared hit=3
-- Planning:
--   Buffers: shared hit=22
-- Planning Time: 0.692 ms
-- JIT:
--   Functions: 108
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 6.570 ms (Deform 3.600 ms), Inlining 0.000 ms, Optimization 2.885 ms, Emission 55.208 ms, Total 64.663 ms"
-- Execution Time: 6430.245 ms


DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT *
from free_locations
WHERE
    capacity >= 10000
    and country LIKE '%Macedonia'
    and not exists(
        select 1
        from new_duel d
        join sport_category cat
            on cat.id = d.sport_category_id
        WHERE d.location_id = venue_id
          AND d.duel_date = '2026-05-10'::date
          AND d.duel_time < '21:00:00'::time -- end od range
          AND d.duel_time +
              (interval '1 minute' * cat.duration_minutes) >
              '16:00:00'::time -- start of range
    );
-- Hash Right Anti Join  (cost=2534.62..52852.94 rows=1010 width=57) (actual time=84.665..90.328 rows=589 loops=1)
--   Hash Cond: (d.location_id = l.id)
--   Buffers: shared hit=1458 read=29295
--   ->  Gather  (cost=1012.58..51326.83 rows=1060 width=4) (actual time=2.346..87.957 rows=29 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         Buffers: shared hit=805 read=29295
--         ->  Hash Join  (cost=12.58..50220.83 rows=442 width=4) (actual time=40.935..67.667 rows=10 loops=3)
--               Hash Cond: (d.sport_category_id = cat.id)
--               Join Filter: ((d.duel_time + ('00:01:00'::interval * (cat.duration_minutes)::double precision)) > '16:00:00'::time without time zone)
--               Rows Removed by Join Filter: 34
--               Buffers: shared hit=805 read=29295
--               ->  Parallel Seq Scan on new_duel_2026 d  (cost=0.00..50204.75 rows=1325 width=16) (actual time=40.703..67.440 rows=44 loops=3)
--                     Filter: ((duel_time < '21:00:00'::time without time zone) AND (duel_date = '2026-05-10'::date))
--                     Rows Removed by Filter: 1072472
--                     Buffers: shared hit=800 read=29295
--               ->  Hash  (cost=8.37..8.37 rows=337 width=8) (actual time=0.507..0.510 rows=337 loops=1)
--                     Buckets: 1024  Batches: 1  Memory Usage: 22kB
--                     Buffers: shared hit=5
--                     ->  Seq Scan on sport_category cat  (cost=0.00..8.37 rows=337 width=8) (actual time=0.008..0.255 rows=337 loops=1)
--                           Buffers: shared hit=5
--   ->  Hash  (cost=1509.29..1509.29 rows=1020 width=57) (actual time=1.886..1.893 rows=589 loops=1)
--         Buckets: 1024  Batches: 1  Memory Usage: 67kB
--         Buffers: shared hit=653
--         ->  Nested Loop  (cost=0.42..1509.29 rows=1020 width=57) (actual time=0.038..1.364 rows=589 loops=1)
--               Buffers: shared hit=653
--               ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.017..0.022 rows=1 loops=1)
--                     Filter: ((name)::text ~~ '%Macedonia'::text)
--                     Rows Removed by Filter: 164
--                     Buffers: shared hit=1
--               ->  Index Scan using unique_name_per_country on location l  (cost=0.42..748.01 rows=510 width=49) (actual time=0.018..0.575 rows=589 loops=1)
--                     Index Cond: (country_id = c.id)
--                     Filter: (capacity >= 10000)
--                     Rows Removed by Filter: 140
--                     Buffers: shared hit=652
-- Planning:
--   Buffers: shared hit=12
-- Planning Time: 0.473 ms
-- Execution Time: 90.889 ms

CREATE OR REPLACE VIEW new_top_scorers_on_competition AS
SELECT
    comp.id AS competition_id,
    comp.name AS competition_name,
    p.first_name || ' ' || p.last_name AS player_name,
    t.name AS team_name,
    COUNT(*) AS scores
FROM NEW_SCORE s
JOIN NEW_DUEL d ON d.id = s.duel_id
JOIN COMPETITION comp ON comp.id = d.competition_id and comp.start_date >= d.duel_date and comp.end_date <= d.duel_date
JOIN SPORTSPERSON sp ON sp.ssn = s.player_ssn
JOIN PERSON p ON p.ssn = sp.ssn
JOIN NEW_TEAM_ROSTER tr ON tr.duel_id = s.duel_id AND tr.player_ssn = s.player_ssn
JOIN SPORT_TEAM t ON t.id = tr.team_id
WHERE d.competition_id IS NOT NULL
GROUP BY comp.id, comp.name, s.player_ssn, p.first_name, p.last_name, t.name
ORDER BY scores DESC;

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
select * from top_scorers_on_competition WHERE competition_id = 70767;
-- Subquery Scan on top_scorers_on_competition  (cost=618400.78..618400.80 rows=1 width=139) (actual time=14941.204..14941.688 rows=93 loops=1)
-- "  Buffers: shared hit=1007729 read=371521, temp read=856 written=858"
--   ->  Sort  (cost=618400.78..618400.79 rows=1 width=168) (actual time=14941.163..14941.533 rows=93 loops=1)
--         Sort Key: (count(*)) DESC
--         Sort Method: quicksort  Memory: 41kB
-- "        Buffers: shared hit=1007729 read=371521, temp read=856 written=858"
--         ->  GroupAggregate  (cost=618400.74..618400.77 rows=1 width=168) (actual time=14864.433..14941.328 rows=93 loops=1)
-- "              Group Key: s.player_ssn, p.first_name, p.last_name, t.name"
-- "              Buffers: shared hit=1007729 read=371521, temp read=856 written=858"
--               ->  Sort  (cost=618400.74..618400.74 rows=1 width=128) (actual time=14863.709..14903.596 rows=49546 loops=1)
-- "                    Sort Key: s.player_ssn, p.first_name, p.last_name, t.name"
--                     Sort Method: external merge  Disk: 6848kB
-- "                    Buffers: shared hit=1007729 read=371521, temp read=856 written=858"
--                     ->  Nested Loop  (cost=238747.18..618400.73 rows=1 width=128) (actual time=13038.903..14795.899 rows=49546 loops=1)
--                           Buffers: shared hit=1007729 read=371521
--                           ->  Nested Loop  (cost=238746.76..618397.32 rows=1 width=86) (actual time=13038.876..14621.738 rows=49546 loops=1)
--                                 Buffers: shared hit=809545 read=371521
--                                 ->  Nested Loop  (cost=238746.33..618395.36 rows=1 width=114) (actual time=13038.834..14406.866 rows=49546 loops=1)
--                                       Buffers: shared hit=660906 read=371521
--                                       ->  Nested Loop  (cost=238745.77..618391.44 rows=1 width=85) (actual time=13038.787..14170.458 rows=49546 loops=1)
--                                             Buffers: shared hit=413176 read=371521
--                                             ->  Gather  (cost=238745.34..618382.99 rows=1 width=36) (actual time=13038.751..13933.609 rows=49546 loops=1)
--                                                   Workers Planned: 2
--                                                   Workers Launched: 2
--                                                   Buffers: shared hit=214992 read=371521
--                                                   ->  Nested Loop  (cost=237745.34..617382.89 rows=1 width=36) (actual time=13025.955..14343.837 rows=16515 loops=3)
--                                                         Join Filter: (d.id = tr.duel_id)
--                                                         Buffers: shared hit=214992 read=371521
--                                                         ->  Parallel Hash Join  (cost=237744.78..616146.29 rows=217 width=26) (actual time=13025.869..14205.721 rows=16515 loops=3)
--                                                               Hash Cond: (s.duel_id = d.id)
--                                                               Buffers: shared hit=1697 read=371521
--                                                               ->  Parallel Seq Scan on score s  (cost=0.00..345589.00 rows=12500000 width=18) (actual time=0.539..6748.147 rows=10000000 loops=3)
--                                                                     Buffers: shared hit=256 read=220333
--                                                               ->  Parallel Hash  (cost=237743.31..237743.31 rows=118 width=8) (actual time=888.360..888.363 rows=52 loops=3)
--                                                                     Buckets: 1024  Batches: 1  Memory Usage: 40kB
--                                                                     Buffers: shared hit=1381 read=151188
--                                                                     ->  Parallel Seq Scan on duel d  (cost=0.00..237743.31 rows=118 width=8) (actual time=725.884..888.266 rows=52 loops=3)
--                                                                           Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                           Rows Removed by Filter: 5451104
--                                                                           Buffers: shared hit=1381 read=151188
--                                                         ->  Index Only Scan using team_roster_pkey on team_roster tr  (cost=0.56..5.69 rows=1 width=22) (actual time=0.005..0.006 rows=1 loops=49546)
--                                                               Index Cond: ((player_ssn = s.player_ssn) AND (duel_id = s.duel_id))
--                                                               Heap Fetches: 0
--                                                               Buffers: shared hit=213295
--                                             ->  Index Scan using competition_pkey on competition comp  (cost=0.42..8.44 rows=1 width=53) (actual time=0.001..0.002 rows=1 loops=49546)
--                                                   Index Cond: (id = 70767)
--                                                   Buffers: shared hit=198184
--                                       ->  Index Scan using person_pkey on person p  (cost=0.56..3.92 rows=1 width=29) (actual time=0.003..0.003 rows=1 loops=49546)
--                                             Index Cond: (ssn = s.player_ssn)
--                                             Buffers: shared hit=247730
--                                 ->  Index Only Scan using sportsperson_pkey on sportsperson sp  (cost=0.43..1.96 rows=1 width=14) (actual time=0.002..0.002 rows=1 loops=49546)
--                                       Index Cond: (ssn = s.player_ssn)
--                                       Heap Fetches: 0
--                                       Buffers: shared hit=148639
--                           ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..3.41 rows=1 width=50) (actual time=0.001..0.001 rows=1 loops=49546)
--                                 Index Cond: (id = tr.team_id)
--                                 Buffers: shared hit=198184
-- Planning:
--   Buffers: shared hit=98
-- Planning Time: 4.977 ms
-- JIT:
--   Functions: 77
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 4.349 ms (Deform 1.605 ms), Inlining 119.671 ms, Optimization 252.973 ms, Emission 208.689 ms, Total 585.682 ms"
-- Execution Time: 14945.273 ms

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
select * from new_top_scorers_on_competition WHERE competition_id = 70767;
-- Subquery Scan on new_top_scorers_on_competition  (cost=703271.24..703271.25 rows=1 width=139) (actual time=606.865..613.904 rows=0 loops=1)
--   Buffers: shared hit=3754 read=150036
--   ->  Sort  (cost=703271.24..703271.24 rows=1 width=168) (actual time=606.863..613.900 rows=0 loops=1)
--         Sort Key: (count(*)) DESC
--         Sort Method: quicksort  Memory: 25kB
--         Buffers: shared hit=3754 read=150036
--         ->  GroupAggregate  (cost=703271.19..703271.23 rows=1 width=168) (actual time=606.844..613.880 rows=0 loops=1)
-- "              Group Key: s.player_ssn, p.first_name, p.last_name, t.name"
--               Buffers: shared hit=3754 read=150036
--               ->  Sort  (cost=703271.19..703271.20 rows=1 width=128) (actual time=606.841..613.875 rows=0 loops=1)
-- "                    Sort Key: s.player_ssn, p.first_name, p.last_name, t.name"
--                     Sort Method: quicksort  Memory: 25kB
--                     Buffers: shared hit=3754 read=150036
--                     ->  Nested Loop  (cost=241308.07..703271.18 rows=1 width=128) (actual time=606.818..613.851 rows=0 loops=1)
--                           Buffers: shared hit=3754 read=150036
--                           ->  Gather  (cost=241307.65..703268.46 rows=1 width=86) (actual time=606.816..613.846 rows=0 loops=1)
--                                 Workers Planned: 2
--                                 Workers Launched: 2
--                                 Buffers: shared hit=3754 read=150036
--                                 ->  Nested Loop  (cost=240307.65..702268.36 rows=1 width=86) (actual time=585.713..585.736 rows=0 loops=3)
--                                       Buffers: shared hit=3754 read=150036
--                                       ->  Nested Loop  (cost=240307.22..702266.74 rows=1 width=114) (actual time=585.711..585.732 rows=0 loops=3)
--                                             Buffers: shared hit=3754 read=150036
--                                             ->  Nested Loop  (cost=240306.66..702263.40 rows=1 width=85) (actual time=585.709..585.729 rows=0 loops=3)
--                                                   Join Filter: (d.id = tr.duel_id)
--                                                   Buffers: shared hit=3754 read=150036
--                                                   ->  Parallel Hash Join  (cost=240306.10..677848.81 rows=10334 width=75) (actual time=585.707..585.726 rows=0 loops=3)
--                                                         Hash Cond: (s.duel_id = d.id)
--                                                         Buffers: shared hit=3754 read=150036
--                                                         ->  Parallel Seq Scan on new_score s  (cost=0.00..375000.00 rows=12500000 width=18) (never executed)
--                                                         ->  Parallel Hash  (cost=240305.87..240305.87 rows=18 width=57) (actual time=585.460..585.475 rows=0 loops=3)
--                                                               Buckets: 1024  Batches: 1  Memory Usage: 0kB
--                                                               Buffers: shared hit=3694 read=150036
--                                                               ->  Nested Loop  (cost=0.42..240305.87 rows=18 width=57) (actual time=585.414..585.426 rows=0 loops=3)
--                                                                     Join Filter: ((comp.start_date >= d.duel_date) AND (comp.end_date <= d.duel_date))
--                                                                     Rows Removed by Join Filter: 52
--                                                                     Buffers: shared hit=3694 read=150036
--                                                                     ->  Parallel Append  (cost=0.00..238876.98 rows=169 width=12) (actual time=516.681..585.089 rows=52 loops=3)
--                                                                           Buffers: shared hit=3069 read=150036
--                                                                           ->  Parallel Seq Scan on new_duel_2025 d_5  (cost=0.00..46883.90 rows=32 width=12) (actual time=369.441..482.864 rows=156 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 3217533
--                                                                                 Buffers: shared hit=64 read=30061
--                                                                           ->  Parallel Seq Scan on new_duel_2024 d_4  (cost=0.00..46874.22 rows=32 width=12) (actual time=482.327..482.328 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 3216993
--                                                                                 Buffers: shared hit=64 read=30055
--                                                                           ->  Parallel Seq Scan on new_duel_2023 d_3  (cost=0.00..46858.83 rows=32 width=12) (actual time=37.525..37.525 rows=0 loops=3)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 1071992
--                                                                                 Buffers: shared hit=192 read=29917
--                                                                           ->  Parallel Seq Scan on new_duel_2026 d_6  (cost=0.00..46853.12 rows=32 width=12) (actual time=57.414..57.415 rows=0 loops=2)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 1608774
--                                                                                 Buffers: shared hit=128 read=29967
--                                                                           ->  Parallel Seq Scan on new_duel_2022 d_2  (cost=0.00..46845.11 rows=32 width=12) (actual time=104.351..104.352 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 3215058
--                                                                                 Buffers: shared hit=64 read=30036
--                                                                           ->  Parallel Seq Scan on new_duel_2027 d_7  (cost=0.00..926.78 rows=1 width=12) (actual time=1.608..1.609 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 55458
--                                                                                 Buffers: shared hit=519
--                                                                           ->  Parallel Seq Scan on new_duel_2028 d_8  (cost=0.00..900.35 rows=1 width=12) (actual time=1.606..1.607 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 53904
--                                                                                 Buffers: shared hit=504
--                                                                           ->  Parallel Seq Scan on new_duel_2030 d_10  (cost=0.00..895.14 rows=1 width=12) (actual time=1.510..1.511 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 53603
--                                                                                 Buffers: shared hit=501
--                                                                           ->  Parallel Seq Scan on new_duel_2029 d_9  (cost=0.00..894.71 rows=1 width=12) (actual time=2.319..2.319 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 53544
--                                                                                 Buffers: shared hit=501
--                                                                           ->  Parallel Seq Scan on new_duel_2021 d_1  (cost=0.00..522.37 rows=1 width=12) (actual time=0.926..0.926 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 29562
--                                                                                 Buffers: shared hit=305
--                                                                           ->  Parallel Seq Scan on new_duel_2031 d_11  (cost=0.00..403.29 rows=1 width=12) (actual time=0.717..0.718 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 24111
--                                                                                 Buffers: shared hit=226
--                                                                           ->  Parallel Seq Scan on new_duel_2041 d_12  (cost=0.00..18.31 rows=4 width=12) (actual time=449.350..449.351 rows=0 loops=1)
--                                                                                 Filter: ((competition_id IS NOT NULL) AND (competition_id = 70767))
--                                                                                 Rows Removed by Filter: 20
--                                                                                 Buffers: shared hit=1
--                                                                     ->  Index Scan using competition_pkey on competition comp  (cost=0.42..8.44 rows=1 width=61) (actual time=0.003..0.004 rows=1 loops=156)
--                                                                           Index Cond: (id = 70767)
--                                                                           Buffers: shared hit=625
--                                                   ->  Index Only Scan using new_team_roster_pkey on new_team_roster tr  (cost=0.56..2.35 rows=1 width=22) (never executed)
--                                                         Index Cond: ((player_ssn = s.player_ssn) AND (duel_id = s.duel_id))
--                                                         Heap Fetches: 0
--                                             ->  Index Scan using person_pkey on person p  (cost=0.56..3.34 rows=1 width=29) (never executed)
--                                                   Index Cond: (ssn = s.player_ssn)
--                                       ->  Index Only Scan using sportsperson_pkey on sportsperson sp  (cost=0.43..1.62 rows=1 width=14) (never executed)
--                                             Index Cond: (ssn = s.player_ssn)
--                                             Heap Fetches: 0
--                           ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..2.72 rows=1 width=50) (never executed)
--                                 Index Cond: (id = tr.team_id)
-- Planning:
--   Buffers: shared hit=80
-- Planning Time: 5.665 ms
-- JIT:
--   Functions: 239
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 13.890 ms (Deform 6.966 ms), Inlining 125.863 ms, Optimization 552.419 ms, Emission 500.940 ms, Total 1193.112 ms"
-- Execution Time: 618.602 ms

CREATE OR REPLACE VIEW new_referee_work AS
SELECT
    r.ssn AS referee_ssn,
    p.first_name || ' ' || p.last_name AS referee_name,
    c.name AS country,
    sc.name AS sport_category_name,
    COUNT(rd.duel_id) AS total_duels_officiated,
    MIN(d.duel_date) AS first_duel_date,
    COUNT(*) FILTER (WHERE d.duel_date+d.duel_time > NOW()) AS upcoming_duels
FROM REFEREE r
JOIN PERSON p ON r.ssn = p.ssn
JOIN COUNTRY c ON c.id = p.country_id
JOIN SPORT_CATEGORY sc ON r.sport_category_id = sc.id
LEFT JOIN NEW_REFEREEING_DUEL rd ON rd.referee_ssn = r.ssn
LEFT JOIN NEW_DUEL d ON d.id = rd.duel_id
JOIN FEDERATION f ON f.id = r.federation_id
GROUP BY r.ssn, p.first_name, p.last_name, c.name, sc.name;

DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from referee_work where referee_ssn = '051195848087';
-- Subquery Scan on referee_work  (cost=277.01..278.48 rows=28 width=104) (actual time=0.494..0.516 rows=1 loops=1)
--   Buffers: shared hit=39
--   ->  GroupAggregate  (cost=277.01..278.20 rows=28 width=119) (actual time=0.492..0.512 rows=1 loops=1)
-- "        Group Key: p.first_name, p.last_name, c.name, sc.name"
--         Buffers: shared hit=39
--         ->  Sort  (cost=277.01..277.08 rows=28 width=79) (actual time=0.478..0.498 rows=4 loops=1)
-- "              Sort Key: p.first_name, p.last_name, c.name, sc.name"
--               Sort Method: quicksort  Memory: 25kB
--               Buffers: shared hit=39
--               ->  Hash Join  (cost=7.13..276.34 rows=28 width=79) (actual time=0.412..0.474 rows=4 loops=1)
--                     Hash Cond: (p.country_id = c.id)
--                     Buffers: shared hit=39
--                     ->  Nested Loop Left Join  (cost=2.42..271.55 rows=28 width=75) (actual time=0.125..0.177 rows=4 loops=1)
--                           Buffers: shared hit=38
--                           ->  Nested Loop Left Join  (cost=1.99..34.88 rows=28 width=67) (actual time=0.108..0.135 rows=4 loops=1)
--                                 Buffers: shared hit=22
--                                 ->  Nested Loop  (cost=1.42..29.55 rows=1 width=63) (actual time=0.085..0.099 rows=1 loops=1)
--                                       Buffers: shared hit=14
--                                       ->  Nested Loop  (cost=1.14..25.25 rows=1 width=67) (actual time=0.065..0.075 rows=1 loops=1)
--                                             Buffers: shared hit=11
--                                             ->  Nested Loop  (cost=0.99..17.04 rows=1 width=41) (actual time=0.048..0.055 rows=1 loops=1)
--                                                   Buffers: shared hit=9
--                                                   ->  Index Scan using referee_pkey on referee r  (cost=0.43..8.45 rows=1 width=22) (actual time=0.022..0.023 rows=1 loops=1)
--                                                         Index Cond: (ssn = '051195848087'::bpchar)
--                                                         Buffers: shared hit=4
--                                                   ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=33) (actual time=0.021..0.023 rows=1 loops=1)
--                                                         Index Cond: (ssn = '051195848087'::bpchar)
--                                                         Buffers: shared hit=5
--                                             ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..8.17 rows=1 width=34) (actual time=0.014..0.015 rows=1 loops=1)
--                                                   Index Cond: (id = r.sport_category_id)
--                                                   Buffers: shared hit=2
--                                       ->  Index Only Scan using federation_pkey on federation f  (cost=0.28..4.30 rows=1 width=4) (actual time=0.018..0.018 rows=1 loops=1)
--                                             Index Cond: (id = r.federation_id)
--                                             Heap Fetches: 0
--                                             Buffers: shared hit=3
--                                 ->  Index Only Scan using refereeing_duel_pkey on refereeing_duel rd  (cost=0.56..5.05 rows=28 width=18) (actual time=0.021..0.027 rows=4 loops=1)
--                                       Index Cond: (referee_ssn = '051195848087'::bpchar)
--                                       Heap Fetches: 0
--                                       Buffers: shared hit=8
--                           ->  Index Scan using duel_pkey on duel d  (cost=0.43..8.45 rows=1 width=12) (actual time=0.007..0.007 rows=1 loops=4)
--                                 Index Cond: (id = rd.duel_id)
--                                 Buffers: shared hit=16
--                     ->  Hash  (cost=2.65..2.65 rows=165 width=12) (actual time=0.250..0.252 rows=165 loops=1)
--                           Buckets: 1024  Batches: 1  Memory Usage: 16kB
--                           Buffers: shared hit=1
--                           ->  Seq Scan on country c  (cost=0.00..2.65 rows=165 width=12) (actual time=0.011..0.118 rows=165 loops=1)
--                                 Buffers: shared hit=1
-- Planning:
--   Buffers: shared hit=35
-- Planning Time: 1.156 ms
-- Execution Time: 0.691 ms


DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from new_referee_work where referee_ssn = '051195848087';
-- Subquery Scan on new_referee_work  (cost=921.44..923.39 rows=37 width=104) (actual time=0.794..0.830 rows=1 loops=1)
--   Buffers: shared hit=139
--   ->  GroupAggregate  (cost=921.44..923.02 rows=37 width=119) (actual time=0.792..0.825 rows=1 loops=1)
-- "        Group Key: p.first_name, p.last_name, c.name, sc.name"
--         Buffers: shared hit=139
--         ->  Sort  (cost=921.44..921.54 rows=37 width=83) (actual time=0.776..0.811 rows=4 loops=1)
-- "              Sort Key: p.first_name, p.last_name, c.name, sc.name"
--               Sort Method: quicksort  Memory: 25kB
--               Buffers: shared hit=139
--               ->  Hash Join  (cost=6.99..920.48 rows=37 width=83) (actual time=0.391..0.789 rows=4 loops=1)
--                     Hash Cond: (p.country_id = c.id)
--                     Buffers: shared hit=139
--                     ->  Nested Loop Left Join  (cost=2.27..915.67 rows=37 width=79) (actual time=0.126..0.513 rows=4 loops=1)
--                           Buffers: shared hit=138
--                           ->  Nested Loop Left Join  (cost=1.99..34.36 rows=9 width=67) (actual time=0.107..0.136 rows=4 loops=1)
--                                 Buffers: shared hit=22
--                                 ->  Nested Loop  (cost=1.42..29.55 rows=1 width=63) (actual time=0.080..0.094 rows=1 loops=1)
--                                       Buffers: shared hit=14
--                                       ->  Nested Loop  (cost=1.14..25.25 rows=1 width=67) (actual time=0.063..0.074 rows=1 loops=1)
--                                             Buffers: shared hit=11
--                                             ->  Nested Loop  (cost=0.99..17.04 rows=1 width=41) (actual time=0.048..0.056 rows=1 loops=1)
--                                                   Buffers: shared hit=9
--                                                   ->  Index Scan using referee_pkey on referee r  (cost=0.43..8.45 rows=1 width=22) (actual time=0.025..0.026 rows=1 loops=1)
--                                                         Index Cond: (ssn = '051195848087'::bpchar)
--                                                         Buffers: shared hit=4
--                                                   ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=33) (actual time=0.019..0.021 rows=1 loops=1)
--                                                         Index Cond: (ssn = '051195848087'::bpchar)
--                                                         Buffers: shared hit=5
--                                             ->  Index Scan using sport_category_pkey on sport_category sc  (cost=0.15..8.17 rows=1 width=34) (actual time=0.012..0.012 rows=1 loops=1)
--                                                   Index Cond: (id = r.sport_category_id)
--                                                   Buffers: shared hit=2
--                                       ->  Index Only Scan using federation_pkey on federation f  (cost=0.28..4.30 rows=1 width=4) (actual time=0.014..0.015 rows=1 loops=1)
--                                             Index Cond: (id = r.federation_id)
--                                             Heap Fetches: 0
--                                             Buffers: shared hit=3
--                                 ->  Index Only Scan using new_refereeing_duel_pkey on new_refereeing_duel rd  (cost=0.56..4.72 rows=9 width=18) (actual time=0.025..0.031 rows=4 loops=1)
--                                       Index Cond: (referee_ssn = '051195848087'::bpchar)
--                                       Heap Fetches: 0
--                                       Buffers: shared hit=8
--                           ->  Append  (cost=0.29..97.75 rows=17 width=16) (actual time=0.020..0.090 rows=1 loops=4)
--                                 Buffers: shared hit=116
--                                 ->  Index Scan using new_duel_2021_pkey on new_duel_2021 d_1  (cost=0.29..8.30 rows=1 width=16) (actual time=0.006..0.006 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=9
--                                 ->  Index Scan using new_duel_2022_pkey on new_duel_2022 d_2  (cost=0.43..8.45 rows=1 width=16) (actual time=0.007..0.007 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=13
--                                 ->  Index Scan using new_duel_2023_pkey on new_duel_2023 d_3  (cost=0.43..8.45 rows=1 width=16) (actual time=0.006..0.006 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=12
--                                 ->  Index Scan using new_duel_2024_pkey on new_duel_2024 d_4  (cost=0.43..8.45 rows=1 width=16) (actual time=0.006..0.006 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=12
--                                 ->  Index Scan using new_duel_2025_pkey on new_duel_2025 d_5  (cost=0.43..8.45 rows=1 width=16) (actual time=0.006..0.007 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=13
--                                 ->  Index Scan using new_duel_2026_pkey on new_duel_2026 d_6  (cost=0.43..8.45 rows=1 width=16) (actual time=0.007..0.007 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=13
--                                 ->  Index Scan using new_duel_2027_pkey on new_duel_2027 d_7  (cost=0.29..8.31 rows=1 width=16) (actual time=0.005..0.005 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=8
--                                 ->  Index Scan using new_duel_2028_pkey on new_duel_2028 d_8  (cost=0.29..8.31 rows=1 width=16) (actual time=0.004..0.005 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=8
--                                 ->  Index Scan using new_duel_2029_pkey on new_duel_2029 d_9  (cost=0.29..8.31 rows=1 width=16) (actual time=0.005..0.005 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=8
--                                 ->  Index Scan using new_duel_2030_pkey on new_duel_2030 d_10  (cost=0.29..8.31 rows=1 width=16) (actual time=0.012..0.012 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=8
--                                 ->  Index Scan using new_duel_2031_pkey on new_duel_2031 d_11  (cost=0.29..8.30 rows=1 width=16) (actual time=0.006..0.006 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=8
--                                 ->  Index Scan using new_duel_2041_pkey on new_duel_2041 d_12  (cost=0.15..5.59 rows=6 width=16) (actual time=0.004..0.004 rows=0 loops=4)
--                                       Index Cond: (id = rd.duel_id)
--                                       Buffers: shared hit=4
--                     ->  Hash  (cost=2.65..2.65 rows=165 width=12) (actual time=0.249..0.251 rows=165 loops=1)
--                           Buckets: 1024  Batches: 1  Memory Usage: 16kB
--                           Buffers: shared hit=1
--                           ->  Seq Scan on country c  (cost=0.00..2.65 rows=165 width=12) (actual time=0.009..0.124 rows=165 loops=1)
--                                 Buffers: shared hit=1
-- Planning:
--   Buffers: shared hit=20
-- Planning Time: 0.931 ms
-- Execution Time: 1.120 ms

-- NOTE: Nema golem benefit, skoro isti se, no e primer za migriranje na view

CREATE OR REPLACE VIEW new_team_stats AS
SELECT
    t.id AS team_id,
    t.name AS team_name,
    scat.name AS sport_category,
    c.name AS country,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM COACHING_TEAM ct
        JOIN COACH co ON co.ssn = ct.coach_ssn
        JOIN PERSON p ON p.ssn = co.ssn
        WHERE ct.team_id = t.id
          AND ct.end_date IS NULL
    ) AS coaches,
    (
        SELECT COUNT(*)
        FROM SPORTSPERSON_CONTRACT spc
        JOIN SPORTSPERSON sp ON sp.ssn = spc.player_ssn
            AND sp.sport_category_id = t.sport_category_id
        WHERE spc.club_id = t.club_id
          AND spc.start_date <= CURRENT_DATE
          AND (spc.end_date IS NULL OR spc.end_date >= CURRENT_DATE)
    ) AS active_contracts,
    (
        SELECT COUNT(*)
        FROM NEW_DUEL d
        WHERE d.duel_date > CURRENT_DATE
          AND (d.home_team_id = t.id OR d.away_team_id = t.id)
    ) AS registered_upcoming_duels,
    (
        SELECT d.duel_date
        FROM NEW_DUEL d
        WHERE d.duel_date > CURRENT_DATE
          AND (d.home_team_id = t.id OR d.away_team_id = t.id)
        ORDER BY d.duel_date, d.duel_time
        LIMIT 1
    ) AS next_duel_date
FROM SPORT_TEAM t
JOIN SPORT_CLUB sc ON sc.id = t.club_id
JOIN COUNTRY c ON c.id = sc.country_id
JOIN SPORT_CATEGORY scat ON scat.id = t.sport_category_id;

DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from team_stats ts where ts.team_id = 205986;
-- Nested Loop  (cost=1.00..263677.68 rows=1 width=140) (actual time=472.999..473.038 rows=1 loops=1)
--   Buffers: shared hit=303739 read=48403 written=1
--   ->  Nested Loop  (cost=0.86..16.91 rows=1 width=66) (actual time=20.851..20.863 rows=1 loops=1)
--         Buffers: shared hit=8 read=1
--         ->  Nested Loop  (cost=0.71..16.75 rows=1 width=62) (actual time=20.823..20.831 rows=1 loops=1)
--               Buffers: shared hit=6 read=1
--               ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..8.44 rows=1 width=58) (actual time=0.024..0.027 rows=1 loops=1)
--                     Index Cond: (id = 205986)
--                     Buffers: shared hit=4
--               ->  Index Scan using sport_club_pkey on sport_club sc  (cost=0.29..8.31 rows=1 width=8) (actual time=0.051..0.052 rows=1 loops=1)
--                     Index Cond: (id = t.club_id)
--                     Buffers: shared hit=2 read=1
--         ->  Index Scan using country_pkey on country c  (cost=0.14..0.16 rows=1 width=12) (actual time=0.017..0.017 rows=1 loops=1)
--               Index Cond: (id = sc.country_id)
--               Buffers: shared hit=2
--   ->  Index Scan using sport_category_pkey on sport_category scat  (cost=0.15..8.17 rows=1 width=34) (actual time=0.016..0.016 rows=1 loops=1)
--         Index Cond: (id = t.sport_category_id)
--         Buffers: shared hit=2
--   SubPlan 1
--     ->  Aggregate  (cost=21.42..21.43 rows=1 width=32) (actual time=0.053..0.062 rows=1 loops=1)
--           Buffers: shared hit=2
--           ->  Sort  (cost=21.41..21.41 rows=1 width=15) (actual time=0.044..0.052 rows=0 loops=1)
--                 Sort Key: p.last_name
--                 Sort Method: quicksort  Memory: 25kB
--                 Buffers: shared hit=2
--                 ->  Nested Loop  (cost=4.89..21.40 rows=1 width=15) (actual time=0.025..0.032 rows=0 loops=1)
--                       Join Filter: (ct.coach_ssn = co.ssn)
--                       Buffers: shared hit=2
--                       ->  Nested Loop  (cost=4.74..21.22 rows=1 width=85) (actual time=0.023..0.027 rows=0 loops=1)
--                             Buffers: shared hit=2
--                             ->  Bitmap Heap Scan on coaching_team ct  (cost=4.18..12.64 rows=1 width=56) (actual time=0.020..0.022 rows=0 loops=1)
--                                   Recheck Cond: (team_id = t.id)
--                                   Filter: (end_date IS NULL)
--                                   Buffers: shared hit=2
--                                   ->  Bitmap Index Scan on coaching_team_pkey  (cost=0.00..4.18 rows=4 width=0) (actual time=0.005..0.006 rows=0 loops=1)
--                                         Index Cond: (team_id = t.id)
--                                         Buffers: shared hit=2
--                             ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = ct.coach_ssn)
--                       ->  Index Only Scan using coach_pkey on coach co  (cost=0.15..0.17 rows=1 width=56) (never executed)
--                             Index Cond: (ssn = p.ssn)
--                             Heap Fetches: 0
--   SubPlan 2
--     ->  Aggregate  (cost=125005.26..125005.27 rows=1 width=8) (actual time=168.254..168.259 rows=1 loops=1)
--           Buffers: shared hit=99 read=32200
--           ->  Nested Loop  (cost=0.43..125005.26 rows=1 width=0) (actual time=65.022..168.193 rows=3 loops=1)
--                 Buffers: shared hit=99 read=32200
--                 ->  Seq Scan on sportsperson_contract spc  (cost=0.00..124523.60 rows=57 width=14) (actual time=8.237..167.189 rows=51 loops=1)
--                       Filter: ((club_id = t.club_id) AND (start_date <= CURRENT_DATE) AND ((end_date IS NULL) OR (end_date >= CURRENT_DATE)))
--                       Rows Removed by Filter: 4107887
--                       Buffers: shared read=32095
--                 ->  Index Scan using sportsperson_pkey on sportsperson sp  (cost=0.43..8.45 rows=1 width=14) (actual time=0.015..0.015 rows=0 loops=51)
--                       Index Cond: (ssn = spc.player_ssn)
--                       Filter: (sport_category_id = t.sport_category_id)
--                       Rows Removed by Filter: 1
--                       Buffers: shared hit=99 read=105
--   SubPlan 3
--     ->  Aggregate  (cost=132598.12..132598.13 rows=1 width=8) (actual time=267.139..267.142 rows=1 loops=1)
--           Buffers: shared hit=279991 read=16202 written=1
--           ->  Index Only Scan using duel_upcoming_indexes on duel d  (cost=0.56..132598.07 rows=22 width=0) (actual time=16.504..267.027 rows=8 loops=1)
--                 Index Cond: (start_time > now())
--                 Filter: ((home_team_id = t.id) OR (away_team_id = t.id))
--                 Rows Removed by Filter: 2904749
--                 Heap Fetches: 20
--                 Buffers: shared hit=279991 read=16202 written=1
--   SubPlan 4
--     ->  Limit  (cost=0.56..6027.72 rows=1 width=12) (actual time=16.612..16.615 rows=1 loops=1)
--           Buffers: shared hit=23637
--           ->  Index Only Scan using duel_upcoming_indexes on duel d_1  (cost=0.56..132598.12 rows=22 width=12) (actual time=16.603..16.603 rows=1 loops=1)
--                 Index Cond: (start_time > now())
--                 Filter: ((home_team_id = t.id) OR (away_team_id = t.id))
--                 Rows Removed by Filter: 215109
--                 Heap Fetches: 0
--                 Buffers: shared hit=23637
-- Planning:
--   Buffers: shared hit=21 read=3
-- Planning Time: 1.041 ms
-- JIT:
--   Functions: 61
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 2.404 ms (Deform 0.766 ms), Inlining 0.000 ms, Optimization 0.754 ms, Emission 20.227 ms, Total 23.385 ms"
-- Execution Time: 475.794 ms

DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from new_team_stats ts where ts.team_id = 205986;
-- Nested Loop  (cost=1.00..892891.21 rows=1 width=140) (actual time=743.014..743.078 rows=1 loops=1)
--   Buffers: shared hit=5233 read=91773
--   ->  Nested Loop  (cost=0.86..16.91 rows=1 width=66) (actual time=244.740..244.754 rows=1 loops=1)
--         Buffers: shared hit=9
--         ->  Nested Loop  (cost=0.71..16.75 rows=1 width=62) (actual time=244.712..244.722 rows=1 loops=1)
--               Buffers: shared hit=7
--               ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..8.44 rows=1 width=58) (actual time=0.074..0.080 rows=1 loops=1)
--                     Index Cond: (id = 205986)
--                     Buffers: shared hit=4
--               ->  Index Scan using sport_club_pkey on sport_club sc  (cost=0.29..8.31 rows=1 width=8) (actual time=0.086..0.087 rows=1 loops=1)
--                     Index Cond: (id = t.club_id)
--                     Buffers: shared hit=3
--         ->  Index Scan using country_pkey on country c  (cost=0.14..0.16 rows=1 width=12) (actual time=0.016..0.017 rows=1 loops=1)
--               Index Cond: (id = sc.country_id)
--               Buffers: shared hit=2
--   ->  Index Scan using sport_category_pkey on sport_category scat  (cost=0.15..8.17 rows=1 width=34) (actual time=0.013..0.014 rows=1 loops=1)
--         Index Cond: (id = t.sport_category_id)
--         Buffers: shared hit=2
--   SubPlan 1
--     ->  Aggregate  (cost=21.42..21.43 rows=1 width=32) (actual time=0.046..0.056 rows=1 loops=1)
--           Buffers: shared hit=2
--           ->  Sort  (cost=21.41..21.41 rows=1 width=15) (actual time=0.039..0.047 rows=0 loops=1)
--                 Sort Key: p.last_name
--                 Sort Method: quicksort  Memory: 25kB
--                 Buffers: shared hit=2
--                 ->  Nested Loop  (cost=4.89..21.40 rows=1 width=15) (actual time=0.021..0.027 rows=0 loops=1)
--                       Join Filter: (ct.coach_ssn = co.ssn)
--                       Buffers: shared hit=2
--                       ->  Nested Loop  (cost=4.74..21.22 rows=1 width=85) (actual time=0.019..0.023 rows=0 loops=1)
--                             Buffers: shared hit=2
--                             ->  Bitmap Heap Scan on coaching_team ct  (cost=4.18..12.64 rows=1 width=56) (actual time=0.017..0.020 rows=0 loops=1)
--                                   Recheck Cond: (team_id = t.id)
--                                   Filter: (end_date IS NULL)
--                                   Buffers: shared hit=2
--                                   ->  Bitmap Index Scan on coaching_team_pkey  (cost=0.00..4.18 rows=4 width=0) (actual time=0.003..0.004 rows=0 loops=1)
--                                         Index Cond: (team_id = t.id)
--                                         Buffers: shared hit=2
--                             ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = ct.coach_ssn)
--                       ->  Index Only Scan using coach_pkey on coach co  (cost=0.15..0.17 rows=1 width=56) (never executed)
--                             Index Cond: (ssn = p.ssn)
--                             Heap Fetches: 0
--   SubPlan 2
--     ->  Aggregate  (cost=125005.26..125005.27 rows=1 width=8) (actual time=141.416..141.422 rows=1 loops=1)
--           Buffers: shared hit=300 read=31999
--           ->  Nested Loop  (cost=0.43..125005.26 rows=1 width=0) (actual time=54.753..141.370 rows=3 loops=1)
--                 Buffers: shared hit=300 read=31999
--                 ->  Seq Scan on sportsperson_contract spc  (cost=0.00..124523.60 rows=57 width=14) (actual time=7.027..140.810 rows=51 loops=1)
--                       Filter: ((club_id = t.club_id) AND (start_date <= CURRENT_DATE) AND ((end_date IS NULL) OR (end_date >= CURRENT_DATE)))
--                       Rows Removed by Filter: 4107887
--                       Buffers: shared hit=96 read=31999
--                 ->  Index Scan using sportsperson_pkey on sportsperson sp  (cost=0.43..8.45 rows=1 width=14) (actual time=0.008..0.008 rows=0 loops=51)
--                       Index Cond: (ssn = spc.player_ssn)
--                       Filter: (sport_category_id = t.sport_category_id)
--                       Rows Removed by Filter: 1
--                       Buffers: shared hit=204
--   SubPlan 3
--     ->  Aggregate  (cost=383919.64..383919.65 rows=1 width=8) (actual time=192.702..192.716 rows=1 loops=1)
--           Buffers: shared hit=2444 read=29903
--           ->  Append  (cost=0.29..383919.55 rows=37 width=0) (actual time=38.897..192.672 rows=8 loops=1)
--                 Buffers: shared hit=2444 read=29903
--                 Subplans Removed: 5
--                 ->  Seq Scan on new_duel_2026 d_1  (cost=0.00..94446.20 rows=14 width=0) (actual time=38.894..181.944 rows=8 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 3217540
--                       Buffers: shared hit=192 read=29903
--                 ->  Seq Scan on new_duel_2027 d_2  (cost=0.00..1628.16 rows=3 width=0) (actual time=2.420..2.421 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 55458
--                       Buffers: shared hit=519
--                 ->  Seq Scan on new_duel_2028 d_3  (cost=0.00..1582.08 rows=3 width=0) (actual time=2.349..2.349 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 53904
--                       Buffers: shared hit=504
--                 ->  Seq Scan on new_duel_2029 d_4  (cost=0.00..1571.88 rows=3 width=0) (actual time=2.338..2.339 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 53544
--                       Buffers: shared hit=501
--                 ->  Seq Scan on new_duel_2030 d_5  (cost=0.00..1573.06 rows=3 width=0) (actual time=2.490..2.491 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 53603
--                       Buffers: shared hit=501
--                 ->  Seq Scan on new_duel_2031 d_6  (cost=0.00..708.22 rows=2 width=0) (actual time=1.056..1.057 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 24111
--                       Buffers: shared hit=226
--                 ->  Seq Scan on new_duel_2041 d_7  (cost=0.00..32.60 rows=4 width=0) (actual time=0.019..0.020 rows=0 loops=1)
--                       Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                       Rows Removed by Filter: 20
--                       Buffers: shared hit=1
--   SubPlan 4
--     ->  Limit  (cost=383919.73..383919.74 rows=1 width=12) (actual time=164.040..164.054 rows=1 loops=1)
--           Buffers: shared hit=2476 read=29871
--           ->  Sort  (cost=383919.73..383919.83 rows=37 width=12) (actual time=164.037..164.049 rows=1 loops=1)
-- "                Sort Key: d_8.duel_date, d_8.duel_time"
--                 Sort Method: top-N heapsort  Memory: 25kB
--                 Buffers: shared hit=2476 read=29871
--                 ->  Append  (cost=0.29..383919.55 rows=37 width=12) (actual time=32.880..163.997 rows=8 loops=1)
--                       Buffers: shared hit=2476 read=29871
--                       Subplans Removed: 5
--                       ->  Seq Scan on new_duel_2026 d_9  (cost=0.00..94446.20 rows=14 width=12) (actual time=32.878..153.638 rows=8 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 3217540
--                             Buffers: shared hit=224 read=29871
--                       ->  Seq Scan on new_duel_2027 d_10  (cost=0.00..1628.16 rows=3 width=12) (actual time=2.332..2.333 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 55458
--                             Buffers: shared hit=519
--                       ->  Seq Scan on new_duel_2028 d_11  (cost=0.00..1582.08 rows=3 width=12) (actual time=2.333..2.333 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 53904
--                             Buffers: shared hit=504
--                       ->  Seq Scan on new_duel_2029 d_12  (cost=0.00..1571.88 rows=3 width=12) (actual time=2.294..2.295 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 53544
--                             Buffers: shared hit=501
--                       ->  Seq Scan on new_duel_2030 d_13  (cost=0.00..1573.06 rows=3 width=12) (actual time=2.270..2.271 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 53603
--                             Buffers: shared hit=501
--                       ->  Seq Scan on new_duel_2031 d_14  (cost=0.00..708.22 rows=2 width=12) (actual time=1.057..1.058 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 24111
--                             Buffers: shared hit=226
--                       ->  Seq Scan on new_duel_2041 d_15  (cost=0.00..32.60 rows=4 width=12) (actual time=0.020..0.020 rows=0 loops=1)
--                             Filter: ((duel_date > CURRENT_DATE) AND ((home_team_id = t.id) OR (away_team_id = t.id)))
--                             Rows Removed by Filter: 20
--                             Buffers: shared hit=1
-- Planning:
--   Buffers: shared hit=27
-- Planning Time: 1.222 ms
-- JIT:
--   Functions: 105
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 4.135 ms (Deform 1.288 ms), Inlining 57.827 ms, Optimization 268.170 ms, Emission 182.831 ms, Total 512.963 ms"
-- Execution Time: 1011.932 ms

-- NOTE: Particioniranje go pravi mnogu posporo, sepak e prifatlivo vreme na izvrshuvanje


CREATE OR REPLACE VIEW new_duel_history AS
SELECT
    d.id AS duel_id,
    d.duel_time,
    l.name AS location,
    ht.name AS home_team,
    at.name AS away_team,
    COALESCE(d.home_team_score, 0) AS home_team_scores,
    COALESCE(d.away_team_score, 0) AS away_team_scores,
    CASE
        WHEN d.home_team_score > d.away_team_score THEN ht.name
        WHEN d.away_team_score > d.home_team_score THEN at.name
        ELSE 'Draw'
    END AS result,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (' || s.time_score::text || ')', ', ' ORDER BY s.time_score)
        FROM NEW_SCORE s
        JOIN NEW_TEAM_ROSTER tr
            ON tr.duel_id = s.duel_id
            AND tr.player_ssn = s.player_ssn
            AND tr.team_id = d.home_team_id
        JOIN PERSON p ON p.ssn = s.player_ssn
        WHERE s.duel_id = d.id
    ) AS home_scorers,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (' || s.time_score::text || ')', ', ' ORDER BY s.time_score)
        FROM NEW_SCORE s
        JOIN NEW_TEAM_ROSTER tr
            ON tr.duel_id = s.duel_id
            AND tr.player_ssn = s.player_ssn
            AND tr.team_id = d.away_team_id
        JOIN PERSON p ON p.ssn = s.player_ssn
        WHERE s.duel_id = d.id
    ) AS away_scorers,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (off ' || tr.end_time::text || ')', ', ')
        FROM NEW_TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.home_team_id
          AND scat.team_capacity > 3
          AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
    ) AS home_red_cards,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (off ' || tr.end_time::text || ')', ', ')
        FROM NEW_TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.away_team_id
          AND scat.team_capacity > 3
          AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
    ) AS away_red_cards,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM NEW_TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id AND tr.team_id = d.home_team_id
    ) AS home_roster,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM NEW_TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id AND tr.team_id = d.away_team_id
    ) AS away_roster,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ')
        FROM NEW_REFEREEING_DUEL rd
        JOIN PERSON p ON p.ssn = rd.referee_ssn
        WHERE rd.duel_id = d.id
    ) AS referees
FROM NEW_DUEL d
JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
JOIN SPORT_TEAM at ON at.id = d.away_team_id
JOIN LOCATION l ON l.id = d.location_id
WHERE d.duel_date < CURRENT_DATE
ORDER BY d.duel_date DESC, d.duel_time DESC;

DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from duel_history where duel_id = 4430009;
-- Sort  (cost=4100195.45..4100195.45 rows=1 width=388) (actual time=21165.288..21165.356 rows=1 loops=1)
--   Sort Key: d.start_time DESC
--   Sort Method: quicksort  Memory: 27kB
--   Buffers: shared hit=5193 read=1910764
--   ->  Nested Loop  (cost=1.57..4100195.44 rows=1 width=388) (actual time=21165.260..21165.335 rows=1 loops=1)
--         Buffers: shared hit=5193 read=1910764
--         ->  Nested Loop  (cost=1.28..25.34 rows=1 width=128) (actual time=748.242..748.256 rows=1 loops=1)
--               Buffers: shared hit=12
--               ->  Nested Loop  (cost=0.86..16.90 rows=1 width=82) (actual time=748.218..748.228 rows=1 loops=1)
--                     Buffers: shared hit=8
--                     ->  Index Scan using duel_pkey on duel d  (cost=0.43..8.46 rows=1 width=36) (actual time=748.169..748.174 rows=1 loops=1)
--                           Index Cond: (id = 4430009)
--                           Filter: (start_time < now())
--                           Buffers: shared hit=4
--                     ->  Index Scan using sport_team_pkey on sport_team ht  (cost=0.42..8.44 rows=1 width=50) (actual time=0.031..0.032 rows=1 loops=1)
--                           Index Cond: (id = d.home_team_id)
--                           Buffers: shared hit=4
--               ->  Index Scan using sport_team_pkey on sport_team at  (cost=0.42..8.44 rows=1 width=50) (actual time=0.014..0.014 rows=1 loops=1)
--                     Index Cond: (id = d.away_team_id)
--                     Buffers: shared hit=4
--         ->  Index Scan using location_pkey on location l  (cost=0.29..8.31 rows=1 width=24) (actual time=0.014..0.015 rows=1 loops=1)
--               Index Cond: (id = d.location_id)
--               Buffers: shared hit=3
--         SubPlan 1
--           ->  Aggregate  (cost=598127.96..598127.97 rows=1 width=32) (actual time=850.215..850.225 rows=1 loops=1)
--                 Buffers: shared hit=620 read=220173
--                 ->  Sort  (cost=598127.94..598127.94 rows=1 width=23) (actual time=850.179..850.187 rows=0 loops=1)
--                       Sort Key: s.time_score
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=620 read=220173
--                       ->  Nested Loop  (cost=1.12..598127.93 rows=1 width=23) (actual time=850.170..850.176 rows=0 loops=1)
--                             Join Filter: (tr.player_ssn = p.ssn)
--                             Buffers: shared hit=620 read=220173
--                             ->  Nested Loop  (cost=0.56..598119.36 rows=1 width=36) (actual time=850.167..850.171 rows=0 loops=1)
--                                   Buffers: shared hit=620 read=220173
--                                   ->  Seq Scan on score s  (cost=0.00..595589.00 rows=551 width=26) (actual time=640.745..849.888 rows=51 loops=1)
--                                         Filter: (duel_id = d.id)
--                                         Rows Removed by Filter: 29999949
--                                         Buffers: shared hit=416 read=220173
--                                   ->  Index Only Scan using team_roster_pkey on team_roster tr  (cost=0.56..4.58 rows=1 width=18) (actual time=0.003..0.003 rows=0 loops=51)
--                                         Index Cond: ((player_ssn = s.player_ssn) AND (team_id = d.home_team_id) AND (duel_id = d.id))
--                                         Heap Fetches: 0
--                                         Buffers: shared hit=204
--                             ->  Index Scan using person_pkey on person p  (cost=0.56..8.56 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = s.player_ssn)
--         SubPlan 2
--           ->  Aggregate  (cost=598127.96..598127.97 rows=1 width=32) (actual time=820.856..820.866 rows=1 loops=1)
--                 Buffers: shared hit=908 read=220141
--                 ->  Sort  (cost=598127.94..598127.94 rows=1 width=23) (actual time=820.738..820.777 rows=51 loops=1)
--                       Sort Key: s_1.time_score
--                       Sort Method: quicksort  Memory: 26kB
--                       Buffers: shared hit=908 read=220141
--                       ->  Nested Loop  (cost=1.12..598127.93 rows=1 width=23) (actual time=614.448..820.696 rows=51 loops=1)
--                             Join Filter: (tr_1.player_ssn = p_1.ssn)
--                             Buffers: shared hit=908 read=220141
--                             ->  Nested Loop  (cost=0.56..598119.36 rows=1 width=36) (actual time=614.411..820.425 rows=51 loops=1)
--                                   Buffers: shared hit=653 read=220141
--                                   ->  Seq Scan on score s_1  (cost=0.00..595589.00 rows=551 width=26) (actual time=614.312..820.092 rows=51 loops=1)
--                                         Filter: (duel_id = d.id)
--                                         Rows Removed by Filter: 29999949
--                                         Buffers: shared hit=448 read=220141
--                                   ->  Index Only Scan using team_roster_pkey on team_roster tr_1  (cost=0.56..4.58 rows=1 width=18) (actual time=0.003..0.003 rows=1 loops=51)
--                                         Index Cond: ((player_ssn = s_1.player_ssn) AND (team_id = d.away_team_id) AND (duel_id = d.id))
--                                         Heap Fetches: 0
--                                         Buffers: shared hit=205
--                             ->  Index Scan using person_pkey on person p_1  (cost=0.56..8.56 rows=1 width=29) (actual time=0.003..0.003 rows=1 loops=51)
--                                   Index Cond: (ssn = s_1.player_ssn)
--                                   Buffers: shared hit=255
--         SubPlan 3
--           ->  Aggregate  (cost=572455.13..572455.14 rows=1 width=32) (actual time=3898.874..3898.880 rows=1 loops=1)
--                 Buffers: shared hit=769 read=315887
--                 ->  Nested Loop  (cost=0.71..572455.11 rows=1 width=23) (actual time=3898.838..3898.842 rows=0 loops=1)
--                       Join Filter: (tr_2.end_time < (((scat.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--                       Buffers: shared hit=769 read=315887
--                       ->  Nested Loop  (cost=0.56..572446.92 rows=1 width=23) (actual time=3898.836..3898.838 rows=0 loops=1)
--                             Buffers: shared hit=769 read=315887
--                             ->  Seq Scan on team_roster tr_2  (cost=0.00..572438.34 rows=1 width=22) (actual time=3898.833..3898.834 rows=0 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.home_team_id))
--                                   Rows Removed by Filter: 20000003
--                                   Buffers: shared hit=769 read=315887
--                             ->  Index Scan using person_pkey on person p_2  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = tr_2.player_ssn)
--                       ->  Index Scan using sport_category_pkey on sport_category scat  (cost=0.15..8.17 rows=1 width=4) (never executed)
--                             Index Cond: (id = d.sport_category_id)
--                             Filter: (team_capacity > 3)
--         SubPlan 4
--           ->  Aggregate  (cost=572455.13..572455.14 rows=1 width=32) (actual time=3568.086..3568.095 rows=1 loops=1)
--                 Buffers: shared hit=906 read=315855
--                 ->  Nested Loop  (cost=0.71..572455.11 rows=1 width=23) (actual time=1085.741..3568.040 rows=2 loops=1)
--                       Join Filter: (tr_3.end_time < (((scat_1.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--                       Rows Removed by Join Filter: 13
--                       Buffers: shared hit=906 read=315855
--                       ->  Nested Loop  (cost=0.56..572446.92 rows=1 width=23) (actual time=1085.650..3567.905 rows=15 loops=1)
--                             Buffers: shared hit=876 read=315855
--                             ->  Seq Scan on team_roster tr_3  (cost=0.00..572438.34 rows=1 width=22) (actual time=1085.539..3567.623 rows=15 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.away_team_id))
--                                   Rows Removed by Filter: 19999988
--                                   Buffers: shared hit=801 read=315855
--                             ->  Index Scan using person_pkey on person p_3  (cost=0.56..8.58 rows=1 width=29) (actual time=0.012..0.012 rows=1 loops=15)
--                                   Index Cond: (ssn = tr_3.player_ssn)
--                                   Buffers: shared hit=75
--                       ->  Index Scan using sport_category_pkey on sport_category scat_1  (cost=0.15..8.17 rows=1 width=4) (actual time=0.004..0.005 rows=1 loops=15)
--                             Index Cond: (id = d.sport_category_id)
--                             Filter: (team_capacity > 3)
--                             Buffers: shared hit=30
--         SubPlan 5
--           ->  Aggregate  (cost=572446.94..572446.95 rows=1 width=32) (actual time=3545.886..3545.892 rows=1 loops=1)
--                 Buffers: shared hit=833 read=315823
--                 ->  Sort  (cost=572446.93..572446.93 rows=1 width=15) (actual time=3545.851..3545.855 rows=0 loops=1)
--                       Sort Key: p_4.last_name
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=833 read=315823
--                       ->  Nested Loop  (cost=0.56..572446.92 rows=1 width=15) (actual time=3545.833..3545.835 rows=0 loops=1)
--                             Buffers: shared hit=833 read=315823
--                             ->  Seq Scan on team_roster tr_4  (cost=0.00..572438.34 rows=1 width=14) (actual time=3545.830..3545.830 rows=0 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.home_team_id))
--                                   Rows Removed by Filter: 20000003
--                                   Buffers: shared hit=833 read=315823
--                             ->  Index Scan using person_pkey on person p_4  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = tr_4.player_ssn)
--         SubPlan 6
--           ->  Aggregate  (cost=572446.94..572446.95 rows=1 width=32) (actual time=3687.637..3687.645 rows=1 loops=1)
--                 Buffers: shared hit=940 read=315791
--                 ->  Sort  (cost=572446.93..572446.93 rows=1 width=15) (actual time=3687.558..3687.573 rows=15 loops=1)
--                       Sort Key: p_5.last_name
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=940 read=315791
--                       ->  Nested Loop  (cost=0.56..572446.92 rows=1 width=15) (actual time=1125.634..3687.526 rows=15 loops=1)
--                             Buffers: shared hit=940 read=315791
--                             ->  Seq Scan on team_roster tr_5  (cost=0.00..572438.34 rows=1 width=14) (actual time=1125.533..3687.297 rows=15 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.away_team_id))
--                                   Rows Removed by Filter: 19999988
--                                   Buffers: shared hit=865 read=315791
--                             ->  Index Scan using person_pkey on person p_5  (cost=0.56..8.58 rows=1 width=29) (actual time=0.009..0.009 rows=1 loops=15)
--                                   Index Cond: (ssn = tr_5.player_ssn)
--                                   Buffers: shared hit=75
--         SubPlan 7
--           ->  Aggregate  (cost=614101.65..614101.66 rows=1 width=32) (actual time=4045.319..4045.325 rows=1 loops=1)
--                 Buffers: shared hit=202 read=207094
--                 ->  Nested Loop  (cost=0.56..614101.63 rows=2 width=15) (actual time=435.934..4045.260 rows=2 loops=1)
--                       Buffers: shared hit=202 read=207094
--                       ->  Seq Scan on refereeing_duel rd  (cost=0.00..614084.48 rows=2 width=14) (actual time=435.829..4045.113 rows=2 loops=1)
--                             Filter: (duel_id = d.id)
--                             Rows Removed by Filter: 32543876
--                             Buffers: shared hit=192 read=207094
--                       ->  Index Scan using person_pkey on person p_6  (cost=0.56..8.58 rows=1 width=29) (actual time=0.034..0.035 rows=1 loops=2)
--                             Index Cond: (ssn = rd.referee_ssn)
--                             Buffers: shared hit=10
-- Planning:
--   Buffers: shared hit=202
-- Planning Time: 2.656 ms
-- JIT:
--   Functions: 136
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 6.553 ms (Deform 2.312 ms), Inlining 16.013 ms, Optimization 414.787 ms, Emission 317.933 ms, Total 755.286 ms"
-- Execution Time: 21172.702 ms


DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from new_duel_history where duel_id = 4430009;
-- Subquery Scan on new_duel_history  (cost=1285.86..49623672.98 rows=13 width=388) (actual time=10782.848..10783.377 rows=1 loops=1)
--   Buffers: shared hit=4847 read=1451026
--   ->  Gather Merge  (cost=1285.86..49623672.85 rows=13 width=392) (actual time=10782.840..10783.366 rows=1 loops=1)
--         Workers Planned: 2
--         Workers Launched: 2
--         Buffers: shared hit=4847 read=1451026
--         ->  Sort  (cost=285.84..285.85 rows=5 width=148) (actual time=259.010..259.025 rows=0 loops=3)
-- "              Sort Key: d.duel_date DESC, d.duel_time DESC"
--               Sort Method: quicksort  Memory: 25kB
--               Buffers: shared hit=69
--               Worker 0:  Sort Method: quicksort  Memory: 25kB
--               Worker 1:  Sort Method: quicksort  Memory: 25kB
--               ->  Nested Loop  (cost=1.57..285.78 rows=5 width=148) (actual time=258.885..258.911 rows=0 loops=3)
--                     Buffers: shared hit=35
--                     ->  Nested Loop  (cost=1.15..243.58 rows=5 width=102) (actual time=258.876..258.900 rows=0 loops=3)
--                           Buffers: shared hit=31
--                           ->  Nested Loop  (cost=0.72..201.38 rows=5 width=56) (actual time=258.866..258.887 rows=0 loops=3)
--                                 Buffers: shared hit=27
--                                 ->  Parallel Append  (cost=0.43..101.66 rows=12 width=40) (actual time=258.853..258.871 rows=0 loops=3)
--                                       Buffers: shared hit=24
--                                       Subplans Removed: 6
--                                       ->  Parallel Index Scan Backward using new_duel_2022_pkey on new_duel_2022 d_2  (cost=0.43..8.45 rows=1 width=40) (actual time=118.905..118.906 rows=0 loops=2)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=4
--                                       ->  Parallel Index Scan Backward using new_duel_2023_pkey on new_duel_2023 d_3  (cost=0.43..8.45 rows=1 width=40) (actual time=117.487..117.488 rows=0 loops=2)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=4
--                                       ->  Parallel Index Scan Backward using new_duel_2024_pkey on new_duel_2024 d_4  (cost=0.43..8.45 rows=1 width=40) (actual time=0.011..0.012 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=4
--                                       ->  Parallel Index Scan Backward using new_duel_2025_pkey on new_duel_2025 d_5  (cost=0.43..8.45 rows=1 width=40) (actual time=0.017..0.019 rows=1 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=5
--                                       ->  Parallel Index Scan Backward using new_duel_2026_pkey on new_duel_2026 d_6  (cost=0.43..8.45 rows=1 width=40) (actual time=0.018..0.018 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=4
--                                       ->  Parallel Index Scan Backward using new_duel_2021_pkey on new_duel_2021 d_1  (cost=0.29..8.31 rows=1 width=40) (actual time=303.739..303.739 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=3
--                                 ->  Index Scan using location_pkey on location l  (cost=0.29..8.31 rows=1 width=24) (actual time=0.024..0.025 rows=1 loops=1)
--                                       Index Cond: (id = d.location_id)
--                                       Buffers: shared hit=3
--                           ->  Index Scan using sport_team_pkey on sport_team ht  (cost=0.42..8.44 rows=1 width=50) (actual time=0.017..0.017 rows=1 loops=1)
--                                 Index Cond: (id = d.home_team_id)
--                                 Buffers: shared hit=4
--                     ->  Index Scan using sport_team_pkey on sport_team at  (cost=0.42..8.44 rows=1 width=50) (actual time=0.012..0.013 rows=1 loops=1)
--                           Index Cond: (id = d.away_team_id)
--                           Buffers: shared hit=4
--         SubPlan 1
--           ->  Aggregate  (cost=627619.16..627619.17 rows=1 width=32) (actual time=2802.800..2802.810 rows=1 loops=1)
--                 Buffers: shared hit=332 read=249872
--                 ->  Sort  (cost=627619.13..627619.14 rows=1 width=23) (actual time=2802.761..2802.769 rows=0 loops=1)
--                       Sort Key: s.time_score
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=332 read=249872
--                       ->  Nested Loop  (cost=1.12..627619.12 rows=1 width=23) (actual time=2802.728..2802.735 rows=0 loops=1)
--                             Join Filter: (tr.player_ssn = p.ssn)
--                             Buffers: shared hit=332 read=249872
--                             ->  Nested Loop  (cost=0.56..627610.55 rows=1 width=36) (actual time=2802.722..2802.726 rows=0 loops=1)
--                                   Buffers: shared hit=332 read=249872
--                                   ->  Seq Scan on new_score s  (cost=0.00..625000.00 rows=569 width=26) (actual time=1202.174..2802.420 rows=51 loops=1)
--                                         Filter: (duel_id = d.id)
--                                         Rows Removed by Filter: 29999949
--                                         Buffers: shared hit=128 read=249872
--                                   ->  Index Only Scan using new_team_roster_pkey on new_team_roster tr  (cost=0.56..4.58 rows=1 width=18) (actual time=0.003..0.003 rows=0 loops=51)
--                                         Index Cond: ((player_ssn = s.player_ssn) AND (team_id = d.home_team_id) AND (duel_id = d.id))
--                                         Heap Fetches: 0
--                                         Buffers: shared hit=204
--                             ->  Index Scan using person_pkey on person p  (cost=0.56..8.56 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = s.player_ssn)
--         SubPlan 2
--           ->  Aggregate  (cost=627619.16..627619.17 rows=1 width=32) (actual time=2655.294..2655.304 rows=1 loops=1)
--                 Buffers: shared hit=620 read=249840
--                 ->  Sort  (cost=627619.13..627619.14 rows=1 width=23) (actual time=2655.131..2655.169 rows=51 loops=1)
--                       Sort Key: s_1.time_score
--                       Sort Method: quicksort  Memory: 26kB
--                       Buffers: shared hit=620 read=249840
--                       ->  Nested Loop  (cost=1.12..627619.12 rows=1 width=23) (actual time=1091.472..2655.086 rows=51 loops=1)
--                             Join Filter: (tr_1.player_ssn = p_1.ssn)
--                             Buffers: shared hit=620 read=249840
--                             ->  Nested Loop  (cost=0.56..627610.55 rows=1 width=36) (actual time=1091.433..2654.731 rows=51 loops=1)
--                                   Buffers: shared hit=365 read=249840
--                                   ->  Seq Scan on new_score s_1  (cost=0.00..625000.00 rows=569 width=26) (actual time=1091.312..2654.304 rows=51 loops=1)
--                                         Filter: (duel_id = d.id)
--                                         Rows Removed by Filter: 29999949
--                                         Buffers: shared hit=160 read=249840
--                                   ->  Index Only Scan using new_team_roster_pkey on new_team_roster tr_1  (cost=0.56..4.58 rows=1 width=18) (actual time=0.004..0.004 rows=1 loops=51)
--                                         Index Cond: ((player_ssn = s_1.player_ssn) AND (team_id = d.away_team_id) AND (duel_id = d.id))
--                                         Heap Fetches: 0
--                                         Buffers: shared hit=205
--                             ->  Index Scan using person_pkey on person p_1  (cost=0.56..8.56 rows=1 width=29) (actual time=0.005..0.005 rows=1 loops=51)
--                                   Index Cond: (ssn = s_1.player_ssn)
--                                   Buffers: shared hit=255
--         SubPlan 3
--           ->  Aggregate  (cost=486932.85..486932.86 rows=1 width=32) (actual time=733.210..733.218 rows=1 loops=1)
--                 Buffers: shared hit=845 read=186071
--                 ->  Nested Loop  (cost=0.71..486932.83 rows=1 width=23) (actual time=733.175..733.180 rows=0 loops=1)
--                       Join Filter: (tr_2.end_time < (((scat.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--                       Buffers: shared hit=845 read=186071
--                       ->  Nested Loop  (cost=0.56..486924.64 rows=1 width=23) (actual time=733.172..733.175 rows=0 loops=1)
--                             Buffers: shared hit=845 read=186071
--                             ->  Seq Scan on new_team_roster tr_2  (cost=0.00..486916.06 rows=1 width=22) (actual time=733.170..733.171 rows=0 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.home_team_id))
--                                   Rows Removed by Filter: 20000003
--                                   Buffers: shared hit=845 read=186071
--                             ->  Index Scan using person_pkey on person p_2  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = tr_2.player_ssn)
--                       ->  Index Scan using sport_category_pkey on sport_category scat  (cost=0.15..8.17 rows=1 width=4) (never executed)
--                             Index Cond: (id = d.sport_category_id)
--                             Filter: (team_capacity > 3)
--         SubPlan 4
--           ->  Aggregate  (cost=486932.85..486932.86 rows=1 width=32) (actual time=648.150..648.159 rows=1 loops=1)
--                 Buffers: shared hit=982 read=186039
--                 ->  Nested Loop  (cost=0.71..486932.83 rows=1 width=23) (actual time=647.727..648.134 rows=2 loops=1)
--                       Join Filter: (tr_3.end_time < (((scat_1.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--                       Rows Removed by Join Filter: 13
--                       Buffers: shared hit=982 read=186039
--                       ->  Nested Loop  (cost=0.56..486924.64 rows=1 width=23) (actual time=647.656..648.020 rows=15 loops=1)
--                             Buffers: shared hit=952 read=186039
--                             ->  Seq Scan on new_team_roster tr_3  (cost=0.00..486916.06 rows=1 width=22) (actual time=647.564..647.804 rows=15 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.away_team_id))
--                                   Rows Removed by Filter: 19999988
--                                   Buffers: shared hit=877 read=186039
--                             ->  Index Scan using person_pkey on person p_3  (cost=0.56..8.58 rows=1 width=29) (actual time=0.009..0.009 rows=1 loops=15)
--                                   Index Cond: (ssn = tr_3.player_ssn)
--                                   Buffers: shared hit=75
--                       ->  Index Scan using sport_category_pkey on sport_category scat_1  (cost=0.15..8.17 rows=1 width=4) (actual time=0.003..0.004 rows=1 loops=15)
--                             Index Cond: (id = d.sport_category_id)
--                             Filter: (team_capacity > 3)
--                             Buffers: shared hit=30
--         SubPlan 5
--           ->  Aggregate  (cost=486924.66..486924.67 rows=1 width=32) (actual time=654.259..654.265 rows=1 loops=1)
--                 Buffers: shared hit=909 read=186007
--                 ->  Sort  (cost=486924.65..486924.65 rows=1 width=15) (actual time=654.224..654.228 rows=0 loops=1)
--                       Sort Key: p_4.last_name
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=909 read=186007
--                       ->  Nested Loop  (cost=0.56..486924.64 rows=1 width=15) (actual time=654.212..654.214 rows=0 loops=1)
--                             Buffers: shared hit=909 read=186007
--                             ->  Seq Scan on new_team_roster tr_4  (cost=0.00..486916.06 rows=1 width=14) (actual time=654.209..654.209 rows=0 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.home_team_id))
--                                   Rows Removed by Filter: 20000003
--                                   Buffers: shared hit=909 read=186007
--                             ->  Index Scan using person_pkey on person p_4  (cost=0.56..8.58 rows=1 width=29) (never executed)
--                                   Index Cond: (ssn = tr_4.player_ssn)
--         SubPlan 6
--           ->  Aggregate  (cost=486924.66..486924.67 rows=1 width=32) (actual time=653.767..653.775 rows=1 loops=1)
--                 Buffers: shared hit=1016 read=185975
--                 ->  Sort  (cost=486924.65..486924.65 rows=1 width=15) (actual time=653.731..653.745 rows=15 loops=1)
--                       Sort Key: p_5.last_name
--                       Sort Method: quicksort  Memory: 25kB
--                       Buffers: shared hit=1016 read=185975
--                       ->  Nested Loop  (cost=0.56..486924.64 rows=1 width=15) (actual time=653.327..653.679 rows=15 loops=1)
--                             Buffers: shared hit=1016 read=185975
--                             ->  Seq Scan on new_team_roster tr_5  (cost=0.00..486916.06 rows=1 width=14) (actual time=653.208..653.445 rows=15 loops=1)
--                                   Filter: ((duel_id = d.id) AND (team_id = d.away_team_id))
--                                   Rows Removed by Filter: 19999988
--                                   Buffers: shared hit=941 read=185975
--                             ->  Index Scan using person_pkey on person p_5  (cost=0.56..8.58 rows=1 width=29) (actual time=0.009..0.009 rows=1 loops=15)
--                                   Index Cond: (ssn = tr_5.player_ssn)
--                                   Buffers: shared hit=75
--         SubPlan 7
--           ->  Aggregate  (cost=614153.16..614153.17 rows=1 width=32) (actual time=2297.008..2297.013 rows=1 loops=1)
--                 Buffers: shared hit=74 read=207222
--                 ->  Nested Loop  (cost=0.56..614153.10 rows=8 width=15) (actual time=1768.362..2296.964 rows=2 loops=1)
--                       Buffers: shared hit=74 read=207222
--                       ->  Seq Scan on new_refereeing_duel rd  (cost=0.00..614084.48 rows=8 width=14) (actual time=1768.263..2296.848 rows=2 loops=1)
--                             Filter: (duel_id = d.id)
--                             Rows Removed by Filter: 32543876
--                             Buffers: shared hit=64 read=207222
--                       ->  Index Scan using person_pkey on person p_6  (cost=0.56..8.58 rows=1 width=29) (actual time=0.027..0.028 rows=1 loops=2)
--                             Index Cond: (ssn = rd.referee_ssn)
--                             Buffers: shared hit=10
-- Planning:
--   Buffers: shared hit=143
-- Planning Time: 2.217 ms
-- JIT:
--   Functions: 256
-- "  Options: Inlining true, Optimization true, Expressions true, Deforming true"
-- "  Timing: Generation 12.431 ms (Deform 4.685 ms), Inlining 194.519 ms, Optimization 769.597 ms, Emission 607.789 ms, Total 1584.336 ms"
-- Execution Time: 11440.701 ms


CREATE OR REPLACE VIEW new_get_red_cards AS
SELECT
    d.id AS duel_id,
    ht.name AS home_team,
    at.name AS away_team,
    d.sport_category_id,
    d.competition_id,
    p.first_name || ' ' || p.last_name AS player_name,
    t.name AS team_name,
    d.duel_date+d.duel_time AS duel_start,
    tr.end_time AS exit_time,
    scat.duration_minutes AS full_duration,
    (scat.duration_minutes - EXTRACT(MINUTE FROM tr.end_time))::int AS minutes_missed
FROM NEW_TEAM_ROSTER tr
JOIN NEW_DUEL d
    ON d.id = tr.duel_id
    AND d.duel_date < CURRENT_DATE
JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
JOIN PERSON p ON p.ssn = tr.player_ssn
JOIN SPORT_TEAM t ON t.id = tr.team_id
JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
JOIN SPORT_TEAM at ON at.id = d.away_team_id
WHERE scat.team_capacity > 3
  AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
ORDER BY d.duel_date DESC, d.duel_time DESC, minutes_missed DESC, d.competition_id;

DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from get_red_cards WHERE duel_id = 4430009;
-- Gather Merge  (cost=406888.79..406889.49 rows=6 width=206) (actual time=2071.146..2077.499 rows=2 loops=1)
--   Workers Planned: 2
--   Workers Launched: 2
--   Buffers: shared hit=1091 read=315695
--   ->  Sort  (cost=405888.77..405888.77 rows=3 width=206) (actual time=2048.013..2048.034 rows=1 loops=3)
-- "        Sort Key: d.start_time DESC, ((((scat.duration_minutes)::numeric - EXTRACT(minute FROM tr.end_time)))::integer) DESC, d.competition_id"
--         Sort Method: quicksort  Memory: 25kB
--         Buffers: shared hit=1091 read=315695
--         Worker 0:  Sort Method: quicksort  Memory: 25kB
--         Worker 1:  Sort Method: quicksort  Memory: 25kB
--         ->  Nested Loop  (cost=12.39..405888.74 rows=3 width=206) (actual time=1815.664..2047.935 rows=1 loops=3)
--               Buffers: shared hit=1055 read=315695
--               ->  Nested Loop  (cost=11.96..405874.56 rows=3 width=143) (actual time=1815.638..2047.903 rows=1 loops=3)
--                     Buffers: shared hit=1051 read=315695
--                     ->  Nested Loop  (cost=11.53..405860.43 rows=3 width=101) (actual time=1815.620..2047.878 rows=1 loops=3)
--                           Buffers: shared hit=1047 read=315695
--                           ->  Nested Loop  (cost=11.11..405835.49 rows=3 width=59) (actual time=1815.595..2047.850 rows=1 loops=3)
--                                 Buffers: shared hit=1038 read=315695
--                                 ->  Hash Join  (cost=10.55..405809.76 rows=3 width=58) (actual time=1815.562..2047.809 rows=1 loops=3)
--                                       Hash Cond: (d.sport_category_id = scat.id)
--                                       Join Filter: (tr.end_time < (((scat.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--                                       Rows Removed by Join Filter: 4
--                                       Buffers: shared hit=1027 read=315695
--                                       ->  Nested Loop  (cost=0.43..405799.55 rows=39 width=54) (actual time=1815.464..2047.710 rows=5 loops=3)
--                                             Buffers: shared hit=1022 read=315695
--                                             ->  Parallel Seq Scan on team_roster tr  (cost=0.00..405469.31 rows=39 width=30) (actual time=1815.419..2047.630 rows=5 loops=3)
--                                                   Filter: (duel_id = 4430009)
--                                                   Rows Removed by Filter: 6666663
--                                                   Buffers: shared hit=961 read=315695
--                                             ->  Index Scan using duel_pkey on duel d  (cost=0.43..8.46 rows=1 width=28) (actual time=0.010..0.011 rows=1 loops=15)
--                                                   Index Cond: (id = 4430009)
--                                                   Filter: (now() > start_time)
--                                                   Buffers: shared hit=61
--                                       ->  Hash  (cost=9.21..9.21 rows=72 width=8) (actual time=0.204..0.208 rows=72 loops=1)
--                                             Buckets: 1024  Batches: 1  Memory Usage: 11kB
--                                             Buffers: shared hit=5
--                                             ->  Seq Scan on sport_category scat  (cost=0.00..9.21 rows=72 width=8) (actual time=0.052..0.134 rows=72 loops=1)
--                                                   Filter: (team_capacity > 3)
--                                                   Rows Removed by Filter: 265
--                                                   Buffers: shared hit=5
--                                 ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=29) (actual time=0.043..0.043 rows=1 loops=2)
--                                       Index Cond: (ssn = tr.player_ssn)
--                                       Buffers: shared hit=11
--                           ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..8.31 rows=1 width=50) (actual time=0.027..0.028 rows=1 loops=2)
--                                 Index Cond: (id = tr.team_id)
--                                 Buffers: shared hit=9
--                     ->  Memoize  (cost=0.43..8.45 rows=1 width=50) (actual time=0.025..0.026 rows=1 loops=2)
--                           Cache Key: d.home_team_id
--                           Cache Mode: logical
--                           Buffers: shared hit=4
--                           Worker 0:  Hits: 1  Misses: 1  Evictions: 0  Overflows: 0  Memory Usage: 1kB
--                           ->  Index Scan using sport_team_pkey on sport_team ht  (cost=0.42..8.44 rows=1 width=50) (actual time=0.028..0.028 rows=1 loops=1)
--                                 Index Cond: (id = d.home_team_id)
--                                 Buffers: shared hit=4
--               ->  Memoize  (cost=0.43..8.45 rows=1 width=50) (actual time=0.028..0.029 rows=1 loops=2)
--                     Cache Key: d.away_team_id
--                     Cache Mode: logical
--                     Buffers: shared hit=4
--                     Worker 0:  Hits: 1  Misses: 1  Evictions: 0  Overflows: 0  Memory Usage: 1kB
--                     ->  Index Scan using sport_team_pkey on sport_team at  (cost=0.42..8.44 rows=1 width=50) (actual time=0.039..0.040 rows=1 loops=1)
--                           Index Cond: (id = d.away_team_id)
--                           Buffers: shared hit=4
-- Planning:
--   Buffers: shared hit=44
-- Planning Time: 1.577 ms
-- JIT:
--   Functions: 153
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 10.236 ms (Deform 3.551 ms), Inlining 0.000 ms, Optimization 3.272 ms, Emission 74.506 ms, Total 88.014 ms"
-- Execution Time: 2081.015 ms


DISCARD ALL;
EXPLAIN (ANALYZE, BUFFERS)
select * from new_get_red_cards WHERE duel_id = 4430009;
-- Subquery Scan on new_get_red_cards  (cost=23451.59..292801.77 rows=69 width=206) (actual time=302.383..307.843 rows=2 loops=1)
--   Buffers: shared hit=914 read=186167
--   ->  Incremental Sort  (cost=23451.59..292801.08 rows=69 width=218) (actual time=302.376..307.830 rows=2 loops=1)
-- "        Sort Key: d.duel_date DESC, d.duel_time DESC, ((((scat.duration_minutes)::numeric - EXTRACT(minute FROM tr.end_time)))::integer) DESC, d.competition_id"
--         Presorted Key: d.duel_date
--         Full-sort Groups: 1  Sort Method: quicksort  Average Memory: 25kB  Peak Memory: 25kB
--         Buffers: shared hit=914 read=186167
--         ->  Nested Loop  (cost=1005.89..292799.13 rows=69 width=218) (actual time=301.707..307.801 rows=2 loops=1)
--               Join Filter: (tr.end_time < (((scat.duration_minutes)::double precision * '00:01:00'::interval))::time without time zone)
--               Rows Removed by Join Filter: 13
--               Buffers: shared hit=914 read=186167
--               ->  Nested Loop  (cost=4.91..178.47 rows=3 width=120) (actual time=24.233..24.380 rows=1 loops=1)
--                     Buffers: shared hit=30
--                     ->  Nested Loop  (cost=4.49..153.15 rows=3 width=78) (actual time=24.212..24.354 rows=1 loops=1)
--                           Buffers: shared hit=26
--                           ->  Nested Loop  (cost=4.07..127.83 rows=3 width=36) (actual time=24.184..24.323 rows=1 loops=1)
--                                 Join Filter: (scat.id = d.sport_category_id)
--                                 Rows Removed by Join Filter: 21
--                                 Buffers: shared hit=22
--                                 ->  Append  (cost=4.07..104.39 rows=13 width=32) (actual time=24.088..24.220 rows=1 loops=1)
--                                       Buffers: shared hit=19
--                                       Subplans Removed: 6
--                                       ->  Index Scan Backward using new_duel_2026_pkey on new_duel_2026 d_6  (cost=0.43..8.45 rows=1 width=32) (actual time=24.053..24.053 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=3
--                                       ->  Index Scan Backward using new_duel_2025_pkey on new_duel_2025 d_5  (cost=0.43..8.45 rows=1 width=32) (actual time=0.031..0.035 rows=1 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=5
--                                       ->  Index Scan Backward using new_duel_2024_pkey on new_duel_2024 d_4  (cost=0.43..8.45 rows=1 width=32) (actual time=0.037..0.038 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=3
--                                       ->  Index Scan Backward using new_duel_2023_pkey on new_duel_2023 d_3  (cost=0.43..8.45 rows=1 width=32) (actual time=0.021..0.022 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=3
--                                       ->  Index Scan Backward using new_duel_2022_pkey on new_duel_2022 d_2  (cost=0.43..8.45 rows=1 width=32) (actual time=0.035..0.036 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=3
--                                       ->  Index Scan Backward using new_duel_2021_pkey on new_duel_2021 d_1  (cost=0.29..8.31 rows=1 width=32) (actual time=0.019..0.019 rows=0 loops=1)
--                                             Index Cond: ((id = 4430009) AND (duel_date < CURRENT_DATE))
--                                             Buffers: shared hit=2
--                                 ->  Materialize  (cost=0.00..9.57 rows=72 width=8) (actual time=0.027..0.075 rows=22 loops=1)
--                                       Buffers: shared hit=3
--                                       ->  Seq Scan on sport_category scat  (cost=0.00..9.21 rows=72 width=8) (actual time=0.023..0.042 rows=22 loops=1)
--                                             Filter: (team_capacity > 3)
--                                             Rows Removed by Filter: 58
--                                             Buffers: shared hit=3
--                           ->  Index Scan using sport_team_pkey on sport_team ht  (cost=0.42..8.44 rows=1 width=50) (actual time=0.018..0.018 rows=1 loops=1)
--                                 Index Cond: (id = d.home_team_id)
--                                 Buffers: shared hit=4
--                     ->  Index Scan using sport_team_pkey on sport_team at  (cost=0.42..8.44 rows=1 width=50) (actual time=0.012..0.013 rows=1 loops=1)
--                           Index Cond: (id = d.away_team_id)
--                           Buffers: shared hit=4
--               ->  Materialize  (cost=1000.98..292614.65 rows=74 width=73) (actual time=277.421..283.375 rows=15 loops=1)
--                     Buffers: shared hit=884 read=186167
--                     ->  Gather  (cost=1000.98..292614.28 rows=74 width=73) (actual time=277.411..283.338 rows=15 loops=1)
--                           Workers Planned: 2
--                           Workers Launched: 2
--                           Buffers: shared hit=884 read=186167
--                           ->  Nested Loop  (cost=0.98..291606.88 rows=31 width=73) (actual time=261.251..261.338 rows=5 loops=3)
--                                 Buffers: shared hit=884 read=186167
--                                 ->  Nested Loop  (cost=0.56..291348.59 rows=31 width=31) (actual time=261.233..261.297 rows=5 loops=3)
--                                       Buffers: shared hit=824 read=186167
--                                       ->  Parallel Seq Scan on new_team_roster tr  (cost=0.00..291082.69 rows=31 width=30) (actual time=261.186..261.193 rows=5 loops=3)
--                                             Filter: (duel_id = 4430009)
--                                             Rows Removed by Filter: 6666663
--                                             Buffers: shared hit=749 read=186167
--                                       ->  Index Scan using person_pkey on person p  (cost=0.56..8.58 rows=1 width=29) (actual time=0.014..0.014 rows=1 loops=15)
--                                             Index Cond: (ssn = tr.player_ssn)
--                                             Buffers: shared hit=75
--                                 ->  Index Scan using sport_team_pkey on sport_team t  (cost=0.42..8.33 rows=1 width=50) (actual time=0.004..0.004 rows=1 loops=15)
--                                       Index Cond: (id = tr.team_id)
--                                       Buffers: shared hit=60
-- Planning:
--   Buffers: shared hit=19
-- Planning Time: 1.515 ms
-- JIT:
--   Functions: 94
-- "  Options: Inlining false, Optimization false, Expressions true, Deforming true"
-- "  Timing: Generation 5.271 ms (Deform 2.124 ms), Inlining 0.000 ms, Optimization 2.280 ms, Emission 43.119 ms, Total 50.671 ms"
-- Execution Time: 312.543 ms

---------------------- PROCEDURES -----------------------------------

CREATE OR REPLACE PROCEDURE new_start_new_season(
    league_id              int4,
    years_from_last_season int4 -- because all seasons for this year are already generated
                                -- and for testing, real use would be 0
)
LANGUAGE plpgsql AS $$
DECLARE
    last_season_id int4;
    new_season_id int4;
    comp_id int4;
    new_season_start_date date;
    new_season_end_date date;
    scat_id int4;
    fed_id int4;
    c_id int4;
    n_d RECORD;
BEGIN
    IF years_from_last_season < 0 OR years_from_last_season > 20 THEN
        RAISE EXCEPTION 'Invalid years_from_last_season – must be in [0, 20]';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM national_league WHERE id = league_id) THEN
        RAISE EXCEPTION 'Invalid league_id – does not exist';
    END IF;

    SELECT nl.sport_category_id, nl.federation_id, nf.country_id
    INTO scat_id, fed_id, c_id
    FROM national_league nl
    JOIN national_federation nf ON nf.id = nl.federation_id
    WHERE nl.id = league_id;

    IF NOT EXISTS (SELECT 1 FROM season WHERE national_league_id = league_id) THEN
        last_season_id := NULL;
        new_season_start_date := (now() + years_from_last_season * INTERVAL '1 year' + INTERVAL '30 days' * random())::date;
        new_season_end_date := (now()  + years_from_last_season * INTERVAL '1 year'  + INTERVAL '1 year' + INTERVAL '30 days' * random())::date;
    ELSE
        SELECT id,
               (end_date + years_from_last_season * INTERVAL '1 year' + INTERVAL '30 days' * random())::date,
               (end_date + years_from_last_season * INTERVAL '1 year' + INTERVAL '1 year'
                         + INTERVAL '30 days' * random())::date
        INTO last_season_id, new_season_start_date, new_season_end_date
        FROM season
        WHERE national_league_id = league_id
        ORDER BY end_date DESC
        LIMIT 1;
    END IF;

    INSERT INTO season (national_league_id, start_date, end_date)
    VALUES (league_id, new_season_start_date, new_season_end_date)
    RETURNING id INTO new_season_id;

    INSERT INTO season_sport_team (season_id, sport_team_id)
    SELECT new_season_id, st.id
    FROM (
        SELECT DISTINCT ON (st.id)
               st.id,
               row_number() OVER (ORDER BY random()) AS i
        FROM sport_team st
        JOIN sport_club sc  ON sc.id = st.club_id
        JOIN club_federation cf ON cf.club_id = sc.id
            AND cf.federation_id = fed_id
            AND cf.start_date < new_season_start_date
            AND (cf.end_date IS NULL
            OR cf.end_date > new_season_start_date)
        WHERE sc.country_id = c_id
            AND st.sport_category_id = scat_id
            AND NOT sc.is_national_representation
    ) st
    WHERE st.i <= 20;

    INSERT INTO competition (type, organizer_federation_id, season_id,
                             name, start_date, end_date)
    SELECT 1, fed_id, new_season_id,
           nl.name, new_season_start_date, new_season_end_date
    FROM   national_league nl
    WHERE  nl.id = league_id
    ON CONFLICT DO NOTHING
    RETURNING id INTO comp_id;

    IF comp_id IS NULL THEN
        SELECT id INTO comp_id
        FROM competition
        WHERE season_id = new_season_id
        LIMIT 1;
    END IF;

    COMMIT;

    CREATE TEMP TABLE created_duels (
        home_team_id INT4 NOT NULL,
        away_team_id INT4 NOT NULL,
        location_id INT4 NOT NULL,
        competition_id INT4,
        start_time TIMESTAMP NOT NULL,
        sport_category_id INT4 NOT NULL
    ) ON COMMIT DROP;

    WITH score_logic (sport_id, multiplier, offset_val) AS (
        VALUES
            (1,5,0),(9,11,0),(11,11,0),(16,11,0),(17,11,0),
            (19,5,0),(20,11,0),(25,11,0),(34,11,0),(40,11,0),
            (2,71,50),(3,21,15),
            (4,4,0),(5,4,0),(27,4,0),(28,4,0),(29,4,0),(39,4,0),
            (6,2,0),(14,2,0),(15,2,0),(22,2,0),(23,2,0),(26,2,0),
            (31,2,0),(32,2,0),(33,2,0),
            (7,13,0),(8,61,0),(10,15,1),(12,401,100),(13,21,60),
            (18,9,0),(21,151,0),(24,141,60),(30,16,5),(35,21,0),
            (36,16,0),(37,21,5),(38,16,0)
    ),
    teams AS (
        SELECT
            sst.sport_team_id AS tid,
            row_number() OVER (ORDER BY sst.sport_team_id) - 1 AS idx,
            count(*) OVER () AS total
        FROM season_sport_team sst
        WHERE sst.season_id = new_season_id
    ),
    team_count AS (
        SELECT CASE WHEN max(total) % 2 = 0 THEN max(total)
                    ELSE max(total) + 1
               END AS n
        FROM teams
    ),
    rounds AS (
        SELECT gs.round_num,
               tc.n
        FROM team_count tc
        CROSS JOIN generate_series(1, (tc.n - 1) * 2) AS gs(round_num)
    ),
    slots AS (
        SELECT r.round_num,
               r.n,
               s.slot_i
        FROM rounds r
        CROSS JOIN generate_series(0, r.n / 2 - 1) AS s(slot_i)
    ),
    pairings AS (
        SELECT sl.round_num,
               sl.n,
               sl.slot_i,
               CASE WHEN sl.slot_i = 0
                    THEN sl.n - 1
                    ELSE ((sl.slot_i - 1 + (sl.round_num - 1) % (sl.n - 1)) % (sl.n - 1))
               END AS a_idx,
               CASE WHEN sl.slot_i = 0
                    THEN (sl.round_num - 1) % (sl.n - 1)
                    ELSE ((sl.n - 1 - sl.slot_i + (sl.round_num - 1) % (sl.n - 1)) % (sl.n - 1))
               END AS b_idx
        FROM slots sl
    ),
    resolved AS (
        SELECT p.round_num,
               CASE WHEN p.round_num <= (p.n - 1)
                    THEN ta.tid ELSE tb.tid
               END AS home_id,
               CASE WHEN p.round_num <= (p.n - 1)
                    THEN tb.tid ELSE ta.tid
               END AS away_id,
               row_number() OVER (PARTITION BY p.round_num ORDER BY p.slot_i) AS match_num
        FROM pairings p
        JOIN teams ta ON ta.idx = p.a_idx
        JOIN teams tb ON tb.idx = p.b_idx
        WHERE ta.tid <> tb.tid
    )
    INSERT INTO created_duels (
        home_team_id, away_team_id, location_id, competition_id,
        start_time, sport_category_id
    )
    SELECT r.home_id,
           r.away_id,
           (SELECT l.id
            FROM location l
            JOIN sport_team st ON st.id  = r.home_id
            JOIN sport_club sc ON sc.id  = st.club_id
            WHERE l.country_id = sc.country_id
            ORDER BY random()
            LIMIT 1)
               AS location_id,
           comp_id,
           new_season_start_date + ((r.round_num  - 1) * INTERVAL '7 days') + ((r.match_num  - 1) * INTERVAL '1 day')
               + CASE WHEN r.match_num % 2 = 0
                      THEN INTERVAL '18 hours'
                      ELSE INTERVAL '12 hours'
                 END AS start_time,
           scat_id
    FROM resolved r
    LEFT JOIN score_logic sl ON sl.sport_id = (
               SELECT sc.sport_id FROM sport_category sc WHERE sc.id = scat_id);

    FOR n_d IN (SELECT * FROM created_duels) LOOP
        BEGIN
            INSERT INTO new_duel (
                home_team_id, away_team_id, location_id, competition_id,
                duel_date, duel_time, sport_category_id, home_team_score, away_team_score
            )
            VALUES (
                n_d.home_team_id, n_d.away_team_id, n_d.location_id, n_d.competition_id,
                n_d.start_time::date, n_d.start_time::time,
                    n_d.sport_category_id, NULL, NULL
                )
            ;
        EXCEPTION WHEN OTHERS THEN
            RAISE NOTICE 'Inserting duel failed with values (%, %, %, %, %, %)',
                n_d.home_team_id, n_d.away_team_id, n_d.location_id,
                n_d.competition_id, n_d.start_time, n_d.sport_category_id
            ;
        END;
    END LOOP;

    COMMIT;
END;
$$;

CALL new_start_new_season(2279810, 1); -- okay

CREATE OR REPLACE PROCEDURE new_reschedule_duel(
    d_id int4,
    new_ts timestamp
)
LANGUAGE plpgsql AS $$
DECLARE
    ht_id int4;
    at_id int4;
    scat_id int4;
    ref_ssn char(13);
    old_start timestamp;
    new_end timestamp;
    scat_mins int4;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM new_duel WHERE id = d_id)
        THEN RAISE EXCEPTION 'Invalid d_id – duel does not exist';
    END IF;

    SELECT d.home_team_id, d.away_team_id, d.sport_category_id, d.duel_date+d.duel_time, scat.duration_minutes
    INTO ht_id, at_id, scat_id, old_start, scat_mins
    FROM new_duel d
    JOIN sport_category scat ON scat.id = d.sport_category_id
    WHERE d.id = d_id;

    IF old_start < now() THEN
        RAISE EXCEPTION 'Cannot reschedule past duels';
    END IF;

    IF new_ts < now() THEN
        RAISE EXCEPTION 'Cannot reschedule duels in past';
    END IF;

    new_end := new_ts + scat_mins * INTERVAL '1 minute';

    ref_ssn := NULL;
    SELECT referee_ssn INTO ref_ssn FROM refereeing_duel WHERE duel_id = d_id LIMIT 1;

    IF ref_ssn IS NOT NULL THEN
        IF EXISTS (SELECT 1
                   FROM refereeing_duel rd
                            JOIN new_duel d2 ON d2.id = rd.duel_id
                   WHERE rd.referee_ssn = ref_ssn
                     AND rd.duel_id != d_id
                     AND (
                       (new_ts BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                       OR
                       (new_end BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                     )
                   )
            THEN RAISE EXCEPTION 'Referee % has another duel scheduled at %', ref_ssn, new_ts;
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM new_duel d2
               WHERE (d2.home_team_id = ht_id OR d2.away_team_id = ht_id)
                 AND d2.id != d_id
                 AND (
                       (new_ts BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                       OR
                       (new_end BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                     )
               )
        THEN RAISE EXCEPTION 'Home team has another duel scheduled at %', new_ts;
    END IF;

    IF EXISTS (SELECT 1 FROM new_duel d2
               WHERE (d2.home_team_id = at_id OR d2.away_team_id = at_id)
                 AND d2.id != d_id
                 AND (
                       (new_ts BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                       OR
                       (new_end BETWEEN
                           (d2.duel_date + d2.duel_time) AND
                           (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                       )
                     )
               )
        THEN RAISE EXCEPTION 'Away team has another duel scheduled at %', new_ts;
    END IF;

    UPDATE new_duel
    SET duel_date = new_ts::date,
        duel_time = new_ts::time
    WHERE id = d_id;

    RAISE NOTICE 'Duel % rescheduled to %', d_id, new_ts;
END;
$$;

CALL new_reschedule_duel(57385, '2026-06-14 14:00:00'::timestamp );


CREATE OR REPLACE PROCEDURE new_assign_referee_for_duel(
    d_id int4
)
LANGUAGE plpgsql AS $$
DECLARE
    ref_ssn char(13);
    scat_id int4;
    scat_mins int4;
    duel_start timestamp;
    duel_end timestamp;
    comp_id int4;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM new_duel WHERE id = d_id)
        THEN RAISE EXCEPTION 'Invalid d_id – duel does not exist';
    END IF;

    SELECT d.sport_category_id, d.duel_date+d.duel_time, scat.duration_minutes, d.competition_id
    INTO scat_id, duel_start, scat_mins, comp_id
    FROM new_duel d
    JOIN sport_category scat ON scat.id = d.sport_category_id
    WHERE d.id = d_id;

    duel_end := duel_start + scat_mins * INTERVAL '1 minute';

    IF comp_id IS NULL THEN
        SELECT r.ssn INTO ref_ssn
        FROM referee r
        WHERE r.sport_category_id = scat_id
          AND NOT EXISTS (
              SELECT 1 FROM new_refereeing_duel rd
              JOIN new_duel d2 ON d2.id = rd.duel_id
              WHERE rd.referee_ssn = r.ssn
                AND d2.id != d_id
                AND (
                   (duel_start BETWEEN
                       (d2.duel_date + d2.duel_time) AND
                       (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                   )
                   OR
                   (duel_end BETWEEN
                       (d2.duel_date + d2.duel_time) AND
                       (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                   )
                 )
          )
        ORDER BY random()
        LIMIT 1;
    ELSE
        SELECT r.ssn INTO ref_ssn
        FROM referee r
        JOIN competition c ON c.id = comp_id
        JOIN season s ON s.id = c.season_id
        JOIN national_league nl ON nl.id = s.national_league_id
        WHERE r.sport_category_id = scat_id
          AND r.federation_id = nl.federation_id
          AND NOT EXISTS (
              SELECT 1 FROM new_refereeing_duel rd
              JOIN new_duel d2 ON d2.id = rd.duel_id
              WHERE rd.referee_ssn = r.ssn
                AND d2.id != d_id
                AND (
                   (duel_start BETWEEN
                       (d2.duel_date + d2.duel_time) AND
                       (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                   )
                   OR
                   (duel_end BETWEEN
                       (d2.duel_date + d2.duel_time) AND
                       (d2.duel_date + duel_time + scat_mins * INTERVAL '1 minute')
                   )
                 )
          )
        ORDER BY random()
        LIMIT 1;
    END IF;

    IF ref_ssn IS NULL THEN
        RAISE EXCEPTION 'No referee found for duel %', d_id;
    END IF;

    INSERT INTO new_refereeing_duel VALUES (ref_ssn, d_id, duel_start::date);
END;
$$;

CALL new_assign_referee_for_duel(4903); -- okay

