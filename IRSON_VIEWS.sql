CREATE OR REPLACE VIEW season_team_standings AS
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
       AND c.season_id = 1
    JOIN SPORT_CATEGORY spca
        ON spca.id = d.sport_category_id
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


CREATE OR REPLACE VIEW get_duels AS
SELECT
    d.id,
    d.start_time,
    ht.name AS home_team,
    at.name AS away_team,
    l.name AS location
FROM DUEL d
JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
JOIN SPORT_TEAM at ON at.id = d.away_team_id
JOIN LOCATION l ON l.id = d.location_id
LEFT JOIN COMPETITION c ON d.competition_id = c.id
JOIN SPORT_CATEGORY sc ON d.sport_category_id = sc.id
WHERE d.sport_category_id = 1
  AND d.competition_id = 1
  AND d.start_time > NOW()
ORDER BY d.start_time ASC;


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
