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

