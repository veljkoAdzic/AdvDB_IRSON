-- CREATE OR REPLACE VIEW season_team_standings AS
-- WITH duel_results AS (
--     SELECT
--         d.id AS duel_id,
--         c.season_id AS season_id,
--         d.home_team_id,
--         d.away_team_id,
--         spca.points_per_win,
--         spca.points_per_draw,
--         spca.points_per_losing,
--         (SELECT COUNT(*)
--          FROM SCORE s
--          JOIN TEAM_ROSTER tr
--              ON s.duel_id = tr.duel_id
--             AND s.player_ssn = tr.player_ssn
--             AND tr.team_id = d.home_team_id
--         ) AS home_team_goals,
--         (SELECT COUNT(*)
--          FROM SCORE s
--          JOIN TEAM_ROSTER tr
--              ON s.duel_id = tr.duel_id
--             AND s.player_ssn = tr.player_ssn
--             AND tr.team_id = d.away_team_id
--         ) AS away_team_goals
--     FROM DUEL d
--     JOIN COMPETITION c
--         ON d.competition_id = c.id
--        AND c.season_id = 1
--     JOIN SPORT_CATEGORY spca
--         ON spca.id = d.sport_category_id
-- )
-- SELECT
--     t.id AS team_id,
--     t.name AS team_name,
--     dr.season_id,
--     COUNT(*) AS matches_played,
--     SUM(
--         CASE
--             WHEN (t.id = dr.home_team_id AND dr.home_team_goals > dr.away_team_goals)
--               OR (t.id = dr.away_team_id AND dr.away_team_goals > dr.home_team_goals)
--                 THEN dr.points_per_win
--             WHEN dr.home_team_goals = dr.away_team_goals
--                 THEN dr.points_per_draw
--             ELSE dr.points_per_losing
--         END
--     ) AS total_points
-- FROM SPORT_TEAM t
-- JOIN duel_results dr
--     ON t.id IN (dr.home_team_id, dr.away_team_id)
-- GROUP BY t.id, t.name, dr.season_id
-- ORDER BY total_points DESC;
--
--
-- CREATE OR REPLACE VIEW get_duels AS
-- SELECT
--     d.id,
--     d.start_time,
--     ht.name AS home_team,
--     at.name AS away_team,
--     l.name AS location
-- FROM DUEL d
-- JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
-- JOIN SPORT_TEAM at ON at.id = d.away_team_id
-- JOIN LOCATION l ON l.id = d.location_id
-- LEFT JOIN COMPETITION c ON d.competition_id = c.id
-- JOIN SPORT_CATEGORY sc ON d.sport_category_id = sc.id
-- WHERE d.sport_category_id = 1
--   AND d.competition_id = 1
--   AND d.start_time > NOW()
-- ORDER BY d.start_time ASC;
--
--
-- CREATE OR REPLACE VIEW monthly_profit_for_team AS
-- WITH monthly_income AS (
--     SELECT COALESCE(SUM(amount), 0) AS total_income
--     FROM SPONSORSHIP
--     WHERE sport_team_id = 1
--       AND start_date <= NOW()::date
--       AND (end_date IS NULL OR end_date > NOW()::date + INTERVAL '30 days')
-- ),
-- monthly_spending AS (
--     SELECT COALESCE(SUM(spso.payout), 0) AS total_spending
--     FROM SPORTSPERSON_CONTRACT spso
--     JOIN SPORT_CLUB sc ON sc.id = spso.club_id
--     JOIN SPORT_TEAM st ON st.club_id = sc.id
--     WHERE st.id = 1
--       AND spso.start_date <= NOW()::date
--       AND (spso.end_date IS NULL OR spso.end_date > NOW()::date + INTERVAL '30 days')
-- )
-- SELECT
--     st.id,
--     st.name,
--     mi.total_income AS income,
--     ms.total_spending AS spending,
--     mi.total_income - ms.total_spending AS profit
-- FROM monthly_income mi, monthly_spending ms
-- JOIN SPORT_TEAM st ON st.id = 1;

-------------1
CREATE OR REPLACE VIEW duel_score AS
SELECT
    d.id AS duel_id,
    d.home_team_id,
    d.away_team_id,
    (
        SELECT COUNT(*)
        FROM SCORE s
        JOIN TEAM_ROSTER tr
            ON s.duel_id = tr.duel_id
           AND s.player_ssn = tr.player_ssn
           AND tr.team_id = d.home_team_id
        WHERE s.duel_id = d.id
    ) AS home_team_goals,
    (
        SELECT COUNT(*)
        FROM SCORE s
        JOIN TEAM_ROSTER tr
            ON s.duel_id = tr.duel_id
           AND s.player_ssn = tr.player_ssn
           AND tr.team_id = d.away_team_id
        WHERE s.duel_id = d.id
    ) AS away_team_goals
FROM DUEL d;

--------------------2
CREATE OR REPLACE VIEW season_team_standings AS
SELECT
    t.id   AS team_id,
    t.name AS team_name,
    c.season_id,
    COUNT(*) AS matches_played,
    SUM(
        CASE
            WHEN (t.id = ds.home_team_id AND ds.home_team_goals > ds.away_team_goals)
              OR (t.id = ds.away_team_id AND ds.away_team_goals > ds.home_team_goals)
                THEN sc.points_per_win
            WHEN ds.home_team_goals = ds.away_team_goals
                THEN sc.points_per_draw
            ELSE sc.points_per_losing
        END
    ) AS total_points,
    SUM(
        CASE WHEN t.id = ds.home_team_id THEN ds.home_team_goals
             ELSE ds.away_team_goals END
    ) AS goals_scored,
    SUM(
        CASE WHEN t.id = ds.home_team_id THEN ds.away_team_goals
             ELSE ds.home_team_goals END
    ) AS goals_conceded
FROM SPORT_TEAM t
JOIN duel_score ds
    ON t.id IN (ds.home_team_id, ds.away_team_id)
JOIN DUEL d
    ON d.id = ds.duel_id
JOIN COMPETITION c
    ON d.competition_id = c.id
   AND c.season_id = 1
JOIN SPORT_CATEGORY sc
    ON sc.id = d.sport_category_id
GROUP BY t.id, t.name, c.season_id
ORDER BY total_points DESC, (goals_scored - goals_conceded) DESC;

---------------------------3
CREATE OR REPLACE VIEW duel_history AS
SELECT
    d.id            AS duel_id,
    d.start_time,
    l.name          AS location,
    ht.name         AS home_team,
    at.name         AS away_team,
    ds.home_team_goals,
    ds.away_team_goals,
    CASE
        WHEN ds.home_team_goals > ds.away_team_goals THEN ht.name
        WHEN ds.away_team_goals > ds.home_team_goals THEN at.name
        ELSE 'Draw'
    END AS result,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.home_team_id
    ) AS home_roster,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.away_team_id
    ) AS away_roster
FROM DUEL d
JOIN duel_score ds  ON ds.duel_id = d.id
JOIN SPORT_TEAM ht  ON ht.id = d.home_team_id
JOIN SPORT_TEAM at  ON at.id = d.away_team_id
JOIN LOCATION   l   ON l.id = d.location_id
JOIN COMPETITION c  ON c.id = d.competition_id
WHERE c.id        = 1
  AND d.start_time < NOW()
ORDER BY d.start_time DESC;

----------------------------4
CREATE OR REPLACE VIEW monthly_profit_for_team AS
WITH monthly_income AS (
    SELECT COALESCE(SUM(amount), 0) AS total_income
    FROM SPONSORSHIP
    WHERE sport_team_id = 1
      AND start_date <= NOW()::date
      AND (end_date IS NULL OR end_date > NOW()::date + INTERVAL '30 days')
),
monthly_spending AS (
    SELECT COALESCE(SUM(spso.payout), 0) AS total_spending
    FROM SPORTSPERSON_CONTRACT spso
    JOIN SPORT_CLUB sc ON sc.id = spso.club_id
    JOIN SPORT_TEAM st ON st.club_id = sc.id
    WHERE st.id = 1
      AND spso.start_date <= NOW()::date
      AND (spso.end_date IS NULL OR spso.end_date > NOW()::date + INTERVAL '30 days')
)
SELECT
    st.id,
    st.name,
    mi.total_income AS income,
    ms.total_spending AS spending,
    mi.total_income - ms.total_spending AS profit
FROM monthly_income mi, monthly_spending ms
JOIN SPORT_TEAM st ON st.id = 1;

------------------5
CREATE OR REPLACE VIEW free_locations_for_slots AS
WITH time_slots AS (
    SELECT 1 AS slot_num, '2025-03-01 10:00:00'::timestamp AS slot_start, '2025-03-01 12:00:00'::timestamp AS slot_end
    UNION ALL
    SELECT 2,'2025-03-01 14:00:00'::timestamp,'2025-03-01 16:00:00'::timestamp
    UNION ALL
    SELECT 3,'2025-03-01 18:00:00'::timestamp,'2025-03-01 20:00:00'::timestamp
),
category_duels AS (
    SELECT
        d.location_id,
        d.start_time,
        d.start_time + (sc.duration_minutes * INTERVAL '1 minute') AS end_time
    FROM DUEL d
    JOIN SPORT_CATEGORY sc ON sc.id = d.sport_category_id
    WHERE d.sport_category_id = 1
),
free_locations AS (
    SELECT
        ts.slot_num,
        ts.slot_start,
        ts.slot_end,
        l.id AS location_id,
        l.name AS location_name,
        l.address,
        l.capacity
    FROM time_slots ts
    CROSS JOIN LOCATION l
    WHERE l.country_id = 1
      AND NOT EXISTS (
          SELECT 1
          FROM category_duels cd
          WHERE cd.location_id = l.id
            AND cd.start_time < ts.slot_end
            AND cd.end_time > ts.slot_start
      )
),
ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY slot_num
            ORDER BY capacity DESC
        ) AS rank
    FROM free_locations
)
SELECT
    slot_num,
    slot_start,
    slot_end,
    location_id,
    location_name,
    address,
    capacity
FROM ranked
WHERE rank <= 3
ORDER BY slot_num, capacity DESC;

-------------------------6
CREATE OR REPLACE VIEW top_scores_per_competiotion as
SELECT d.competition_id,
       s.player_ssn,
       p.first_name || ' ' || p.last_name as player_name,
       COUNT(*) as total_goals,
       RANK() OVER (
            PARTITION BY d.competition_id
            ORDER BY COUNT(*) DESC
       ) as rank
FROM SCORE s
    join Duel d on s.duel_id=d.id
    join SPORTSPERSON sp on s.player_ssn=sp.ssn
    join PERSON p on sp.ssn = p.ssn
WHERE d.competition_id is not null
group by d.competition_id, s.player_ssn, p.first_name, p.last_name;

-----------------------------7
CREATE OR REPLACE VIEW referee_workflow_summary as
SELECT r.ssn as referee_ssn,
       p.first_name || ' ' || p.last_name as referee_name,
       c.name as country,
       sc.name as sport_category_name,
       COUNT(rd.duel_id) as total_duels_officiated,
       MIN(d.start_time)::date as first_duel_date,
       MAX(d.start_time)::date as last_duel_date
FROM REFEREE r
    join PERSON p on r.ssn=p.ssn
    join COUNTRY c on c.id = p.country_id
    join SPORT_CATEGORY sc on r.sport_category_id = sc.id
    left join REFEREEING_DUEL rd on rd.referee_ssn = r.ssn
    LEFT join DUEL d on d.id=rd.duel_id
group by r.ssn, p.first_name, p.last_name, c.name, sc.name
HAVING COUNT(rd.duel_id)>0
ORDER BY total_duels_officiated DESC;

----------------------8
CREATE OR replace VIEW location_usage as
SELECT l.id as location_id,
       l.name as location_name,
       l.capacity,
       l.address,
       c.name as country_name,
       count(d.id) as total_duel_played,
       MIN(d.start_time)::date as first_duel_date,
       MAX(d.start_time)::date as last_duel_date
FROM location l
    join country c on l.country_id=c.id
    left join Duel d on d.location_id=l.id
GROUP BY l.id, l.name, l.capacity, l.address, c.name;

------------------------9
CREATE OR REPLACE VIEW player_duel_stats as
SELECT sp.ssn,
       p.first_name || ' ' || p.last_name as person_name,
       c.name as country_name,
       sc.name as sport_name,
       count(Distinct tr.duel_id) as total_duels,
       count(s.id) as total_score,
       round(
            AVG(
                (extract(EPOCH from (coalesce(tr.end_time, tr.start_time+sc.duration_minutes * Interval '1 minute')-tr.start_time)))/60.0
            ), 1
       ) as avg_minutes_per_duel,
       round(
            sum(
                (extract(EPOCH from (coalesce(tr.end_time, tr.start_time+sc.duration_minutes * Interval '1 minute')-tr.start_time)))/60.0
            ),1
       ) as total_minutes_played
FROM sportsperson sp
    join person p on sp.ssn=p.ssn
    join country c on c.id = p.country_id
    join sport_category sc on sc.id=sp.sport_category_id
    left join team_roster tr on tr.player_ssn = sp.ssn
    left join duel d on d.id=tr.duel_id
    left join score s on s.player_ssn=sp.ssn
group by sp.ssn, p.first_name, p.last_name, c.name, sc.name
order by total_score desc;
