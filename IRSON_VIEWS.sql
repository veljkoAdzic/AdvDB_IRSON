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