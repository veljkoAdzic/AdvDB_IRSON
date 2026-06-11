CREATE TABLE NEW_DUEL (
    id                int4 NOT NULL,
    daily_match_no    int4 NOT NULL,
    duel_date         date NOT NULL,
    home_team_id      int4 NOT NULL,
    away_team_id      int4 NOT NULL,
    location_id       int4 NOT NULL,
    competition_id    int4,
    duel_time         time NOT NULL,
    sport_category_id int4 NOT NULL,
    home_team_score int4,
    away_team_score int4,
    PRIMARY KEY (daily_match_no, duel_date)
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


INSERT INTO NEW_DUEL (id, daily_match_no, duel_date, home_team_id, away_team_id, location_id, competition_id, duel_time, sport_category_id, home_team_score, away_team_score)
SELECT
    d.id,
    ROW_NUMBER() OVER (PARTITION BY d.start_time::date ORDER BY d.start_time) as daily_match_no,
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


CREATE TABLE NEW_TEAM_ROSTER (
    player_ssn char(13) NOT NULL,
    team_id    int4 NOT NULL,
    daily_match_no int4 NOT NULL,
    duel_date  date NOT NULL,
    start_time time NOT NULL,
    end_time   time
);


CREATE TABLE NEW_REFEREEING_DUEL (
    referee_ssn char(13) NOT NULL,
    daily_match_no int4 NOT NULL,
    duel_date   date NOT NULL
);


CREATE TABLE NEW_SCORE (
    id          int4 NOT NULL,
    daily_match_no int4 NOT NULL,
    duel_date   date NOT NULL,
    player_ssn  char(13) NOT NULL,
    time_score  time NOT NULL
);


INSERT INTO NEW_TEAM_ROSTER (player_ssn, team_id, daily_match_no, duel_date, start_time, end_time)
SELECT
    tr.player_ssn,
    tr.team_id,
    nd.daily_match_no,
    nd.duel_date,
    tr.start_time,
    tr.end_time
FROM team_roster tr
JOIN duel d ON tr.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.daily_match_no;


INSERT INTO NEW_REFEREEING_DUEL (referee_ssn, daily_match_no, duel_date)
SELECT
    rd.referee_ssn,
    nd.daily_match_no,
    nd.duel_date
FROM refereeing_duel rd
JOIN duel d ON rd.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.daily_match_no;


INSERT INTO NEW_SCORE (id, daily_match_no, duel_date, player_ssn, time_score)
SELECT
    s.id,
    nd.daily_match_no,
    nd.duel_date,
    s.player_ssn,
    s.time_score
FROM score s
JOIN duel d ON s.duel_id = d.id
JOIN NEW_DUEL nd ON nd.id = d.id
ORDER BY nd.duel_date, nd.daily_match_no;


ALTER TABLE NEW_DUEL
ADD CONSTRAINT nd_competition_fk FOREIGN KEY (competition_id) REFERENCES COMPETITION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_home_team_fk FOREIGN KEY (home_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_away_team_fk FOREIGN KEY (away_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_location_fk FOREIGN KEY (location_id) REFERENCES LOCATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nd_different_teams_c CHECK (home_team_id != away_team_id);


ALTER TABLE NEW_TEAM_ROSTER
ADD PRIMARY KEY (player_ssn, team_id, daily_match_no, duel_date),
ADD CONSTRAINT ntr_roster_date_check CHECK (end_time IS NULL OR start_time < end_time),
ADD CONSTRAINT ntr_sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ntr_duel_fk FOREIGN KEY (daily_match_no, duel_date) REFERENCES NEW_DUEL (daily_match_no, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_REFEREEING_DUEL
ADD PRIMARY KEY (referee_ssn, daily_match_no, duel_date),
ADD CONSTRAINT nrd_nd_fk FOREIGN KEY (daily_match_no, duel_date) REFERENCES NEW_DUEL (daily_match_no, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT nrd_referee_fk FOREIGN KEY (referee_ssn) REFERENCES REFEREE (ssn) ON DELETE RESTRICT ON UPDATE CASCADE;


ALTER TABLE NEW_SCORE
ADD PRIMARY KEY (id),
ADD CONSTRAINT ns_player_ssn FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
ADD CONSTRAINT ns_duel_fk FOREIGN KEY (daily_match_no, duel_date) REFERENCES NEW_DUEL (daily_match_no, duel_date) ON DELETE RESTRICT ON UPDATE CASCADE;


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

DROP INDEX duel_upcoming_indexes;

DISCARD ALL;

--indeksot e dropnat
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

/*
 Gather Merge  (cost=98951.25..99687.79 rows=6324 width=209) (actual time=6933.130..6957.730 rows=1066.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=779811 read=722709
  ->  Sort  (cost=97951.23..97957.82 rows=2635 width=209) (actual time=6877.594..6877.653 rows=355.33 loops=3)
"        Sort Key: ((d.start_time)::date), ((d.start_time)::time without time zone), l.capacity DESC"
        Sort Method: quicksort  Memory: 76kB
        Buffers: shared hit=779811 read=722709
        Worker 0:  Sort Method: quicksort  Memory: 133kB
        Worker 1:  Sort Method: quicksort  Memory: 129kB
        ->  Nested Loop Left Join  (cost=1580.50..97801.51 rows=2635 width=209) (actual time=4.698..6875.881 rows=355.33 loops=3)
              Buffers: shared hit=779764 read=722708
              ->  Hash Join  (cost=1580.08..96542.07 rows=2635 width=158) (actual time=4.503..6867.028 rows=355.33 loops=3)
                    Hash Cond: (d.sport_category_id = scat.id)
                    Buffers: shared hit=776560 read=721646
                    ->  Nested Loop  (cost=1567.50..96522.48 rows=2635 width=134) (actual time=3.611..6865.521 rows=355.33 loops=3)
                          Buffers: shared hit=776508 read=721643
                          ->  Nested Loop  (cost=1567.08..95232.96 rows=2635 width=95) (actual time=3.589..6858.608 rows=355.33 loops=3)
                                Buffers: shared hit=772826 read=721061
                                ->  Hash Join  (cost=1566.65..93943.44 rows=2635 width=56) (actual time=3.376..6849.480 rows=355.33 loops=3)
                                      Hash Cond: (d.location_id = l.id)
                                      Buffers: shared hit=769108 read=720513
                                      ->  Parallel Index Scan using idx_duel_start_time on duel d  (cost=0.44..91535.51 rows=217428 width=28) (actual time=0.664..6834.720 rows=62623.33 loops=3)
                                            Index Cond: (start_time > now())
                                            Filter: ((start_time)::date <= (CURRENT_DATE + 7))
                                            Rows Removed by Filter: 465586
                                            Index Searches: 1
                                            Buffers: shared hit=768344 read=720513
                                      ->  Hash  (cost=1549.87..1549.87 rows=1308 width=36) (actual time=0.492..0.496 rows=340.00 loops=3)
                                            Buckets: 2048  Batches: 1  Memory Usage: 42kB
                                            Buffers: shared hit=764
                                            ->  Nested Loop  (cost=0.42..1549.87 rows=1308 width=36) (actual time=0.284..0.430 rows=340.00 loops=3)
                                                  Buffers: shared hit=764
                                                  ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.247..0.253 rows=1.00 loops=3)
                                                        Filter: ((name)::text ~~ '%Macedonia'::text)
                                                        Rows Removed by Filter: 164
                                                        Buffers: shared hit=3
                                                  ->  Index Scan using unique_name_per_country on location l  (cost=0.42..766.86 rows=654 width=32) (actual time=0.033..0.132 rows=340.00 loops=3)
                                                        Index Cond: (country_id = c.id)
                                                        Index Searches: 3
                                                        Buffers: shared hit=761
                                ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.49 rows=1 width=47) (actual time=0.018..0.018 rows=1.00 loops=1066)
                                      Index Cond: (id = d.home_team_id)
                                      Index Searches: 1066
                                      Buffers: shared hit=3718 read=548
                          ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.49 rows=1 width=47) (actual time=0.016..0.016 rows=1.00 loops=1066)
                                Index Cond: (id = d.away_team_id)
                                Index Searches: 1066
                                Buffers: shared hit=3682 read=582
                    ->  Hash  (cost=8.37..8.37 rows=337 width=32) (actual time=0.879..0.880 rows=337.00 loops=3)
                          Buckets: 1024  Batches: 1  Memory Usage: 30kB
                          Buffers: shared hit=52 read=3
                          ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=32) (actual time=0.736..0.801 rows=337.00 loops=3)
                                Buffers: shared hit=52 read=3
              ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.47 rows=1 width=51) (actual time=0.023..0.023 rows=1.00 loops=1066)
                    Index Cond: (id = d.competition_id)
                    Index Searches: 1066
                    Buffers: shared hit=3204 read=1062
Planning:
  Buffers: shared hit=38 read=31
Planning Time: 4.449 ms
Execution Time: 6958.071 ms
 */

DISCARD ALL;

EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM new_upcoming_duels
WHERE match_date <= CURRENT_DATE + 7
    AND country LIKE '%Macedonia'
ORDER BY match_date, kickoff, capacity DESC;

/*
 Gather Merge  (cost=406224.46..407479.15 rows=10773 width=209) (actual time=381.932..387.896 rows=1066.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=12694 read=33550
  ->  Sort  (cost=405224.44..405235.66 rows=4489 width=209) (actual time=319.972..320.006 rows=355.33 loops=3)
"        Sort Key: nd.duel_date, nd.duel_time, l.capacity DESC"
        Sort Method: quicksort  Memory: 69kB
        Buffers: shared hit=12694 read=33550
        Worker 0:  Sort Method: quicksort  Memory: 133kB
        Worker 1:  Sort Method: quicksort  Memory: 136kB
        ->  Nested Loop Left Join  (cost=1580.07..404952.13 rows=4489 width=209) (actual time=153.924..318.952 rows=355.33 loops=3)
              Buffers: shared hit=12649 read=33547
              ->  Hash Join  (cost=1579.64..402890.07 rows=4489 width=162) (actual time=153.383..314.635 rows=355.33 loops=3)
                    Hash Cond: (nd.sport_category_id = scat.id)
                    Buffers: shared hit=8799 read=33131
                    ->  Nested Loop  (cost=1567.06..402865.56 rows=4489 width=138) (actual time=152.874..313.932 rows=355.33 loops=3)
                          Buffers: shared hit=8789 read=33126
                          ->  Nested Loop  (cost=1566.64..400760.25 rows=4489 width=99) (actual time=152.720..310.723 rows=355.33 loops=3)
                                Buffers: shared hit=4780 read=32871
                                ->  Hash Join  (cost=1566.22..398654.94 rows=4489 width=60) (actual time=152.250..307.110 rows=355.33 loops=3)
                                      Hash Cond: (nd.location_id = l.id)
                                      Buffers: shared hit=755 read=32630
                                      ->  Parallel Append  (cost=0.00..395655.14 rows=370319 width=32) (actual time=150.579..300.135 rows=62623.33 loops=3)
                                            Buffers: shared read=32621
                                            Subplans Removed: 5
                                            ->  Parallel Seq Scan on new_duel_2026 nd_1  (cost=0.00..78766.04 rows=367362 width=32) (actual time=150.576..295.441 rows=62623.33 loops=3)
                                                  Filter: ((duel_date <= (CURRENT_DATE + 7)) AND ((duel_date > CURRENT_DATE) OR ((duel_date = CURRENT_DATE) AND ((duel_time)::time with time zone > CURRENT_TIME))))
                                                  Rows Removed by Filter: 992120
                                                  Buffers: shared read=32621
                                      ->  Hash  (cost=1549.87..1549.87 rows=1308 width=36) (actual time=1.504..1.506 rows=340.00 loops=3)
                                            Buckets: 2048  Batches: 1  Memory Usage: 42kB
                                            Buffers: shared hit=755 read=9
                                            ->  Nested Loop  (cost=0.42..1549.87 rows=1308 width=36) (actual time=1.108..1.401 rows=340.00 loops=3)
                                                  Buffers: shared hit=755 read=9
                                                  ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.570..0.580 rows=1.00 loops=3)
                                                        Filter: ((name)::text ~~ '%Macedonia'::text)
                                                        Rows Removed by Filter: 164
                                                        Buffers: shared hit=3
                                                  ->  Index Scan using unique_name_per_country on location l  (cost=0.42..766.86 rows=654 width=32) (actual time=0.532..0.752 rows=340.00 loops=3)
                                                        Index Cond: (country_id = c.id)
                                                        Index Searches: 3
                                                        Buffers: shared hit=752 read=9
                                ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.47 rows=1 width=47) (actual time=0.009..0.009 rows=1.00 loops=1066)
                                      Index Cond: (id = nd.home_team_id)
                                      Index Searches: 1066
                                      Buffers: shared hit=4025 read=241
                          ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.47 rows=1 width=47) (actual time=0.008..0.008 rows=1.00 loops=1066)
                                Index Cond: (id = nd.away_team_id)
                                Index Searches: 1066
                                Buffers: shared hit=4009 read=255
                    ->  Hash  (cost=8.37..8.37 rows=337 width=32) (actual time=0.497..0.497 rows=337.00 loops=3)
                          Buckets: 1024  Batches: 1  Memory Usage: 30kB
                          Buffers: shared hit=10 read=5
                          ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=32) (actual time=0.356..0.440 rows=337.00 loops=3)
                                Buffers: shared hit=10 read=5
              ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.46 rows=1 width=51) (actual time=0.011..0.011 rows=1.00 loops=1066)
                    Index Cond: (id = nd.competition_id)
                    Index Searches: 1066
                    Buffers: shared hit=3850 read=416
Planning:
  Buffers: shared hit=4 read=8
Planning Time: 2.383 ms
Execution Time: 388.151 ms
 */

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

/*
 Gather Merge  (cost=70085.65..70821.95 rows=6322 width=209) (actual time=165.653..171.818 rows=1066.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=22474 read=745
  ->  Sort  (cost=69085.62..69092.21 rows=2634 width=209) (actual time=119.400..119.438 rows=355.33 loops=3)
"        Sort Key: ((d.start_time)::date), ((d.start_time)::time without time zone), l.capacity DESC"
        Sort Method: quicksort  Memory: 159kB
        Buffers: shared hit=22474 read=745
        Worker 0:  Sort Method: quicksort  Memory: 90kB
        Worker 1:  Sort Method: quicksort  Memory: 89kB
        ->  Nested Loop Left Join  (cost=1580.63..68935.97 rows=2634 width=209) (actual time=2.081..118.640 rows=355.33 loops=3)
              Buffers: shared hit=22426 read=745
              ->  Hash Join  (cost=1580.21..67676.96 rows=2634 width=158) (actual time=2.054..116.126 rows=355.33 loops=3)
                    Hash Cond: (d.sport_category_id = scat.id)
                    Buffers: shared hit=18160 read=745
                    ->  Nested Loop  (cost=1567.62..67657.37 rows=2634 width=134) (actual time=1.547..115.321 rows=355.33 loops=3)
                          Buffers: shared hit=18105 read=745
                          ->  Nested Loop  (cost=1567.20..66368.27 rows=2634 width=95) (actual time=1.526..113.189 rows=355.33 loops=3)
                                Buffers: shared hit=13841 read=745
                                ->  Hash Join  (cost=1566.78..65079.17 rows=2634 width=56) (actual time=1.438..110.678 rows=355.33 loops=3)
                                      Hash Cond: (d.location_id = l.id)
                                      Buffers: shared hit=9575 read=745
                                      ->  Parallel Index Only Scan using duel_upcoming_indexes on duel d  (cost=0.56..62671.71 rows=217309 width=28) (actual time=0.577..103.221 rows=62623.33 loops=3)
                                            Index Cond: (start_time > now())
                                            Filter: ((start_time)::date <= (CURRENT_DATE + 7))
                                            Rows Removed by Filter: 465586
                                            Heap Fetches: 65
                                            Index Searches: 1
                                            Buffers: shared hit=8811 read=745
                                      ->  Hash  (cost=1549.87..1549.87 rows=1308 width=36) (actual time=0.628..0.629 rows=340.00 loops=3)
                                            Buckets: 2048  Batches: 1  Memory Usage: 42kB
                                            Buffers: shared hit=764
                                            ->  Nested Loop  (cost=0.42..1549.87 rows=1308 width=36) (actual time=0.346..0.548 rows=340.00 loops=3)
                                                  Buffers: shared hit=764
                                                  ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.298..0.305 rows=1.00 loops=3)
                                                        Filter: ((name)::text ~~ '%Macedonia'::text)
                                                        Rows Removed by Filter: 164
                                                        Buffers: shared hit=3
                                                  ->  Index Scan using unique_name_per_country on location l  (cost=0.42..766.86 rows=654 width=32) (actual time=0.044..0.178 rows=340.00 loops=3)
                                                        Index Cond: (country_id = c.id)
                                                        Index Searches: 3
                                                        Buffers: shared hit=761
                                ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.49 rows=1 width=47) (actual time=0.006..0.006 rows=1.00 loops=1066)
                                      Index Cond: (id = d.home_team_id)
                                      Index Searches: 1066
                                      Buffers: shared hit=4266
                          ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.49 rows=1 width=47) (actual time=0.005..0.005 rows=1.00 loops=1066)
                                Index Cond: (id = d.away_team_id)
                                Index Searches: 1066
                                Buffers: shared hit=4264
                    ->  Hash  (cost=8.37..8.37 rows=337 width=32) (actual time=0.497..0.497 rows=337.00 loops=3)
                          Buckets: 1024  Batches: 1  Memory Usage: 30kB
                          Buffers: shared hit=55
                          ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=32) (actual time=0.369..0.427 rows=337.00 loops=3)
                                Buffers: shared hit=55
              ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.47 rows=1 width=51) (actual time=0.006..0.006 rows=1.00 loops=1066)
                    Index Cond: (id = d.competition_id)
                    Index Searches: 1066
                    Buffers: shared hit=4266
Planning:
  Buffers: shared hit=51 read=18
Planning Time: 4.352 ms
Execution Time: 172.446 ms
 */


CREATE INDEX IF NOT EXISTS new_duel_upcoming_indexes ON
    new_duel(
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

/*
 Gather Merge  (cost=406224.46..407479.15 rows=10773 width=209) (actual time=339.093..364.434 rows=1066.00 loops=1)
  Workers Planned: 2
  Workers Launched: 2
  Buffers: shared hit=14187 read=32057
  ->  Sort  (cost=405224.44..405235.66 rows=4489 width=209) (actual time=288.284..288.316 rows=355.33 loops=3)
"        Sort Key: nd.duel_date, nd.duel_time, l.capacity DESC"
        Sort Method: quicksort  Memory: 79kB
        Buffers: shared hit=14187 read=32057
        Worker 0:  Sort Method: quicksort  Memory: 130kB
        Worker 1:  Sort Method: quicksort  Memory: 129kB
        ->  Nested Loop Left Join  (cost=1580.07..404952.13 rows=4489 width=209) (actual time=161.930..287.678 rows=355.33 loops=3)
              Buffers: shared hit=14139 read=32057
              ->  Hash Join  (cost=1579.64..402890.07 rows=4489 width=162) (actual time=161.899..285.220 rows=355.33 loops=3)
                    Hash Cond: (nd.sport_category_id = scat.id)
                    Buffers: shared hit=9873 read=32057
                    ->  Nested Loop  (cost=1567.06..402865.56 rows=4489 width=138) (actual time=160.973..284.060 rows=355.33 loops=3)
                          Buffers: shared hit=9858 read=32057
                          ->  Nested Loop  (cost=1566.64..400760.25 rows=4489 width=99) (actual time=160.949..281.792 rows=355.33 loops=3)
                                Buffers: shared hit=5594 read=32057
                                ->  Hash Join  (cost=1566.22..398654.94 rows=4489 width=60) (actual time=160.909..279.251 rows=355.33 loops=3)
                                      Hash Cond: (nd.location_id = l.id)
                                      Buffers: shared hit=1328 read=32057
                                      ->  Parallel Append  (cost=0.00..395655.14 rows=370319 width=32) (actual time=159.520..271.531 rows=62623.33 loops=3)
                                            Buffers: shared hit=564 read=32057
                                            Subplans Removed: 5
                                            ->  Parallel Seq Scan on new_duel_2026 nd_1  (cost=0.00..78766.04 rows=367362 width=32) (actual time=159.517..265.460 rows=62623.33 loops=3)
                                                  Filter: ((duel_date <= (CURRENT_DATE + 7)) AND ((duel_date > CURRENT_DATE) OR ((duel_date = CURRENT_DATE) AND ((duel_time)::time with time zone > CURRENT_TIME))))
                                                  Rows Removed by Filter: 992120
                                                  Buffers: shared hit=564 read=32057
                                      ->  Hash  (cost=1549.87..1549.87 rows=1308 width=36) (actual time=1.140..1.142 rows=340.00 loops=3)
                                            Buckets: 2048  Batches: 1  Memory Usage: 42kB
                                            Buffers: shared hit=764
                                            ->  Nested Loop  (cost=0.42..1549.87 rows=1308 width=36) (actual time=0.774..1.028 rows=340.00 loops=3)
                                                  Buffers: shared hit=764
                                                  ->  Seq Scan on country c  (cost=0.00..3.06 rows=2 width=12) (actual time=0.714..0.724 rows=1.00 loops=3)
                                                        Filter: ((name)::text ~~ '%Macedonia'::text)
                                                        Rows Removed by Filter: 164
                                                        Buffers: shared hit=3
                                                  ->  Index Scan using unique_name_per_country on location l  (cost=0.42..766.86 rows=654 width=32) (actual time=0.054..0.227 rows=340.00 loops=3)
                                                        Index Cond: (country_id = c.id)
                                                        Index Searches: 3
                                                        Buffers: shared hit=761
                                ->  Index Scan using sport_team_pkey on sport_team home  (cost=0.42..0.47 rows=1 width=47) (actual time=0.006..0.006 rows=1.00 loops=1066)
                                      Index Cond: (id = nd.home_team_id)
                                      Index Searches: 1066
                                      Buffers: shared hit=4266
                          ->  Index Scan using sport_team_pkey on sport_team away  (cost=0.42..0.47 rows=1 width=47) (actual time=0.005..0.005 rows=1.00 loops=1066)
                                Index Cond: (id = nd.away_team_id)
                                Index Searches: 1066
                                Buffers: shared hit=4264
                    ->  Hash  (cost=8.37..8.37 rows=337 width=32) (actual time=0.910..0.910 rows=337.00 loops=3)
                          Buckets: 1024  Batches: 1  Memory Usage: 30kB
                          Buffers: shared hit=15
                          ->  Seq Scan on sport_category scat  (cost=0.00..8.37 rows=337 width=32) (actual time=0.743..0.816 rows=337.00 loops=3)
                                Buffers: shared hit=15
              ->  Index Scan using competition_pkey on competition com  (cost=0.42..0.46 rows=1 width=51) (actual time=0.006..0.006 rows=1.00 loops=1066)
                    Index Cond: (id = nd.competition_id)
                    Index Searches: 1066
                    Buffers: shared hit=4266
Planning:
  Buffers: shared hit=12
Planning Time: 4.553 ms
Execution Time: 364.786 ms
 */
