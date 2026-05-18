-- 7 registracija na sportsperson, referee i coach

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


-- 1. obnovi contract so nova suma za ist tim
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

-- 2. pozajmica contract na input se dobiva interval zavrshuva contract so segashniot club
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

    IF NOT EXISTS(SELECT 1 FROM coach WHERE ssn = p_ssn) THEN
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