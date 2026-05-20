-- registracija na sportsperson, referee i coach
CREATE OR REPLACE PROCEDURE register_sportsperson(
    n_ssn           char(13),
    n_first_name    varchar(30),
    n_last_name     varchar(30),
    n_date_of_birth date,
    n_gender        char(1),
    n_country_id    int4,
    n_sport_category_id int4
)
LANGUAGE plpgsql AS $$
BEGIN
    IF n_date_of_birth > now() - INTERVAL '15 years' THEN
        RAISE EXCEPTION 'Sportsperson must be at least 15 years old';
    END IF;

    IF length(trim(n_first_name)) < 3 THEN
        RAISE EXCEPTION 'First name must be at least 3 characters';
    END IF;

    IF length(trim(n_last_name)) < 3 THEN
        RAISE EXCEPTION 'Last name must be at least 3 characters';
    END IF;

    IF n_gender NOT IN ('M', 'F') THEN
        RAISE EXCEPTION 'Invalid gender.';
    END IF;

    IF n_country_id NOT IN (SELECT id FROM country) THEN
        RAISE EXCEPTION 'Invalid country id';
    END IF;

    IF n_sport_category_id NOT IN (SELECT id FROM sport_category) THEN
        RAISE EXCEPTION 'Invalid sport category id';
    END IF;

    IF n_ssn NOT LIKE 
        to_char(n_date_of_birth, 'DDMM') ||
        to_char(extract(year from n_date_of_birth)::integer % 1000, 'FM009') || 
        '%' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong date of birth in ssn';
    END IF;
    IF n_gender = 'M' AND SUBSTR(n_ssn, 10, 1) != '0' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF; 
    IF n_gender = 'F' AND SUBSTR(n_ssn, 10, 1) != '5' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF;

    INSERT INTO PERSON(ssn, first_name, last_name, date_of_birth, gender, country_id) VALUES
    (n_ssn, trim(n_first_name), trim(n_last_name), n_date_of_birth, n_gender, n_country_id);

    INSERT INTO sportsperson(ssn, sport_category_id) VALUES
        (n_ssn, n_sport_category_id);

    COMMIT;

END;
$$;

CREATE OR REPLACE PROCEDURE register_coach(
    n_ssn           char(13),
    n_first_name    varchar(30),
    n_last_name     varchar(30),
    n_date_of_birth date,
    n_gender        char(1),
    n_country_id    int4,
    n_sport_category_id int4,
    n_federation_id int4
)
LANGUAGE plpgsql AS $$
BEGIN
    IF n_date_of_birth > now() - INTERVAL '15 years' THEN
        RAISE EXCEPTION 'Sportsperson must be at least 15 years old';
    END IF;

    IF length(trim(n_first_name)) < 3 THEN
        RAISE EXCEPTION 'First name must be at least 3 characters';
    END IF;

    IF length(trim(n_last_name)) < 3 THEN
        RAISE EXCEPTION 'Last name must be at least 3 characters';
    END IF;

    IF n_gender NOT IN ('M', 'F') THEN
        RAISE EXCEPTION 'Invalid gender.';
    END IF;

    IF n_country_id NOT IN (SELECT id FROM country) THEN
        RAISE EXCEPTION 'Invalid country id';
    END IF;

    IF n_sport_category_id NOT IN (SELECT id FROM sport_category) THEN
        RAISE EXCEPTION 'Invalid sport category id';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM federation where id = n_federation_id) THEN
        RAISE EXCEPTION 'Invalid federation id';
    END IF;

    IF n_ssn NOT LIKE
        to_char(n_date_of_birth, 'DDMM') ||
        to_char(extract(year from n_date_of_birth)::integer % 1000, 'FM009') ||
        '%' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong date of birth in ssn';
    END IF;
    IF n_gender = 'M' AND SUBSTR(n_ssn, 10, 1) != '0' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF;
    IF n_gender = 'F' AND SUBSTR(n_ssn, 10, 1) != '5' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF;

    INSERT INTO PERSON(ssn, first_name, last_name, date_of_birth, gender, country_id) VALUES
    (n_ssn, trim(n_first_name), trim(n_last_name), n_date_of_birth, n_gender, n_country_id);

    INSERT INTO coach(ssn, sport_category_id, federation_id) VALUES
        (n_ssn, n_sport_category_id, n_federation_id);

    COMMIT;

END;
$$;

CREATE OR REPLACE PROCEDURE register_referee(
    n_ssn           char(13),
    n_first_name    varchar(30),
    n_last_name     varchar(30),
    n_date_of_birth date,
    n_gender        char(1),
    n_country_id    int4,
    n_sport_category_id int4,
    n_federation_id int4
)
LANGUAGE plpgsql AS $$
BEGIN
    IF n_date_of_birth > now() - INTERVAL '15 years' THEN
        RAISE EXCEPTION 'Sportsperson must be at least 15 years old';
    END IF;

    IF length(trim(n_first_name)) < 3 THEN
        RAISE EXCEPTION 'First name must be at least 3 characters';
    END IF;

    IF length(trim(n_last_name)) < 3 THEN
        RAISE EXCEPTION 'Last name must be at least 3 characters';
    END IF;

    IF n_gender NOT IN ('M', 'F') THEN
        RAISE EXCEPTION 'Invalid gender.';
    END IF;

    IF n_country_id NOT IN (SELECT id FROM country) THEN
        RAISE EXCEPTION 'Invalid country id';
    END IF;

    IF n_sport_category_id NOT IN (SELECT id FROM sport_category) THEN
        RAISE EXCEPTION 'Invalid sport category id';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM federation where id = n_federation_id) THEN
        RAISE EXCEPTION 'Invalid federation id';
    END IF;

    IF n_ssn NOT LIKE
        to_char(n_date_of_birth, 'DDMM') ||
        to_char(extract(year from n_date_of_birth)::integer % 1000, 'FM009') ||
        '%' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong date of birth in ssn';
    END IF;
    IF n_gender = 'M' AND SUBSTR(n_ssn, 10, 1) != '0' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF;
    IF n_gender = 'F' AND SUBSTR(n_ssn, 10, 1) != '5' THEN
        RAISE EXCEPTION 'Invalid ssn, wrong gender in ssn';
    END IF;

    INSERT INTO PERSON(ssn, first_name, last_name, date_of_birth, gender, country_id) VALUES
    (n_ssn, trim(n_first_name), trim(n_last_name), n_date_of_birth, n_gender, n_country_id);

    INSERT INTO referee(ssn, sport_category_id, federation_id) VALUES
        (n_ssn, n_sport_category_id, n_federation_id);
    COMMIT;
END;
$$;
CALL register_referee('030299412014', 'Ivicaaa', 'Perovski', '1994-02-03'::date, 'M', 112, 1, 112);
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE renew_sportsperson_contract(
    old_contract_id int4,
    n_end_date date,
    n_payout int4
)
LANGUAGE plpgsql AS $$
DECLARE
    o_ssn char(13);
    o_club_id int4;
    o_end_date date;

BEGIN
    -- Input validacija
    IF n_end_date IS NOT NULL and n_end_date < now() THEN
        RAISE EXCEPTION 'Invalid n_end_date - must be in the future!';
    END IF;

    IF NOT EXISTS( SELECT 1 FROM sportsperson_contract WHERE id = old_contract_id) THEN
        RAISE EXCEPTION 'Invalid old_contract_id - contract with id % does not exist!', old_contract_id;
    END IF;

    IF n_payout <= 0 THEN
        RAISE EXCEPTION 'Invalid n_payout - Payout must be positive amount!';
    END IF;

    -- Zimanje stari vrednosti
    SELECT
        player_ssn, club_id, end_date
        INTO
        o_ssn, o_club_id, o_end_date
    FROM sportsperson_contract
    WHERE id = old_contract_id;

    -- azuriranje star dogovir
    IF o_end_date IS NULL THEN
        UPDATE sportsperson_contract
        SET end_date = now()::date
        WHERE id = old_contract_id
        ;
        SELECT now()::date into o_end_date;
    END IF;

    -- proverka za validen nov obseg
    IF n_end_date IS NOT NULL and o_end_date > n_end_date THEN
        RAISE EXCEPTION 'Invalid n_end_date - must be after %', o_end_date;
    END IF;

    -- dodavanje nov dogovor
    INSERT INTO sportsperson_contract(player_ssn, club_id, start_date, end_date, payout)
    VALUES (o_ssn, o_club_id, o_end_date, n_end_date, n_payout);
    COMMIT;
END;
$$;
call renew_sportsperson_contract(6050471, NULL, 2000000);
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE borrow_player(
    p_ssn char(13),
    borrowed_club_id int4,
    borrowing_club_id int4,
    from_date date,
    to_date date,
    b_payout int4
) LANGUAGE plpgsql AS $$
DECLARE
    old_contract_id int4;
    old_start_date date;
    old_end_date date;
    old_payout int4;
BEGIN
    -- validacija vlezovi
    IF from_date IS NULL OR to_date IS NULL OR from_date > to_date THEN
        RAISE EXCEPTION 'Invalid borrow date range!';
    end if;

    IF NOT EXISTS(SELECT 1 FROM sportsperson WHERE ssn = p_ssn) THEN
        RAISE EXCEPTION 'Invalid p_ssn - Player with ssn % does not exist!', p_ssn;
    end if;

    IF NOT EXISTS(SELECT 1 FROM sport_club WHERE id = borrowing_club_id) THEN
        RAISE EXCEPTION 'Invalid borrowing_club_id - Sport club with id % does not exist!', borrowing_club_id;
    end if;

    IF NOT EXISTS(SELECT 1 FROM sport_club WHERE id = borrowed_club_id) THEN
        RAISE EXCEPTION 'Invalid borrowed_club_id - Sport club with id % does not exist!', borrowed_club_id;
    end if;

    -- naogjanje dogovor
    SELECT
        id, start_date, end_date, payout
    into
        old_contract_id, old_start_date, old_end_date, old_payout
    FROM sportsperson_contract
    WHERE
        player_ssn = p_ssn
        and club_id = borrowed_club_id
    ;

    -- Validacija
    IF old_contract_id IS NULL OR (old_end_date IS NOT NULL AND old_end_date < now()) THEN
        RAISE EXCEPTION 'Player has no active contract with club';
    end if;

    IF old_end_date IS NOT NULL AND (old_end_date > from_date OR old_end_date < to_date) THEN
        RAISE EXCEPTION 'Invalid borrow range - active contract ends in borrow period!';
    end if;

    IF from_date < old_start_date OR (old_end_date IS NOT NULL AND to_date > old_end_date) THEN
        RAISE EXCEPTION 'Invalid borrow range - must be within contract range!';
    end if;

    -- Zavrshuvanje na momentalen dogovor
    UPDATE sportsperson_contract
    SET end_date = from_date
    WHERE id = old_contract_id;

    -- Kreiranje nov dogovor za pozajmuvanje
    INSERT INTO sportsperson_contract(player_ssn, club_id, start_date, end_date, payout)
    VALUES
        (p_ssn, borrowing_club_id, from_date, to_date, b_payout);

    -- Prodolzuvanje so star klub
    INSERT INTO sportsperson_contract(player_ssn, club_id, start_date, end_date, payout)
    VALUES
        (p_ssn, borrowed_club_id, to_date + Interval '1 day', old_end_date, old_payout);

    COMMIT;
END;
$$;
call borrow_player('191199745536', '87925', '87926', now()::date, '2026-06-06'::date, 17000);
-----------------------------------------------------------------------------
-- 6. promote sportperson to coach (samo ako nema aktiven contract sega)
CREATE OR REPLACE PROCEDURE promote_sportsperson_to_coach(
    p_ssn char(13),
    n_federation_id int4
) LANGUAGE plpgsql AS $$
BEGIN
    -- validacija input
    IF NOT EXISTS(SELECT 1 FROM sportsperson WHERE ssn = p_ssn) THEN
        RAISE EXCEPTION 'Invalid p_ssn - Player with ssn % does not exist!', p_ssn;
    end if;

    IF EXISTS(SELECT 1 FROM coach WHERE ssn = p_ssn) THEN
        RAISE EXCEPTION 'Invalid p_ssn - Player is already promoted';
    end if;

    IF NOT EXISTS(SELECT 1 FROM federation WHERE id = n_federation_id) THEN
        RAISE EXCEPTION 'Invalid n_federation_id - Federation with id % does not exist!', n_federation_id;
    end if;

    -- Ne smee da ima aktivni dogovori
    IF EXISTS(SELECT 1 FROM player_career_history WHERE ssn = p_ssn and contract_status = 'ACTIVE') THEN
        RAISE EXCEPTION 'Ineligible player - Player has an active contract!';
    end if;

    -- Dodavanje na coach
    INSERT INTO coach(ssn, sport_category_id, federation_id)
        SELECT
            p_ssn, sport_category_id, n_federation_id
        FROM sportsperson
        WHERE ssn = p_ssn
    ;
    COMMIT;
END;
$$;
CALL promote_sportsperson_to_coach('150100143541', 1816); -- okay
CALL promote_sportsperson_to_coach('150100143541', 1816); -- already promoted
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE start_new_season(
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
    INSERT INTO duel (
        home_team_id, away_team_id, location_id, competition_id,
        start_time, sport_category_id, home_team_score, away_team_score
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
           scat_id,
           NULL::int,
           NULL::int
    FROM resolved r
    LEFT JOIN score_logic sl ON sl.sport_id = (
               SELECT sc.sport_id FROM sport_category sc WHERE sc.id = scat_id);
END;
$$;
CALL start_new_season(2279810, 14); -- okay
CALL start_new_season(-22515235, 14); -- invalid id
CALL start_new_season(2279810, 25); -- invalid years
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE reschedule_duel(
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
    IF NOT EXISTS (SELECT 1 FROM duel WHERE id = d_id)
        THEN RAISE EXCEPTION 'Invalid d_id – duel does not exist';
    END IF;

    SELECT d.home_team_id, d.away_team_id, d.sport_category_id, d.start_time, scat.duration_minutes
    INTO ht_id, at_id, scat_id, old_start, scat_mins
    FROM duel d
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
        IF EXISTS (SELECT 1 FROM refereeing_duel rd
                   JOIN duel d2 ON d2.id = rd.duel_id
                   WHERE rd.referee_ssn = ref_ssn
                     AND rd.duel_id != d_id
                     AND ((new_ts  BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')
                       OR (new_end BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')))
            THEN RAISE EXCEPTION 'Referee % has another duel scheduled at %', ref_ssn, new_ts;
        END IF;
    END IF;

    IF EXISTS (SELECT 1 FROM duel d2
               WHERE (d2.home_team_id = ht_id OR d2.away_team_id = ht_id)
                 AND d2.id != d_id
                 AND ((new_ts  BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')
                   OR (new_end BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')))
        THEN RAISE EXCEPTION 'Home team has another duel scheduled at %', new_ts;
    END IF;

    IF EXISTS (SELECT 1 FROM duel d2
               WHERE (d2.home_team_id = at_id OR d2.away_team_id = at_id)
                 AND d2.id != d_id
                 AND ((new_ts  BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')
                   OR (new_end BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')))
        THEN RAISE EXCEPTION 'Away team has another duel scheduled at %', new_ts;
    END IF;

    UPDATE duel SET start_time = new_ts WHERE id = d_id;

    RAISE NOTICE 'Duel % rescheduled to %', d_id, new_ts;
END;
$$;
CALL reschedule_duel(47870948, '2027-05-20 18:00:00.000000'::timestamp); -- past duel
CALL reschedule_duel(32668983, '2022-05-20 18:00:00.000000'::timestamp); -- rescheduling future for past
CALL reschedule_duel(32668983, '2028-05-20 18:00:00.000000'::timestamp); -- okay
CALL reschedule_duel(32668983, '2026-08-11 12:00:00.000000'::timestamp); -- time overlap of same team on another duel
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE assign_referee_for_duel(
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
    IF NOT EXISTS (SELECT 1 FROM duel WHERE id = d_id)
        THEN RAISE EXCEPTION 'Invalid d_id – duel does not exist';
    END IF;

    SELECT d.sport_category_id, d.start_time, scat.duration_minutes, d.competition_id
    INTO scat_id, duel_start, scat_mins, comp_id
    FROM duel d
    JOIN sport_category scat ON scat.id = d.sport_category_id
    WHERE d.id = d_id;

    duel_end := duel_start + scat_mins * INTERVAL '1 minute';

    IF comp_id IS NULL THEN
        SELECT r.ssn INTO ref_ssn
        FROM referee r
        WHERE r.sport_category_id = scat_id
          AND NOT EXISTS (
              SELECT 1 FROM refereeing_duel rd
              JOIN duel d2 ON d2.id = rd.duel_id
              WHERE rd.referee_ssn = r.ssn
                AND d2.id != d_id
                AND ((duel_start BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')
                  OR (duel_end BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute'))
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
              SELECT 1 FROM refereeing_duel rd
              JOIN duel d2 ON d2.id = rd.duel_id
              WHERE rd.referee_ssn = r.ssn
                AND d2.id != d_id
                AND ((duel_start BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute')
                  OR (duel_end BETWEEN d2.start_time AND d2.start_time + scat_mins * INTERVAL '1 minute'))
          )
        ORDER BY random()
        LIMIT 1;
    END IF;

    IF ref_ssn IS NULL THEN
        RAISE EXCEPTION 'No referee found for duel %', d_id;
    END IF;

    INSERT INTO refereeing_duel VALUES (ref_ssn, d_id);
END;
$$;
CALL assign_referee_for_duel(47870948); -- okay
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_sponsorship_to_team(
    Nteam_id int,
    Nsponsor_id int,
    Nstart_date date,
    Nend_date date,
    Namount int
)
LANGUAGE plpgsql as $$
DECLARE
    team_name varchar(150);
    sponsor_name varchar(80);
BEGIN
    SELECT name INTO team_name
    from sport_team where id = Nteam_id;

    if team_name is NULL then
        raise exception 'Team with id % does not exist', Nteam_id;
    end if;

    SELECT name INTO sponsor_name
    from sponsor where id = Nsponsor_id;

    if sponsor_name is NULL then
        raise exception 'Sponsor with id % does not exist', Nteam_id;
    end if;

    IF Namount <= 0 THEN
        RAISE EXCEPTION 'Sponsorship amount must be greater than 0';
    END IF;

    IF NOT valid_date_range(Nstart_date, Nend_date) THEN
        RAISE EXCEPTION 'Invalid date range: start_date must be before end_date';
    END IF;

    if exists(
        Select 1
        from sponsorship
        where sport_team_id = Nteam_id and sponsor_id=Nsponsor_id
            and Nstart_date <= coalesce(Nend_date, 'infinity'::date)
            and coalesce(Nend_date, 'infinity'::date)>= Nstart_date
    )THEN
        RAISE EXCEPTION 'Sponsor "%" already has an active deal with team "%" in this period',
            sponsor_name, team_name;
    end if;

    Insert into sponsorship(sport_team_id, sponsor_id, start_date, end_date, amount)
    values (Nteam_id, Nsponsor_id, Nstart_date, Nend_date, Namount);

    RAISE NOTICE 'Sponsorship of % added: "%" now sponsors "%"',
        Namount, sponsor_name, team_name;

end;
$$;
CALL add_sponsorship_to_team(1, 3, '2024-09-13'::date, '2026-12-10'::date, 12345);
-----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE rename_sport_club(
    p_club_id int,
    p_name varchar(150)
)
LANGUAGE plpgsql as $$
DECLARE
    v_old_name varchar(150);
    v_country_id int;
    v_team_name varchar(150);
BEGIN
    Select name, country_id into v_old_name, v_country_id
    from sport_club
    where id = p_club_id;

    if v_old_name is null then
        Raise exception 'Club with id % does not exist', p_club_id;
    end if;

    if v_old_name Like 'National Representation%' then
        Raise EXCEPTION  'You cannot change name to National Representation';
    end if;

    IF p_name LIKE 'National Representation%' THEN
        RAISE EXCEPTION 'New name cannot start with "National Representation"';
    END IF;

    if exists(
        select 1
        from sport_club
        where name = p_name and id <> p_club_id and country_id = v_country_id
    ) then
        raise exception 'Club with name % already exists in the same country', p_name;
    end if;

    Update sport_club
    set name = p_name
    where id = p_club_id;


    UPDATE SPORT_TEAM
    SET name = p_name || substring(name FROM length(v_old_name) + 1)
    WHERE club_id = p_club_id
      AND name LIKE v_old_name || '%';

    RAISE NOTICE 'Club renamed from "%" to "%". % team(s) updated.',
        v_old_name, p_name,
        (SELECT COUNT(*) FROM SPORT_TEAM
         WHERE club_id = p_club_id AND name LIKE p_name || '%');

end;
$$;
call rename_sport_club(97434, 'AAAAAAAAAAAAA');
