CREATE OR REPLACE FUNCTION season_team_standings(
    p_season_id INT,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    team_id INT,
    team_name TEXT,
    season_id INT,
    matches_played BIGINT,
    total_points NUMERIC
) AS
$$
WITH duel_results AS (
    SELECT
        d.id AS duel_id,
        c.season_id AS season_id,
        d.home_team_id,
        d.away_team_id,
        spca.points_per_win,
        spca.points_per_draw,
        spca.points_per_losing,
        (SELECT COUNT(*)
         FROM SCORE s
         JOIN TEAM_ROSTER tr
             ON s.duel_id = tr.duel_id
            AND s.player_ssn = tr.player_ssn
            AND tr.team_id = d.home_team_id
        ) AS home_team_goals,
        (SELECT COUNT(*)
         FROM SCORE s
         JOIN TEAM_ROSTER tr
             ON s.duel_id = tr.duel_id
            AND s.player_ssn = tr.player_ssn
            AND tr.team_id = d.away_team_id
        ) AS away_team_goals
    FROM DUEL d
    JOIN COMPETITION c
        ON d.competition_id = c.id
       AND c.season_id = p_season_id
    JOIN SPORT_CATEGORY spca
        ON spca.id = d.sport_category_id
    WHERE d.start_time::date >= p_start_date
      AND d.start_time::date <= p_end_date
)
SELECT
    t.id AS team_id,
    t.name AS team_name,
    dr.season_id,
    COUNT(*) AS matches_played,
    SUM(
        CASE
            WHEN (t.id = dr.home_team_id AND dr.home_team_goals > dr.away_team_goals)
              OR (t.id = dr.away_team_id AND dr.away_team_goals > dr.home_team_goals)
                THEN dr.points_per_win

            WHEN dr.home_team_goals = dr.away_team_goals
                THEN dr.points_per_draw

            ELSE dr.points_per_losing
        END
    ) AS total_points
FROM SPORT_TEAM t
JOIN duel_results dr
    ON t.id IN (dr.home_team_id, dr.away_team_id)
GROUP BY t.id, t.name, dr.season_id
ORDER BY total_points DESC;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION get_duels(
    p_state TEXT,
    p_sport_category_id INT,
    p_competition_id INT,
    p_limit INT DEFAULT 100,
    p_offset INT DEFAULT 0
)
RETURNS TABLE (
    id INT,
    start_time TIMESTAMP,
    home_team TEXT,
    away_team TEXT,
    location TEXT
) AS
$$
SELECT
    d.id,
    d.start_time,
    ht.name,
    at.name,
    l.name
FROM duel d
JOIN sport_team ht ON ht.id = d.home_team_id
JOIN sport_team at ON at.id = d.away_team_id
JOIN location l ON l.id = d.location_id
JOIN competition c ON d.competition_id = c.id
JOIN sport_category sc ON d.sport_category_id = sc.id
WHERE
    d.sport_category_id = p_sport_category_id
    AND d.competition_id = p_competition_id
    AND (
        (p_state = 'future' AND d.start_time > NOW())
        OR
        (p_state = 'past' AND d.start_time < NOW())
        OR
        (p_state = 'current' AND 
            NOW() BETWEEN d.start_time 
            AND d.start_time + sc.duration_minutes * INTERVAL '1 minute'
        )
    )
ORDER BY
    CASE WHEN p_state = 'future' THEN d.start_time END ASC,
    CASE WHEN p_state <> 'future' THEN d.start_time END DESC
LIMIT p_limit
OFFSET p_offset;
$$ LANGUAGE sql;

CREATE OR REPLACE FUNCTION monthly_profit_for_team(p_team_id INT)
RETURNS TABLE (
    income NUMERIC,
    spending NUMERIC,
    profit NUMERIC
) AS
$$
WITH monthly_income AS (
    SELECT
        sport_team_id,
        SUM(amount) AS total_income
    FROM SPONSORSHIP
    WHERE sport_team_id = p_team_id
      AND start_date <= NOW()::date
      AND (end_date IS NULL OR end_date > NOW()::date + INTERVAL '30 days')
    GROUP BY sport_team_id
),
monthly_spending AS (
    SELECT
        sc.id AS club_id,
        SUM(spso.payout) AS total_spending
    FROM SPORTSPERSON_CONTRACT spso
    JOIN SPORT_CLUB sc
        ON sc.id = spso.club_id
    JOIN SPORT_TEAM st
        ON st.club_id = sc.id
    WHERE st.id = p_team_id
      AND spso.start_date <= NOW()::date
      AND (spso.end_date IS NULL OR spso.end_date > NOW()::date + INTERVAL '30 days')
    GROUP BY sc.id
)
SELECT
    COALESCE(mi.total_income, 0) AS income,
    COALESCE(ms.total_spending, 0) AS spending,
    COALESCE(mi.total_income, 0) - COALESCE(ms.total_spending, 0) AS profit
FROM monthly_income mi
FULL JOIN monthly_spending ms
    ON true;
$$ LANGUAGE sql;