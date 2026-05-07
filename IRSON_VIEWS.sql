-----------------------------------------------------------------------------
-- 1. season standing
CREATE VIEW season_standing AS
SELECT
    t.id AS team_id,
    t.name AS team_name,
    c.id AS competiton_id,
    c.season_id,
    c.name AS leauge_name,
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
JOIN duel d
    ON t.id IN (d.home_team_id, d.away_team_id)
    AND now() > d.start_time
JOIN competition c
    ON d.competition_id = c.id
JOIN sport_category sc
    ON sc.id = d.sport_category_id
GROUP BY
    t.id,
    t.name,
    c.season_id,
    c.id,
    c.name
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
    ) DESC;
select * from season_standing where season_id = 7839809;
-----------------------------------------------------------------------------
-- 2. monthly income for club
CREATE VIEW monthly_income_for_club AS
SELECT
    sc.id,
    sc.name,
    sum(ss.amount) AS income,
    sum(scn.payout) AS spending,
    sum(ss.amount) - sum(scn.payout) AS profit,
    count(distinct ss.sponsor_id) AS number_of_active_sponsorships,
    count(distinct scn.player_ssn) AS number_of_player_active_contracts
FROM sport_club sc
JOIN sportsperson_contract scn on scn.club_id = sc.id
    and scn.start_date <= now()::date
    and (scn.end_date is null or scn.end_date > now()::date + INTERVAL '30 days')
JOIN sport_team st on st.club_id = sc.id
JOIN sponsorship ss on ss.sport_team_id = st.id
    and ss.start_date < now()::date
    and (ss.end_date is null or ss.end_date > now()::date + INTERVAL '30 days')
GROUP BY sc.id, sc.name;
select * from monthly_income_for_club where id = 97426;
-----------------------------------------------------------------------------
-- 3. upcoming duels
CREATE VIEW upcoming_duels AS
SELECT
    d.start_time::date AS match_date,
    d.start_time::time AS kickoff,
    home.name AS home_team,
    away.name AS away_team,
    scat.name AS sport,
    l.name AS venue,
    l.capacity,
    c.name AS country,
    d.competition_id,
    com.name AS competiton_name
FROM duel d
JOIN sport_team home ON home.id = d.home_team_id
JOIN sport_team away ON away.id = d.away_team_id
JOIN sport_category scat ON scat.id = d.sport_category_id
JOIN location l ON l.id = d.location_id
JOIN country c ON c.id = l.country_id
LEFT JOIN competition com on c.id = d.competition_id
WHERE d.start_time > NOW()
ORDER BY com.name;
select * from upcoming_duels
where match_date <= (now() + INTERVAL '7 days')::date
    and country like '%Macedonia'
order by match_date, kickoff, capacity DESC;
-- TODO: so ime na competiton da se fixa
-----------------------------------------------------------------------------
-- 4. free locations
SELECT
    l.name AS venue,
    l.capacity,
    l.address,
    c.name AS country,
    c.id AS country_id
FROM location l
JOIN country c ON c.id = l.country_id
JOIN DUEL d ON d.location_id = l.id;
--TODO: da se zavhrsi
-----------------------------------------------------------------------------
-- 5. top scorers on competition
CREATE VIEW top_scorers_on_competition AS
SELECT
    comp.id AS competition_id,
    comp.name AS competition_name,
    p.first_name || ' ' || p.last_name AS player_name,
    t.name AS team_name,
    COUNT(*) AS scores
FROM SCORE s
JOIN DUEL d ON d.id = s.duel_id
JOIN COMPETITION comp ON comp.id = d.competition_id
JOIN SPORTSPERSON sp ON sp.ssn = s.player_ssn
JOIN PERSON p ON p.ssn = sp.ssn
JOIN TEAM_ROSTER tr ON tr.duel_id = s.duel_id AND tr.player_ssn = s.player_ssn
JOIN SPORT_TEAM t ON t.id = tr.team_id
WHERE d.competition_id IS NOT NULL
GROUP BY comp.id, comp.name, s.player_ssn, p.first_name, p.last_name, t.name
ORDER BY scores DESC;
select * from top_scorers_on_competition where competition_id = 7287756;
-----------------------------------------------------------------------------
-- 6. referee work
CREATE VIEW referee_work AS
SELECT
    r.ssn AS referee_ssn,
    p.first_name || ' ' || p.last_name AS referee_name,
    c.name AS country,
    sc.name AS sport_category_name,
    COUNT(rd.duel_id) AS total_duels_officiated,
    MIN(d.start_time)::date AS first_duel_date,
    COUNT(*) FILTER (WHERE d.start_time > NOW()) AS upcoming_duels
FROM REFEREE r
JOIN PERSON p ON r.ssn = p.ssn
JOIN COUNTRY c ON c.id = p.country_id
JOIN SPORT_CATEGORY sc ON r.sport_category_id = sc.id
LEFT JOIN REFEREEING_DUEL rd ON rd.referee_ssn = r.ssn
LEFT JOIN DUEL d ON d.id = rd.duel_id
JOIN FEDERATION f ON f.id = r.federation_id
GROUP BY r.ssn, p.first_name, p.last_name, c.name, sc.name;
select * from referee_work where referee_ssn = '151200845059';
-----------------------------------------------------------------------------
-- 7. team stats: team coaches, active contracts and upcoming duels
CREATE VIEW team_stats AS
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
        FROM DUEL d
        WHERE d.start_time > NOW()
          AND (d.home_team_id = t.id OR d.away_team_id = t.id)
    ) AS registered_upcoming_duels,
    (
        SELECT d.start_time::date
        FROM DUEL d
        WHERE d.start_time > NOW()
          AND (d.home_team_id = t.id OR d.away_team_id = t.id)
        ORDER BY d.start_time
        LIMIT 1
    ) AS next_duel_date
FROM SPORT_TEAM t
JOIN SPORT_CLUB sc ON sc.id = t.club_id
JOIN COUNTRY c ON c.id = sc.country_id
JOIN SPORT_CATEGORY scat ON scat.id = t.sport_category_id;
select * from team_stats ts where ts.team_id = 205986;
-----------------------------------------------------------------------------
-- 8. duel history which teams, team rosters, scores, and red cads
CREATE VIEW duel_history AS
SELECT
    d.id AS duel_id,
    d.start_time,
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
        FROM SCORE s
        JOIN TEAM_ROSTER tr ON tr.duel_id = s.duel_id AND tr.player_ssn = s.player_ssn AND tr.team_id = d.home_team_id
        JOIN PERSON p ON p.ssn = s.player_ssn
        WHERE s.duel_id = d.id
    ) AS home_scorers,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (' || s.time_score::text || ')', ', ' ORDER BY s.time_score)
        FROM SCORE s
        JOIN TEAM_ROSTER tr ON tr.duel_id = s.duel_id AND tr.player_ssn = s.player_ssn AND tr.team_id = d.away_team_id
        JOIN PERSON p ON p.ssn = s.player_ssn
        WHERE s.duel_id = d.id
    ) AS away_scorers,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (off ' || tr.end_time::text || ')', ', ')
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.home_team_id
          AND scat.team_capacity > 3
          AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
    ) AS home_red_cards,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name || ' (off ' || tr.end_time::text || ')', ', ')
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
        WHERE tr.duel_id = d.id
          AND tr.team_id = d.away_team_id
          AND scat.team_capacity > 3
          AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
    ) AS away_red_cards,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id AND tr.team_id = d.home_team_id
    ) AS home_roster,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ' ORDER BY p.last_name)
        FROM TEAM_ROSTER tr
        JOIN PERSON p ON p.ssn = tr.player_ssn
        WHERE tr.duel_id = d.id AND tr.team_id = d.away_team_id
    ) AS away_roster,
    (
        SELECT STRING_AGG(p.first_name || ' ' || p.last_name, ', ')
        FROM REFEREEING_DUEL rd
        JOIN PERSON p ON p.ssn = rd.referee_ssn
        WHERE rd.duel_id = d.id
    ) AS referees
FROM DUEL d
JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
JOIN SPORT_TEAM at ON at.id = d.away_team_id
JOIN LOCATION l ON l.id = d.location_id
WHERE d.start_time < NOW()
ORDER BY d.start_time DESC;
select * from duel_history where duel_id = 32434137;
-----------------------------------------------------------------------------
-- 9. players that got red card
CREATE VIEW get_red_cards AS
SELECT
    d.id AS duel_id,
    ht.name AS home_team,
    at.name AS away_team,
    d.sport_category_id,
    d.competition_id,
    p.first_name || ' ' || p.last_name AS player_name,
    t.name AS team_name,
    d.start_time AS duel_start,
    tr.end_time AS exit_time,
    scat.duration_minutes AS full_duration,
    (scat.duration_minutes - EXTRACT(MINUTE FROM tr.end_time))::int AS minutes_missed
FROM TEAM_ROSTER tr
JOIN DUEL d ON d.id = tr.duel_id AND now() > d.start_time
JOIN SPORT_CATEGORY scat ON scat.id = d.sport_category_id
JOIN PERSON p ON p.ssn = tr.player_ssn
JOIN SPORT_TEAM t ON t.id = tr.team_id
JOIN SPORT_TEAM ht ON ht.id = d.home_team_id
JOIN SPORT_TEAM at ON at.id = d.away_team_id
WHERE scat.team_capacity > 3
  AND tr.end_time < (scat.duration_minutes * INTERVAL '1 minute')::time
ORDER BY duel_start DESC, minutes_missed DESC, d.competition_id;
select * from get_red_cards where get_red_cards.sport_category_id = 1
    and competition_id < 7284256 + 100;
-----------------------------------------------------------------------------
-- 10. player career history
CREATE VIEW player_career_history AS
SELECT sp.ssn,
       p.first_name || ' ' || p.last_name as player_name,
       p.date_of_birth,
       c_from.name as nationality,
       scategory.name as sport_category,
       sc.name as club_name,
       club_country.name as club_country,
       spc.start_date as contract_start,
       spc.end_date as contract_end,
       CASE
           WHEN spc.end_date is null THEN 'ACTIVE'
           WHEN spc.end_date>now()::date THEN 'ACTIVE'
       ELSE 'EXPIRED' end as contract_status,
       spc.payout as monthly_payout,
       count(*) over (
           partition by sp.ssn
           ) as total_contracts
FROM sportsperson sp
    join person p on p.ssn=sp.ssn
    join country c_from on c_from.id=p.country_id
    join sportsperson_contract spc on spc.player_ssn=sp.ssn
    join sport_category scategory on scategory.id=sp.sport_category_id
    join sport_club sc on sc.id = spc.club_id
    join country club_country on club_country.id = sc.country_id
order by sp.ssn, spc.start_date;
select * from player_career_history where ssn = '271196542072';
-----------------------------------------------------------------------------
-- TODO: duel score i season standing so indeksiranje zemanje od score tabela
-- so joini kako shto kazha Nenand
-- goals da se zemani so score (poopshto)
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