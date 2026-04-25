-- TRIGGERS

--1
CREATE OR REPLACE FUNCTION check_contract_club()
RETURNS trigger AS $$
DECLARE
    club_country   INT;
    player_country INT;
    is_nat         BOOLEAN;
BEGIN
    SELECT is_national_representation, country_id
    INTO is_nat, club_country
    FROM sport_club
    WHERE id = NEW.club_id;

    SELECT country_id
    INTO player_country
    FROM person
    WHERE ssn = NEW.player_ssn;

    IF is_nat AND player_country <> club_country THEN
        RAISE EXCEPTION 'Player cannot be in another country national representation';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM sportsperson_contract c
        JOIN sport_club sc ON sc.id = c.club_id
        WHERE c.player_ssn = NEW.player_ssn
          AND (NEW.id IS NULL OR c.id <> NEW.id)
          AND NEW.start_date <= COALESCE(c.end_date, 'infinity'::date)
          AND COALESCE(NEW.end_date, 'infinity'::date) >= c.start_date
          AND sc.is_national_representation = is_nat
    ) THEN
        IF is_nat THEN
            RAISE EXCEPTION 'Player cannot have two national team contracts at same time';
        ELSE
            RAISE EXCEPTION 'Player already has an active club contract';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_contract
BEFORE INSERT OR UPDATE ON sportsperson_contract
FOR EACH ROW
EXECUTE FUNCTION check_contract_club();


--2
CREATE OR REPLACE FUNCTION check_team_roster_contract()
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
    FROM team_roster
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
        JOIN duel d ON d.id = NEW.duel_id
        WHERE c.player_ssn = NEW.player_ssn
          AND c.club_id = team_club_id
          AND c.start_date <= d.start_time::date
          AND COALESCE(c.end_date, 'infinity'::date) >= d.start_time::date
    ) THEN
        RAISE EXCEPTION 'Player must have an active contract with the club on the duel date';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM team_roster
        WHERE player_ssn = NEW.player_ssn
          AND duel_id = NEW.duel_id
          AND team_id <> NEW.team_id
    ) THEN
        RAISE EXCEPTION 'Player is already rostered in another team for this duel';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_team_roster
BEFORE INSERT OR UPDATE ON team_roster
FOR EACH ROW
EXECUTE FUNCTION check_team_roster_contract();


--3
--Change to compare sport_category_id from sport team no to go through federation
CREATE OR REPLACE FUNCTION check_duel_validity()
RETURNS TRIGGER AS $$
DECLARE
    match_date DATE;
--     duel_sport_id INT;

    home_club_id INT;
    away_club_id INT;

    home_is_rep BOOLEAN;
    away_is_rep BOOLEAN;

    home_federation_active BOOLEAN;
    away_federation_active BOOLEAN;
BEGIN
    match_date := NEW.start_time::DATE;

--     SELECT sport_id
--     INTO duel_sport_id
--     FROM sport_category
--     WHERE id = NEW.sport_category_id;

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

CREATE TRIGGER trg_check_team_sport_and_rep
BEFORE INSERT OR UPDATE ON DUEL
FOR EACH ROW
EXECUTE FUNCTION check_duel_validity();


--4
CREATE OR REPLACE FUNCTION check_referee_availability()
RETURNS TRIGGER AS $$
DECLARE
    new_duel_start TIMESTAMP;
    new_duel_end   TIMESTAMP;
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM referee r
        JOIN sport_category sc1 ON r.sport_category_id = sc1.id
        JOIN duel d ON d.id = NEW.duel_id
        JOIN sport_category sc2 ON d.sport_category_id = sc2.id
        WHERE r.ssn = NEW.referee_ssn AND sc1.id = sc2.id
    ) THEN
        RAISE EXCEPTION 'Referee sport category does not match duel sport category';
    END IF;

    SELECT d.start_time,
           d.start_time + sc.duration_minutes * INTERVAL '1 minute'
    INTO new_duel_start, new_duel_end
    FROM duel d
    JOIN sport_category sc ON d.sport_category_id = sc.id
    WHERE d.id = NEW.duel_id;

    IF EXISTS (
        SELECT 1
        FROM refereeing_duel rd
        JOIN duel d ON rd.duel_id = d.id
        JOIN sport_category sc ON d.sport_category_id = sc.id
        WHERE rd.referee_ssn = NEW.referee_ssn
          AND rd.duel_id <> NEW.duel_id
          AND new_duel_start <
              d.start_time + sc.duration_minutes * INTERVAL '1 minute'
          AND new_duel_end > d.start_time
    ) THEN
        RAISE EXCEPTION
            'Referee with SSN % is already assigned to an overlapping duel starting at %',
            NEW.referee_ssn, new_duel_start;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limit_referee_daily_duels
BEFORE INSERT OR UPDATE ON REFEREEING_DUEL
FOR EACH ROW
EXECUTE FUNCTION check_referee_availability();