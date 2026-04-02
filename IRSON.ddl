CREATE FUNCTION valid_date_range(start_date date, end_date date)
RETURNS boolean AS $$
    SELECT end_date IS NULL OR start_date < end_date;
$$ LANGUAGE sql IMMUTABLE;

-- carchar(255) -> varcahr(50)
-- dodadi ON DELETE ON ALTER
-- izbrishan consstarint za datumi da se vrati (u triger smeneto)
-- sport tim promena season i standing ne treba
--
----- foregin key kt not null
----- "ON DELETE CASCADE" Ne KT UJP Ti trazi podatoci - Stavi ss default
--
-- REFEREE DA ne moze u ist dn da e na istu utakmicu
--

--------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE SPORT (
  id             SERIAL NOT NULL,
  name           varchar(255) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE SPORT_CATEGORY (
    id            SERIAL NOT NULL,
    name          varchar(255) NOT NULL,
    sport_id      int4 NOT NULL,
    gender        char(1) NOT NULL,
    specification varchar(255),
    PRIMARY KEY (id),
    CONSTRAINT GENDER_CHECK CHECK (gender IN ('M', 'F')),
    CONSTRAINT sport_fk FOREIGN KEY (sport_id) REFERENCES SPORT (id)
);

-- Veljko
CREATE TABLE COUNTRY (
  id          SERIAL NOT NULL,
  name        varchar(255) NOT NULL,
  abreviation varchar(5) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE SPONSOR (
  id   SERIAL NOT NULL,
  name varchar(255) NOT NULL,
  PRIMARY KEY (id)
);

-- Veljko
CREATE TABLE COMPETITION_TYPE (
    id         SERIAL NOT NULL,
    type_label varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

-- Antonio
CREATE TABLE PERSON (
    ssn           char(13) NOT NULL, -- smenet varchar -> char - Veljko
    first_name    varchar(255) NOT NULL,
    last_name     varchar(255) NOT NULL,
    date_of_birth date NOT NULL,
    gender        char(1) NOT NULL,
    country_id    int4 NOT NULL, -- dodadeno - Aleksandar
    PRIMARY KEY (ssn),

    FOREIGN KEY (country_id) REFERENCES COUNTRY(id), -- dodadeno Aleksandar
    CONSTRAINT date_of_birth CHECK (date_of_birth > '1900-01-01'), -- DODADEN CONSTRAINT
    CONSTRAINT gender_check CHECK (gender IN ('M', 'F')) --DODADEN CONSTRAINT
);

-- Antonio
CREATE TABLE FEDERATION (
    id       SERIAL NOT NULL,
    sport_id int4 NOT NULL,
    name     varchar(255) NOT NULL,
    PRIMARY KEY (id),

    CONSTRAINT unique_federation_name UNIQUE (name), -- dodaden konstraint - Antonio
    CONSTRAINT sport_fk FOREIGN KEY (sport_id) REFERENCES SPORT (id)
);

-- Antonio
CREATE TABLE INTERNATIONAL_FEDERATION ( -- Smeneto ime - Antonio
    id SERIAL NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT federation_fk FOREIGN KEY (id) REFERENCES FEDERATION (id)
);

-- Antonio
CREATE TABLE NATIONAL_FEDERATION ( -- Smeneto ime - Antonio
    id                          SERIAL NOT NULL,
    country_id                  int4 NOT NULL,
    international_federation_id int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id),
    CONSTRAINT international_fed_fk FOREIGN KEY (international_federation_id) REFERENCES INTERNATIONAL_FEDERATION (id),
    CONSTRAINT federation_fk FOREIGN KEY (id) REFERENCES FEDERATION (id)
);

-- Antonio
CREATE TABLE LOCATION (
    id         SERIAL NOT NULL,
    country_id int4 NOT NULL,
    name       varchar(255) NOT NULL,
    capacity   int4 NOT NULL,
    address    varchar(255) NOT NULL,
    PRIMARY KEY (id),

    CONSTRAINT check_capacity CHECK(capacity>0), -- DODADEN CONSTRAINT
    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id),
    CONSTRAINT unique_name_per_country UNIQUE (country_id, name)
);

-- Antonio
CREATE TABLE REGION (
    id              SERIAL NOT NULL,
    name            varchar(255) NOT NULL, -- DODADENO LAB
    part_of_country bool NOT NULL,
    PRIMARY KEY (id)
);

-- Veljko
CREATE TABLE COUNTRY_REGION ( -- Smeneno ime - Veljko+Antonio
    country_id int4 NOT NULL,
    region_id  int4 NOT NULL,
    PRIMARY KEY (country_id, region_id),

    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id),
    CONSTRAINT region_fk FOREIGN KEY (region_id) REFERENCES REGION (id)
);

-- Antonio
CREATE TABLE NATIONAL_LEAGUE (
    id             SERIAL NOT NULL,
    federation_id  int4 NOT NULL,
    name           varchar(255) NOT NULL,
    date_started   date NOT NULL,
    date_dispanded date,
    region_id      int4,
    PRIMARY KEY (id),

    CONSTRAINT date_constraint CHECK ( valid_date_range(date_started, date_dispanded) ),
    CONSTRAINT nat_federation_fk FOREIGN KEY (federation_id) REFERENCES NATIONAL_FEDERATION (id),
    CONSTRAINT region_fk FOREIGN KEY (region_id) REFERENCES REGION (id)
);

CREATE TABLE SPORT_CLUB (
    id                         SERIAL       NOT NULL,
    federation_id              int4         NOT NULL,
    name                       varchar(255) NOT NULL,
    is_national_representation bool         NOT NULL,
    country_id                 int4         NOT NULL, -- dodadeno - Aleksandar
    PRIMARY KEY (id),
    FOREIGN KEY (country_id) REFERENCES COUNTRY (id),  -- dodadeno Aleksandar
    CONSTRAINT nat_fed_fk FOREIGN KEY (federation_id) REFERENCES NATIONAL_FEDERATION (id)
);

-- Veljko
CREATE TABLE CLUB_FEDERATION (
    federation_id int4 NOT NULL, -- smeneto ime - Veljko
    club_id       int4 NOT NULL, -- smeneto ime - Veljko
    start_date    date   NOT NULL,
    end_date      date,
    PRIMARY KEY (federation_id, club_id),

    CONSTRAINT date_c CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT federation_fk FOREIGN KEY (federation_id) REFERENCES FEDERATION (id),
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id)
);

CREATE TABLE SEASON (
    id                 SERIAL NOT NULL,
    national_league_id SERIAL NOT NULL,
    start_date         date NOT NULL,
    end_date           date,
    PRIMARY KEY (id),
    CONSTRAINT date_c CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT league_fk FOREIGN KEY (national_league_id) REFERENCES NATIONAL_LEAGUE (id),
    CONSTRAINT federation_fk FOREIGN KEY (id) REFERENCES FEDERATION (id)
);

CREATE TABLE SPORT_TEAM (
    id        SERIAL NOT NULL,
    club_id   int4 NOT NULL,
    season_id int4 NOT NULL,
    name      varchar(255) NOT NULL,
    capacity  int4 NOT NULL,
    standing  int4,
    PRIMARY KEY (id),

    CONSTRAINT capacity_c CHECK (capacity > 0),
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id),
    CONSTRAINT season_fk FOREIGN KEY (season_id) REFERENCES SEASON (id)
);

-- Veljko
CREATE TABLE COACH (
    ssn               char(13) NOT NULL, -- smenet varchar -> char - Veljko
    sport_category_id int4 NOT NULL,
    federation_id     int4 NOT NULL,
    PRIMARY KEY (ssn),
    CONSTRAINT federation_fk FOREIGN KEY (federation_id) REFERENCES FEDERATION (id),
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id)
);

-- Veljko
CREATE TABLE COACHING_TEAM (
    team_id    int4 NOT NULL,
    coach_ssn  char(13) NOT NULL, -- smenet varchar -> char - Veljko
    start_date date NOT NULL,
    end_date   date,
    PRIMARY KEY (team_id, coach_ssn),

    CONSTRAINT date_c CHECK (valid_date_range(start_date, end_date)),
    CONSTRAINT team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id),
    CONSTRAINT coach_fk FOREIGN KEY (coach_ssn) REFERENCES COACH (ssn)
);

-- Veljko
CREATE TABLE DONATION (
    club_id       int4 NOT NULL,
    sponsor_id    int4 NOT NULL,
    donation_date date NOT NULL,
    amount        int4 NOT NULL,
    PRIMARY KEY (club_id, sponsor_id, donation_date),

    CONSTRAINT amount_c CHECK ( amount > 0 ),
    CONSTRAINT team_fk FOREIGN KEY (club_id) REFERENCES SPORT_TEAM (id),
    CONSTRAINT sponsor_fk FOREIGN KEY (sponsor_id) REFERENCES SPONSOR (id)
);

CREATE TABLE SPORTSPERSON (
    ssn               char(13) NOT NULL, -- smenet varchar -> char - Veljko
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (ssn),

    CONSTRAINT person_fk FOREIGN KEY (ssn) REFERENCES PERSON (ssn),
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id)
);

CREATE TABLE SPORTSPERSON_CONTRACT (
    id         SERIAL NOT NULL,
    player_ssn char(13) NOT NULL, -- smenet varchar -> char - Veljko
    club_id    int4 NOT NULL,
    start_date date NOT NULL,
    end_date   date NOT NULL,
    payout     int4 NOT NULL,
    PRIMARY KEY (id),

    CONSTRAINT sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn),
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id),
    CONSTRAINT date_c CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT payout_c CHECK ( payout > 0 )
);

CREATE TABLE TEAM_ROSTER (
    player_ssn char(13) NOT NULL, -- smenet varchar -> char - Veljko
    team_id    int4 NOT NULL,
    start_date date NOT NULL,
    end_date   date,
    PRIMARY KEY (player_ssn,  team_id),

    CONSTRAINT date_c CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn),
    CONSTRAINT team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id)
);

-- Veljko
CREATE TABLE COMPETITION (
    id                      SERIAL       NOT NULL,
    type                    int4         NOT NULL,
    organizer_federation_id int4         NOT NULL,
    season_id               int4,
    name                    varchar(255) NOT NULL,
    start_date              date         NOT NULL,
    end_date                date,
    PRIMARY KEY (id),

    CONSTRAINT date_c CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT type_fk FOREIGN KEY (type) REFERENCES COMPETITION_TYPE (id),
    CONSTRAINT org_fk FOREIGN KEY (organizer_federation_id) REFERENCES FEDERATION (id),
    CONSTRAINT season_fk FOREIGN KEY (season_id) REFERENCES SEASON (id)
);

-- Veljko
CREATE TABLE DUEL (
    id                SERIAL NOT NULL,
    home_team_id      int4 NOT NULL,
    away_team_id      int4 NOT NULL,
    location_id       int4 NOT NULL,
    competition_id    int4,
    start_time        timestamp NOT NULL,
    score             int4 NOT NULL,
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (id),

    CONSTRAINT competition_fk FOREIGN KEY (competition_id) REFERENCES COMPETITION (id),
    CONSTRAINT home_team_fk FOREIGN KEY (home_team_id) REFERENCES SPORT_TEAM (id),
    CONSTRAINT away_team_fk FOREIGN KEY (away_team_id) REFERENCES SPORT_TEAM (id),
    CONSTRAINT location_fk FOREIGN KEY (location_id) REFERENCES LOCATION (id),
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id),

    CONSTRAINT score_c CHECK ( score >= 0 ),
    CONSTRAINT different_teams_c CHECK ( home_team_id != away_team_id )
);

-- Antonio
CREATE TABLE REFEREE (
    ssn               char(13) NOT NULL, -- smenet varchar -> char - Veljko
    federation_id     int4 NOT NULL,
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (ssn),

    CONSTRAINT person_fk FOREIGN KEY (ssn) REFERENCES PERSON (ssn),
    CONSTRAINT federation_kf FOREIGN KEY (federation_id) REFERENCES FEDERATION (id),
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id)
);

-- Antonio
CREATE TABLE REFEREEING_DUEL (
    referee_ssn char(13) NOT NULL, -- smenet varchar -> char - Veljko
    duel_id     int4 NOT NULL,
    PRIMARY KEY (referee_ssn, duel_id),

    CONSTRAINT duel_fk FOREIGN KEY (duel_id) REFERENCES DUEL (id),
    CONSTRAINT referee_fk FOREIGN KEY (referee_ssn) REFERENCES REFEREE (ssn)
);

--------------------------------------------------------------------------------------------------------------------------------------------

-- NOTE: Izbrishano zaradi check_contract_club shto pokriva kapacitet - Veljko
--ALEKSANDAR KAPACITET NA TIM
-- CREATE OR REPLACE FUNCTION check_team_capacity()
-- RETURNS TRIGGER AS $$
--     DECLARE
--         max_capacity int4;
--         current_players int4;
--     BEGIN
--         SELECT COUNT(*) INTO current_players --current_capacity
--         FROM TEAM_ROSTER tf
--         WHERE tf.team_id = NEW.team_id
--             AND NEW.startDate >= tf.start_Date
--             AND tf.end_date IS NULL
--         ;
--
--         SELECT capacity INTO max_capacity
--         FROM SPORT_TEAM st
--         WHERE st.id = NEW.team_id
--         ;
--
--         IF current_players >= max_capacity THEN
--             RAISE EXCEPTION 'Cannot insert more players than initial capacity';
--         END IF;
--
--         RETURN NEW;
--     END;
-- $$ LANGUAGE plpgsql IMMUTABLE;
--
-- CREATE TRIGGER trg_check_team_capacity
-- BEFORE INSERT OR UPDATE ON TEAM_ROSTER
-- FOR EACH ROW
--     EXECUTE FUNCTION check_team_capacity();

--ALEKSANDAR CONTRACT:
-- DOZVOLENA KOMBINACIJA CLUB I REPREZENTACIJA VO ISTO VREME
-- VO SPORTIVNO NEMA DA SE DODADE DOKOLKU NEMA ZAVRSHENO CONTRACTOT A INICIRAME NOV
-- SE POREVERUVA DRZHAVATA OD KOJA E SPORTSMANOT DA NE MOZHE ZA TUGJA REPREZENTACIJA
CREATE OR REPLACE FUNCTION check_contract_club()
RETURNS trigger AS $$
DECLARE
    club_country INT;
    player_country INT;
    is_nat BOOLEAN;
BEGIN
    SELECT is_national_representation, country_id
    INTO is_nat, club_country
    FROM sport_club
    WHERE id = NEW.club_id
    ;

    SELECT country_id
    INTO player_country
    FROM person
    WHERE ssn = NEW.player_ssn
    ;

    -- ako e nacionalna rep. igrach mora da e od taa drzava
    IF is_nat AND player_country <> club_country THEN
        RAISE EXCEPTION 'Player cannot be in another country national representation';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM sportsperson_contract c
        JOIN sport_club sc
        ON sc.id = c.club_id
        WHERE c.player_ssn = NEW.player_ssn
          AND (NEW.id IS NULL OR c.id <> NEW.id)
          AND NEW.start_date <= c.end_date
          AND NEW.end_date >= c.start_date
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

--ALEKSANDAR TEAM ROSTER:
-- KAPACITETOT NA TIMOT DA NE SE NADMINE
-- DA SE PROVERI DALI IMAME CONTRACT ZA TOJ TIM SHTO KJE BIDEME STAVENI VO ROSTER
CREATE OR REPLACE FUNCTION check_team_roster_contract()
RETURNS trigger AS $$
DECLARE
    team_club_id INT;
    max_capacity INT;
    current_players INT;
BEGIN
    SELECT club_id
    INTO team_club_id
    FROM sport_team
    WHERE id = NEW.team_id
    ;

    -- NOTE: Beshe nevalidan sql, popraven
    SELECT COUNT(*)
    INTO current_players --current_capacity - Ne beshe dobro mislu dek e ok sga?
    FROM TEAM_ROSTER tf
    WHERE tf.team_id = NEW.team_id
        AND NEW.startDate >= tf.start_Date
        AND tf.end_date IS NULL
    ;

    SELECT capacity INTO max_capacity
    FROM SPORT_TEAM st
    WHERE id = NEW.team_id
    ;

    IF current_players >= max_capacity THEN
        RAISE EXCEPTION 'Cannot insert more players than initial capacity';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM sportsperson_contract c
        WHERE
          c.player_ssn = NEW.player_ssn
          AND c.club_id = team_club_id
          AND NEW.start_date < c.end_date
          AND NEW.end_date > c.start_date
    ) THEN
        RAISE EXCEPTION 'Player must have active contract with the club for this roster period';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_team_roster
BEFORE INSERT OR UPDATE ON team_roster
FOR EACH ROW
EXECUTE FUNCTION check_team_roster_contract();

--Aleksandar DUEL:
-- Proverkak na validnost na timovite vo duel
CREATE OR REPLACE FUNCTION check_team_in_federation()
RETURNS TRIGGER AS $$
DECLARE
    home_club_id INT;
    away_club_id INT;
    match_date DATE;
    home_exists BOOLEAN;
    away_exists BOOLEAN;
BEGIN
    SELECT club_id INTO home_club_id
    FROM SPORT_TEAM
    WHERE id = NEW.home_team_id
    ;

    SELECT club_id INTO away_club_id
    FROM SPORT_TEAM
    WHERE id = NEW.away_team_id
    ;

    match_date := NEW.start_time::DATE;

    SELECT EXISTS (
        SELECT 1
        FROM CLUB_FEDERATION
        WHERE club_id = home_club_id
        AND start_date <= match_date
        AND (end_date IS NULL OR end_date >= match_date)
    ) INTO home_exists
    ;

    SELECT EXISTS (
        SELECT 1 FROM CLUB_FEDERATION
        WHERE club_id = away_club_id
        AND start_date <= match_date
        AND (end_date IS NULL OR end_date >= match_date)
    ) INTO away_exists
    ;

    IF NOT home_exists THEN
        RAISE EXCEPTION 'Home team club does not have an active federation participation on the match date.';
    END IF;

    IF NOT away_exists THEN
        RAISE EXCEPTION 'Away team club does not have an active federation participation on the match date.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_team_participation
BEFORE INSERT OR UPDATE ON DUEL
FOR EACH ROW
EXECUTE FUNCTION check_team_in_federation();

--Veljko
-- Proverka timovi da imaat ista is_national_representation status
-- Proveka dvata tima da igraat ist sport shto e duel-ot
CREATE OR REPLACE FUNCTION check_if_teams_valid_in_duel()
RETURNS TRIGGER AS $$
    DECLARE
        home_team_is_rep BOOLEAN;
        away_team_is_rep BOOLEAN;
        home_club_id INT;
        away_club_id INT;
        duel_sport_id INT;
    BEGIN
        -- get home team representation status and club id
        SELECT is_national_representation, c.id
            INTO home_team_is_rep, home_club_id
        FROM SPORT_CLUB c
        JOIN SPORT_TEAM t
            ON t.id == NEW.home_team_id
        WHERE t.club_id == c.id
        ;

        -- get away team representation status and club id
        SELECT is_national_representation, c.id
            INTO away_team_is_rep, away_club_id
        FROM SPORT_CLUB c
        JOIN SPORT_TEAM t
            ON t.id == NEW.away_team_id
        WHERE t.club_id == c.id
        ;

        -- representation status check
        IF home_team_is_rep != away_team_is_rep THEN
            RAISE EXCEPTION 'Teams must have the same representation status';
        END IF;

        -- za koj sport duel e
        SELECT s.sport_id
        INTO duel_sport_id
        FROM SPORT_CATEGORY s
        WHERE NEW.sport_category_id = s.id;

        -- home sport check
        IF NOT EXISTS(
            SELECT 1
            FROM SPORT_CLUB c
            JOIN FEDERATION f
            on f.id == c.federation_id
            WHERE
              c.id == home_club_id
              AND f.sport_id == duel_sport_id
        ) THEN
            RAISE EXCEPTION  'Home team must play same sport as duel';
        END IF;

        -- away sport check
        IF NOT EXISTS(
            SELECT 1
            FROM SPORT_CLUB c
            JOIN FEDERATION f
            on f.id == c.federation_id
            WHERE
              c.id == away_club_id
              AND f.sport_id == duel_sport_id
        ) THEN
            RAISE EXCEPTION  'Away team must play same sport as duel';
        END IF;

        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_team_sport_and_rep
BEFORE INSERT OR UPDATE ON DUEL
FOR EACH ROW
EXECUTE FUNCTION check_if_teams_valid_in_duel();

--ALEKSANDAR
-- REFEREE U IST DEN DA NE MOZHE DA SUDI NA 2 MATCHA
CREATE OR REPLACE FUNCTION check_referee_availability()
RETURNS TRIGGER AS $$
DECLARE
    new_duel_date DATE;
BEGIN
    SELECT start_time::DATE INTO new_duel_date
    FROM DUEL
    WHERE id = NEW.duel_id;

    IF EXISTS (
        SELECT 1
        FROM REFEREEING_DUEL rd
        JOIN DUEL d ON rd.duel_id = d.id
        WHERE rd.referee_ssn = NEW.referee_ssn
          AND d.start_time::DATE = new_duel_date
          AND rd.duel_id != NEW.duel_id
    ) THEN
        RAISE EXCEPTION 'Referee with SSN % is already assigned to a duel on %', NEW.referee_ssn, new_duel_date;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limit_referee_daily_duels
BEFORE INSERT OR UPDATE ON REFEREEING_DUEL
FOR EACH ROW
EXECUTE FUNCTION check_referee_availability();