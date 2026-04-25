CREATE OR REPLACE FUNCTION valid_date_range(start_date date, end_date date)
RETURNS boolean
LANGUAGE sql
AS $$
    SELECT end_date IS NULL OR start_date < end_date;
$$;

CREATE TABLE SPORT (
  id             SERIAL NOT NULL,
  name           varchar(30) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE SPORT_CATEGORY (
    id            SERIAL NOT NULL,
    name          varchar(60) NOT NULL,
    sport_id      int4 NOT NULL,
    gender        char(1) NOT NULL,
    duration_minutes INTEGER CHECK (duration_minutes BETWEEN 0 AND 999) NOT NULL,
    specification varchar(100),
    team_capacity INTEGER CHECK (team_capacity BETWEEN 1 AND 99) NOT NULL ,
    points_per_win INTEGER CHECK (points_per_win BETWEEN 1 AND 9) NOT NULL,
    points_per_draw INTEGER CHECK (points_per_draw BETWEEN 0 AND 9) NOT NULL,
    points_per_losing INTEGER CHECK (points_per_losing BETWEEN 0 AND 9) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT GENDER_CHECK CHECK (gender IN ('M', 'F')),
    CONSTRAINT sport_fk FOREIGN KEY (sport_id) REFERENCES SPORT (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE COUNTRY (
  id          SERIAL NOT NULL,
  name        varchar(50) NOT NULL,
  abreviation varchar(5) NOT NULL,
  PRIMARY KEY (id)
);

CREATE TABLE SPONSOR (
  id   SERIAL NOT NULL,
  name varchar(30) NOT NULL UNIQUE,
  PRIMARY KEY (id)
);

CREATE TABLE COMPETITION_TYPE (
    id         SERIAL NOT NULL,
    type_label varchar(70) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE PERSON (
    ssn           char(13) NOT NULL,
    first_name    varchar(30) NOT NULL,
    last_name     varchar(30) NOT NULL,
    date_of_birth date NOT NULL,
    gender        char(1) NOT NULL,
    country_id    int4 NOT NULL,
    PRIMARY KEY (ssn),
    FOREIGN KEY (country_id) REFERENCES COUNTRY(id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT date_of_birth CHECK (date_of_birth > '1900-01-01'),
    CONSTRAINT gender_check CHECK (gender IN ('M', 'F'))
);

CREATE TABLE FEDERATION (
    id       SERIAL NOT NULL,
    sport_id int4 NOT NULL,
    name     varchar(50) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT unique_federation_name UNIQUE (name),
    CONSTRAINT sport_fk FOREIGN KEY (sport_id) REFERENCES SPORT (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE INTERNATIONAL_FEDERATION (
    id SERIAL NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT federation_fk FOREIGN KEY (id) REFERENCES FEDERATION (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE NATIONAL_FEDERATION (
    id                          SERIAL NOT NULL,
    country_id                  int4 NOT NULL,
    international_federation_id int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT international_fed_fk FOREIGN KEY (international_federation_id) REFERENCES INTERNATIONAL_FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT federation_fk FOREIGN KEY (id) REFERENCES FEDERATION (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE LOCATION (
    id         SERIAL NOT NULL,
    country_id int4 NOT NULL,
    name       varchar(50) NOT NULL,
    capacity   int4 NOT NULL,
    address    varchar(100) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT check_capacity CHECK(capacity>0),
    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT unique_name_per_country UNIQUE (country_id, name)
);

CREATE TABLE REGION (
    id              SERIAL NOT NULL,
    name            varchar(70) NOT NULL,
    part_of_country bool NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE COUNTRY_REGION (
    country_id int4 NOT NULL,
    region_id  int4 NOT NULL,
    PRIMARY KEY (country_id, region_id),
    CONSTRAINT country_fk FOREIGN KEY (country_id) REFERENCES COUNTRY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT region_fk FOREIGN KEY (region_id) REFERENCES REGION (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE NATIONAL_LEAGUE (
    id             SERIAL NOT NULL,
    federation_id  int4 NOT NULL,
    name           varchar(50) NOT NULL,
    date_started   date NOT NULL,
    date_disbanded date,
    region_id      int4,
    PRIMARY KEY (id),
    CONSTRAINT date_constraint CHECK ( valid_date_range(date_started, date_disbanded) ),
    CONSTRAINT nat_federation_fk FOREIGN KEY (federation_id) REFERENCES NATIONAL_FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT region_fk FOREIGN KEY (region_id) REFERENCES REGION (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SPORT_CLUB (
    id                         SERIAL       NOT NULL,
    name                       varchar(40)  NOT NULL,
    is_national_representation bool         NOT NULL,
    country_id                 int4         NOT NULL,
    PRIMARY KEY (id),
    UNIQUE(name, country_id),
    FOREIGN KEY (country_id) REFERENCES COUNTRY (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE CLUB_FEDERATION (
    federation_id int4 NOT NULL,
    club_id       int4 NOT NULL,
    start_date    date   NOT NULL,
    end_date      date,
    PRIMARY KEY (federation_id, club_id),
    CONSTRAINT club_federation_date_check CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT federation_fk FOREIGN KEY (federation_id) REFERENCES FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SEASON (
    id                 SERIAL NOT NULL,
    national_league_id INTEGER NOT NULL,
    start_date         date NOT NULL,
    end_date           date,
    PRIMARY KEY (id),
    CONSTRAINT season_date_check CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT league_fk FOREIGN KEY (national_league_id) REFERENCES NATIONAL_LEAGUE (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SPORT_TEAM (
    id                    SERIAL NOT NULL,
    club_id               int4 NOT NULL,
    name                  varchar(40) NOT NULL,
    sport_category_id     int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT spk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SEASON_SPORT_TEAM (
    season_id int4 NOT NULL,
    sport_team_id int4 NOT NULL,
    PRIMARY KEY (season_id, sport_team_id),
    CONSTRAINT season_fk FOREIGN KEY (season_id) REFERENCES SEASON (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT sport_team_fk FOREIGN KEY (sport_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE COACH (
    ssn               char(13) NOT NULL,
    sport_category_id int4 NOT NULL,
    federation_id     int4 NOT NULL,
    PRIMARY KEY (ssn),
    CONSTRAINT federation_fk FOREIGN KEY (federation_id) REFERENCES FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT person_fk FOREIGN KEY (ssn) REFERENCES PERSON (ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE COACHING_TEAM (
    team_id    int4 NOT NULL,
    coach_ssn  char(13) NOT NULL,
    start_date date NOT NULL,
    end_date   date,
    PRIMARY KEY (team_id, coach_ssn),
    CONSTRAINT coaching_team_date_check CHECK (valid_date_range(start_date, end_date)),
    CONSTRAINT team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT coach_fk FOREIGN KEY (coach_ssn) REFERENCES COACH (ssn) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SPONSORSHIP (
    id            SERIAL NOT NULL,
    sport_team_id int4 NOT NULL,
    sponsor_id    int4 NOT NULL,
    start_date	  date NOT NULL,
    end_date	  date,
    amount        int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT amount_c CHECK ( amount > 0 ),
    CONSTRAINT sponsorship_date_check CHECK (valid_date_range(start_date, end_date)),
    CONSTRAINT team_fk FOREIGN KEY (sport_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT sponsor_fk FOREIGN KEY (sponsor_id) REFERENCES SPONSOR (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SPORTSPERSON (
    ssn               char(13) NOT NULL,
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (ssn),
    CONSTRAINT person_fk FOREIGN KEY (ssn) REFERENCES PERSON (ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE SPORTSPERSON_CONTRACT (
    id         SERIAL NOT NULL,
    player_ssn char(13) NOT NULL,
    club_id    int4 NOT NULL,
    start_date date NOT NULL,
    end_date   date,
    payout     int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT club_fk FOREIGN KEY (club_id) REFERENCES SPORT_CLUB (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT contract_date_check CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT payout_c CHECK ( payout > 0 )
);

CREATE TABLE COMPETITION (
    id                      SERIAL       NOT NULL,
    type                    int4         NOT NULL,
    organizer_federation_id int4         NOT NULL,
    season_id               int4,
    name                    varchar(40)  NOT NULL,
    start_date              date         NOT NULL,
    end_date                date,
    PRIMARY KEY (id),
    CONSTRAINT competition_date_check CHECK ( valid_date_range(start_date, end_date) ),
    CONSTRAINT type_fk FOREIGN KEY (type) REFERENCES COMPETITION_TYPE (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT org_fk FOREIGN KEY (organizer_federation_id) REFERENCES FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT season_fk FOREIGN KEY (season_id) REFERENCES SEASON (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE DUEL (
    id                SERIAL NOT NULL,
    home_team_id      int4 NOT NULL,
    away_team_id      int4 NOT NULL,
    location_id       int4 NOT NULL,
    competition_id    int4,
    start_time        timestamp NOT NULL,
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT competition_fk FOREIGN KEY (competition_id) REFERENCES COMPETITION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT home_team_fk FOREIGN KEY (home_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT away_team_fk FOREIGN KEY (away_team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT location_fk FOREIGN KEY (location_id) REFERENCES LOCATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT different_teams_c CHECK ( home_team_id != away_team_id )
);

CREATE TABLE SCORE (
    id          SERIAL NOT NULL,
    duel_id     int4 NOT NULL,
    player_ssn  char(13) NOT NULL,
    time_score  time NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT player_ssn FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT duel_id FOREIGN KEY (duel_id) REFERENCES DUEL (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE TEAM_ROSTER (
    player_ssn char(13) NOT NULL,
    team_id    int4 NOT NULL,
    duel_id    int4 NOT NULL,
    start_time time NOT NULL,
    end_time   time,
    PRIMARY KEY (player_ssn,  team_id, duel_id),
    CONSTRAINT roster_date_check CHECK ( end_time IS NULL OR start_time < end_time),
    CONSTRAINT sportsperson_fk FOREIGN KEY (player_ssn) REFERENCES SPORTSPERSON (ssn) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT team_fk FOREIGN KEY (team_id) REFERENCES SPORT_TEAM (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT duel_id FOREIGN KEY (duel_id) REFERENCES DUEL (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE REFEREE (
    ssn               char(13) NOT NULL,
    federation_id     int4 NOT NULL,
    sport_category_id int4 NOT NULL,
    PRIMARY KEY (ssn),
    CONSTRAINT person_fk FOREIGN KEY (ssn) REFERENCES PERSON (ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT federation_kf FOREIGN KEY (federation_id) REFERENCES FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT category_fk FOREIGN KEY (sport_category_id) REFERENCES SPORT_CATEGORY (id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE REFEREEING_DUEL (
    referee_ssn char(13) NOT NULL,
    duel_id     int4 NOT NULL,
    PRIMARY KEY (referee_ssn, duel_id),
    CONSTRAINT duel_fk FOREIGN KEY (duel_id) REFERENCES DUEL (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT referee_fk FOREIGN KEY (referee_ssn) REFERENCES REFEREE (ssn) ON DELETE RESTRICT ON UPDATE CASCADE
);

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

-- Data Inserted

INSERT INTO SPORT (name) VALUES
('Football'),
('Basketball'),
('Handball'),
('Volleyball'),
('Tennis'),
('Athletics'),
('Boxing'),
('Rugby'),
('Hockey'),
('Baseball'),
('Softball'),
('Cricket'),
('Golf'),
('Cycling'),
('Weightlifting'),
('Wrestling'),
('Judo'),
('Karate'),
('Taekwondo'),
('Fencing'),
('Archery'),
('Rowing'),
('Sailing'),
('Skiing'),
('Ice Hockey'),
('Triathlon'),
('Badminton'),
('Table Tennis'),
('Squash'),
('Water Polo'),
('Gymnastics'),
('Equestrian'),
('Canoeing'),
('Curling'),
('Biathlon'),
('Polo'),
('Lacrosse'),
('Futsal'),
('Beach Volleyball'),
('Kickboxing');

INSERT INTO COUNTRY (name, abreviation) VALUES
('Afghanistan', 'AFG'), ('Albania', 'ALB'), ('Algeria', 'ALG'),
('Andorra', 'AND'), ('Angola', 'ANG'), ('Argentina', 'ARG'),
('Armenia', 'ARM'), ('Australia', 'AUS'), ('Austria', 'AUT'),
('Azerbaijan', 'AZE'), ('Bahamas', 'BAH'), ('Bahrain', 'BRN'),
('Bangladesh', 'BAN'), ('Belarus', 'BLR'), ('Belgium', 'BEL'),
('Belize', 'BLZ'), ('Benin', 'BEN'), ('Bhutan', 'BHU'),
('Bolivia', 'BOL'), ('Bosnia', 'BIH'), ('Botswana', 'BOT'),
('Brazil', 'BRA'), ('Brunei', 'BRU'), ('Bulgaria', 'BUL'),
('Burkina Faso', 'BUR'), ('Burundi', 'BDI'), ('Cambodia', 'CAM'),
('Cameroon', 'CMR'), ('Canada', 'CAN'), ('Cape Verde', 'CPV'),
('Chad', 'CHA'), ('Chile', 'CHI'), ('China', 'CHN'),
('Colombia', 'COL'), ('Comoros', 'COM'), ('Congo', 'CGO'),
('Costa Rica', 'CRC'), ('Croatia', 'CRO'), ('Cuba', 'CUB'),
('Cyprus', 'CYP'), ('Czech Republic', 'CZE'), ('Denmark', 'DEN'),
('Djibouti', 'DJI'), ('Dominican Republic', 'DOM'), ('Ecuador', 'ECU'),
('Egypt', 'EGY'), ('El Salvador', 'ESA'), ('Estonia', 'EST'),
('Ethiopia', 'ETH'), ('Fiji', 'FIJ'), ('Finland', 'FIN'),
('France', 'FRA'), ('Gabon', 'GAB'), ('Gambia', 'GAM'),
('Georgia', 'GEO'), ('Germany', 'GER'), ('Ghana', 'GHA'),
('Greece', 'GRE'), ('Guatemala', 'GUA'), ('Guinea', 'GUI'),
('Haiti', 'HAI'), ('Honduras', 'HON'), ('Hungary', 'HUN'),
('Iceland', 'ISL'), ('India', 'IND'), ('Indonesia', 'INA'),
('Iran', 'IRI'), ('Iraq', 'IRQ'), ('Ireland', 'IRL'),
('Israel', 'ISR'), ('Italy', 'ITA'), ('Jamaica', 'JAM'),
('Japan', 'JPN'), ('Jordan', 'JOR'), ('Kazakhstan', 'KAZ'),
('Kenya', 'KEN'), ('Kosovo', 'KOS'), ('Kuwait', 'KUW'),
('Kyrgyzstan', 'KGZ'), ('Laos', 'LAO'), ('Latvia', 'LAT'),
('Lebanon', 'LIB'), ('Lesotho', 'LES'), ('Liberia', 'LBR'),
('Libya', 'LBA'), ('Lithuania', 'LTU'), ('Luxembourg', 'LUX'),
('Madagascar', 'MAD'), ('Malawi', 'MAW'), ('Malaysia', 'MAS'),
('Maldives', 'MDV'), ('Mali', 'MLI'), ('Malta', 'MLT'),
('Mauritania', 'MTN'), ('Mauritius', 'MRI'), ('Mexico', 'MEX'),
('Moldova', 'MDA'), ('Monaco', 'MON'), ('Mongolia', 'MGL'),
('Montenegro', 'MNE'), ('Morocco', 'MAR'), ('Mozambique', 'MOZ'),
('Myanmar', 'MYA'), ('Namibia', 'NAM'), ('Nepal', 'NEP'),
('Netherlands', 'NED'), ('New Zealand', 'NZL'), ('Nicaragua', 'NCA'),
('Niger', 'NIG'), ('Nigeria', 'NGR'), ('North Korea', 'PRK'),
('North Macedonia', 'MKD'), ('Norway', 'NOR'), ('Oman', 'OMA'),
('Pakistan', 'PAK'), ('Palestine', 'PLE'), ('Panama', 'PAN'),
('Paraguay', 'PAR'), ('Peru', 'PER'), ('Philippines', 'PHI'),
('Poland', 'POL'), ('Portugal', 'POR'), ('Qatar', 'QAT'),
('Romania', 'ROU'), ('Russia', 'RUS'), ('Rwanda', 'RWA'),
('Saudi Arabia', 'KSA'), ('Senegal', 'SEN'), ('Serbia', 'SRB'),
('Sierra Leone', 'SLE'), ('Singapore', 'SGP'), ('Slovakia', 'SVK'),
('Slovenia', 'SLO'), ('Somalia', 'SOM'), ('South Africa', 'RSA'),
('South Korea', 'KOR'), ('South Sudan', 'SSD'), ('Spain', 'ESP'),
('Sri Lanka', 'SRI'), ('Sudan', 'SUD'), ('Suriname', 'SUR'),
('Sweden', 'SWE'), ('Switzerland', 'SUI'), ('Syria', 'SYR'),
('Taiwan', 'TPE'), ('Tajikistan', 'TJK'), ('Tanzania', 'TAN'),
('Thailand', 'THA'), ('Togo', 'TOG'), ('Trinidad', 'TTO'),
('Tunisia', 'TUN'), ('Turkey', 'TUR'), ('Turkmenistan', 'TKM'),
('Uganda', 'UGA'), ('Ukraine', 'UKR'), ('UAE', 'UAE'),
('United Kingdom', 'GBR'), ('Uruguay', 'URU'), ('USA', 'USA'),
('Uzbekistan', 'UZB'), ('Venezuela', 'VEN'), ('Vietnam', 'VIE'),
('Yemen', 'YEM'), ('Zambia', 'ZAM'), ('Zimbabwe', 'ZIM');

CREATE TEMPORARY TABLE IF NOT EXISTS temp_sponsor (
    name text
);
COPY temp_sponsor(name)
FROM PROGRAM
'curl "https://raw.githubusercontent.com/veljkoAdzic/AdvDB_IRSON/refs/heads/master/DataFileUsed/sponsors.csv"'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
INSERT INTO sponsor(name)
    SELECT ts.name
    FROM temp_sponsor as ts
    WHERE LENGTH(ts.name) <= 80;

INSERT INTO SPORT_CATEGORY
  (name, sport_id, gender, duration_minutes, specification,
   team_capacity, points_per_win, points_per_draw, points_per_losing)
VALUES
('Men''s Football – 11-a-side',         1,'M',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Women''s Football – 11-a-side',       1,'F',90,'Standard 11-a-side outdoor',          11,3,1,0),
('Men''s Football – Futsal',            1,'M',40,'5-a-side indoor variant',               5,3,1,0),
('Women''s Football – Futsal',          1,'F',40,'5-a-side indoor variant',               5,3,1,0),
('Men''s Football – Beach Soccer',      1,'M',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Women''s Football – Beach Soccer',    1,'F',36,'3×12-min periods, sand pitch',          5,3,1,0),
('Men''s Football – Under-21',          1,'M',90,'Youth Olympic / U21 tournament',       11,3,1,0),
('Women''s Football – Under-20',        1,'F',90,'FIFA Women''s World Youth',            11,3,1,0),
('Men''s Basketball – 5-on-5',         2,'M',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Women''s Basketball – 5-on-5',       2,'F',40,'FIBA regulation 4×10 min quarters',    5,3,0,1),
('Men''s Basketball – 3×3',            2,'M',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Women''s Basketball – 3×3',          2,'F',10,'FIBA 3×3, half-court',                  3,3,0,1),
('Men''s Basketball – Wheelchair',     2,'M',40,'Paralympic classification',              5,3,0,1),
('Women''s Basketball – Wheelchair',   2,'F',40,'Paralympic classification',              5,3,0,1),
('Men''s Handball – Indoor',           3,'M',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Women''s Handball – Indoor',         3,'F',60,'2×30-min halves, 7-a-side',             7,3,1,0),
('Men''s Beach Handball',              3,'M',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Women''s Beach Handball',            3,'F',20,'2×10-min periods, 4-a-side',             4,3,0,1),
('Men''s Volleyball – Indoor',         4,'M',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Women''s Volleyball – Indoor',       4,'F',90,'Best-of-5 sets, 6-a-side',              6,3,0,1),
('Men''s Beach Volleyball',            4,'M',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Women''s Beach Volleyball',          4,'F',45,'Best-of-3 sets, 2-a-side',              2,3,0,1),
('Men''s Snow Volleyball',             4,'M',40,'3-a-side on snow court',                 3,3,0,1),
('Women''s Snow Volleyball',           4,'F',40,'3-a-side on snow court',                 3,3,0,1),
('Men''s Tennis – Singles',            5,'M',180,'Best-of-5 sets (Grand Slams)',          1,3,0,1),
('Women''s Tennis – Singles',          5,'F',120,'Best-of-3 sets',                        1,3,0,1),
('Men''s Tennis – Doubles',            5,'M',120,'Best-of-3 sets',                        2,3,0,1),
('Women''s Tennis – Doubles',          5,'F',120,'Best-of-3 sets',                        2,3,0,1),
('Mixed Tennis – Doubles',             5,'M',120,'Mixed-gender doubles',                  2,3,0,1),
('Men''s Athletics – Track Sprint',    6,'M',1,'100m/200m/400m events',                  1,3,0,1),
('Women''s Athletics – Track Sprint',  6,'F',1,'100m/200m/400m events',                  1,3,0,1),
('Men''s Athletics – Middle Distance', 6,'M',4,'800m/1500m events',                       1,3,0,1),
('Women''s Athletics – Middle Distance',6,'F',4,'800m/1500m events',                      1,3,0,1),
('Men''s Athletics – Long Distance',   6,'M',30,'5000m/10000m events',                    1,3,0,1),
('Women''s Athletics – Long Distance', 6,'F',30,'5000m/10000m events',                    1,3,0,1),
('Men''s Athletics – Marathon',        6,'M',130,'Road race, 42.195 km',                  1,3,0,1),
('Women''s Athletics – Marathon',      6,'F',145,'Road race, 42.195 km',                  1,3,0,1),
('Men''s Athletics – Hurdles',         6,'M',2,'110m/400m hurdles',                       1,3,0,1),
('Women''s Athletics – Hurdles',       6,'F',2,'100m/400m hurdles',                       1,3,0,1),
('Men''s Athletics – Steeplechase',    6,'M',8,'3000m steeplechase',                      1,3,0,1),
('Women''s Athletics – Steeplechase',  6,'F',10,'3000m steeplechase',                     1,3,0,1),
('Men''s Athletics – Relay',           6,'M',1,'4×100m and 4×400m relay',                4,3,0,1),
('Women''s Athletics – Relay',         6,'F',1,'4×100m and 4×400m relay',                4,3,0,1),
('Men''s Athletics – High Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – High Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Long Jump',       6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Long Jump',     6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Triple Jump',     6,'M',60,'Field jump event',                        1,3,0,1),
('Women''s Athletics – Triple Jump',   6,'F',60,'Field jump event',                        1,3,0,1),
('Men''s Athletics – Pole Vault',      6,'M',90,'Field vault event',                       1,3,0,1),
('Women''s Athletics – Pole Vault',    6,'F',90,'Field vault event',                       1,3,0,1),
('Men''s Athletics – Shot Put',        6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Shot Put',      6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Discus',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Discus',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Hammer',          6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Hammer',        6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Javelin',         6,'M',60,'Throwing event',                          1,3,0,1),
('Women''s Athletics – Javelin',       6,'F',60,'Throwing event',                          1,3,0,1),
('Men''s Athletics – Decathlon',       6,'M',600,'10 events over 2 days',                  1,3,0,1),
('Women''s Athletics – Heptathlon',    6,'F',480,'7 events over 2 days',                   1,3,0,1),
('Men''s Athletics – Race Walk 20km',  6,'M',90,'Road race walk',                          1,3,0,1),
('Women''s Athletics – Race Walk 20km',6,'F',100,'Road race walk',                         1,3,0,1),
('Men''s Boxing – Light Flyweight',    7,'M',9,'Up to 49 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Flyweight',          7,'M',9,'Up to 52 kg, 3×3-min rounds',             1,3,0,1),
('Men''s Boxing – Bantamweight',       7,'M',9,'Up to 56 kg',                              1,3,0,1),
('Men''s Boxing – Featherweight',      7,'M',9,'Up to 60 kg',                              1,3,0,1),
('Men''s Boxing – Lightweight',        7,'M',9,'Up to 64 kg',                              1,3,0,1),
('Men''s Boxing – Welterweight',       7,'M',9,'Up to 69 kg',                              1,3,0,1),
('Men''s Boxing – Middleweight',       7,'M',9,'Up to 75 kg',                              1,3,0,1),
('Men''s Boxing – Light Heavyweight',  7,'M',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Boxing – Heavyweight',        7,'M',9,'Up to 91 kg',                              1,3,0,1),
('Men''s Boxing – Super Heavyweight',  7,'M',9,'Over 91 kg',                               1,3,0,1),
('Women''s Boxing – Flyweight',        7,'F',9,'Up to 50 kg, 3×3-min rounds',             1,3,0,1),
('Women''s Boxing – Lightweight',      7,'F',9,'Up to 60 kg',                              1,3,0,1),
('Women''s Boxing – Welterweight',     7,'F',9,'Up to 66 kg',                              1,3,0,1),
('Women''s Boxing – Middleweight',     7,'F',9,'Up to 75 kg',                              1,3,0,1),
('Women''s Boxing – Heavyweight',      7,'F',9,'Up to 81 kg',                              1,3,0,1),
('Men''s Rugby Union – 15s',           8,'M',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Women''s Rugby Union – 15s',         8,'F',80,'2×40-min halves, 15-a-side',            15,4,2,0),
('Men''s Rugby Sevens',                8,'M',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Women''s Rugby Sevens',              8,'F',14,'2×7-min halves, 7-a-side',               7,4,2,0),
('Men''s Rugby League',               8,'M',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Women''s Rugby League',             8,'F',80,'2×40-min halves, 13-a-side',            13,2,1,0),
('Men''s Field Hockey',                9,'M',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Women''s Field Hockey',              9,'F',60,'4×15-min quarters, 11-a-side',          11,3,1,0),
('Men''s Baseball',                   10,'M',180,'9 innings, standard rules',              9,2,0,1),
('Women''s Baseball',                 10,'F',150,'9 innings, women''s rules',              9,2,0,1),
('Men''s Softball – Slow Pitch',      11,'M',60,'7 innings slow pitch',                   9,2,0,1),
('Women''s Softball – Fast Pitch',    11,'F',60,'7 innings fast pitch',                   9,2,0,1),
('Mixed Softball – Slow Pitch',       11,'M',60,'Co-ed, mixed gender roster',             9,2,0,1),
('Men''s Cricket – Test Match',       12,'M',450,'5-day match, 11-a-side',               11,1,1,0),
('Women''s Cricket – Test Match',     12,'F',450,'5-day women''s test',                  11,1,1,0),
('Men''s Cricket – ODI',              12,'M',480,'50-over one-day international',         11,2,1,0),
('Women''s Cricket – ODI',            12,'F',480,'50-over one-day international',         11,2,1,0),
('Men''s Cricket – T20',              12,'M',80,'20-over format',                         11,2,0,1),
('Women''s Cricket – T20',            12,'F',80,'20-over format',                         11,2,0,1),
('Men''s Golf – Stroke Play',         13,'M',240,'72-hole stroke play tournament',         1,3,0,1),
('Women''s Golf – Stroke Play',       13,'F',240,'72-hole stroke play tournament',         1,3,0,1),
('Men''s Golf – Match Play',          13,'M',240,'Hole-by-hole competition',               1,3,0,1),
('Women''s Golf – Match Play',        13,'F',240,'Hole-by-hole competition',               1,3,0,1),
('Men''s Golf – Team Ryder Cup',      13,'M',240,'Foursomes/fourballs, 12-man teams',     12,2,1,0),
('Women''s Golf – Solheim Cup',       13,'F',240,'Foursomes/fourballs, 12-woman teams',   12,2,1,0),
('Men''s Cycling – Road Race',        14,'M',300,'Mass-start road race',                   1,3,0,1),
('Women''s Cycling – Road Race',      14,'F',240,'Mass-start road race',                   1,3,0,1),
('Men''s Cycling – Time Trial',       14,'M',60,'Individual time trial',                   1,3,0,1),
('Women''s Cycling – Time Trial',     14,'F',45,'Individual time trial',                   1,3,0,1),
('Men''s Cycling – Track Sprint',     14,'M',4,'Track sprint / keirin',                    1,3,0,1),
('Women''s Cycling – Track Sprint',   14,'F',4,'Track sprint / keirin',                    1,3,0,1),
('Men''s Cycling – Track Endurance',  14,'M',50,'Points race / omnium',                    1,3,0,1),
('Women''s Cycling – Track Endurance',14,'F',50,'Points race / omnium',                    1,3,0,1),
('Men''s Cycling – Mountain Bike XC', 14,'M',90,'Cross-country off-road',                  1,3,0,1),
('Women''s Cycling – Mountain Bike XC',14,'F',75,'Cross-country off-road',                 1,3,0,1),
('Men''s Cycling – BMX Racing',       14,'M',1,'Sprint elimination format',                1,3,0,1),
('Women''s Cycling – BMX Racing',     14,'F',1,'Sprint elimination format',                1,3,0,1),
('Men''s Cycling – Team Pursuit',     14,'M',4,'4-km team pursuit, track',                 4,3,0,1),
('Women''s Cycling – Team Pursuit',   14,'F',4,'4-km team pursuit, track',                 4,3,0,1),
('Men''s Weightlifting – 61 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 73 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 89 kg',      15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 102 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109 kg',     15,'M',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Men''s Weightlifting – 109+ kg',    15,'M',30,'Unlimited class',                          1,3,0,1),
('Women''s Weightlifting – 49 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 59 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 71 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87 kg',    15,'F',30,'Snatch + clean & jerk combined',          1,3,0,1),
('Women''s Weightlifting – 87+ kg',   15,'F',30,'Unlimited class',                          1,3,0,1),
('Men''s Wrestling – Freestyle 57 kg',16,'M',6,'3+3 minutes, two periods',                1,3,0,1),
('Men''s Wrestling – Freestyle 65 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 74 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 86 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 97 kg',16,'M',6,'Freestyle rules',                          1,3,0,1),
('Men''s Wrestling – Freestyle 125 kg',16,'M',6,'Freestyle rules',                         1,3,0,1),
('Men''s Wrestling – Greco-Roman 60 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 77 kg',16,'M',6,'Greco-Roman rules',                      1,3,0,1),
('Men''s Wrestling – Greco-Roman 130 kg',16,'M',6,'Greco-Roman rules',                     1,3,0,1),
('Women''s Wrestling – Freestyle 50 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 57 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 68 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Women''s Wrestling – Freestyle 76 kg',16,'F',6,'Freestyle rules',                        1,3,0,1),
('Men''s Judo – Extra Lightweight',   17,'M',4,'Up to 60 kg, Olympic mat',                1,3,0,1),
('Men''s Judo – Half Lightweight',    17,'M',4,'Up to 66 kg',                              1,3,0,1),
('Men''s Judo – Lightweight',         17,'M',4,'Up to 73 kg',                              1,3,0,1),
('Men''s Judo – Half Middleweight',   17,'M',4,'Up to 81 kg',                              1,3,0,1),
('Men''s Judo – Middleweight',        17,'M',4,'Up to 90 kg',                              1,3,0,1),
('Men''s Judo – Half Heavyweight',    17,'M',4,'Up to 100 kg',                             1,3,0,1),
('Men''s Judo – Heavyweight',         17,'M',4,'Over 100 kg',                              1,3,0,1),
('Women''s Judo – Extra Lightweight', 17,'F',4,'Up to 48 kg',                              1,3,0,1),
('Women''s Judo – Half Lightweight',  17,'F',4,'Up to 52 kg',                              1,3,0,1),
('Women''s Judo – Lightweight',       17,'F',4,'Up to 57 kg',                              1,3,0,1),
('Women''s Judo – Half Middleweight', 17,'F',4,'Up to 63 kg',                              1,3,0,1),
('Women''s Judo – Middleweight',      17,'F',4,'Up to 70 kg',                              1,3,0,1),
('Women''s Judo – Half Heavyweight',  17,'F',4,'Up to 78 kg',                              1,3,0,1),
('Women''s Judo – Heavyweight',       17,'F',4,'Over 78 kg',                               1,3,0,1),
('Mixed Judo – Team Event',           17,'M',4,'3M+3F per team, alternating bouts',        6,3,0,1),
('Men''s Karate – Kata Individual',   18,'M',5,'Solo performance judged',                  1,3,0,1),
('Women''s Karate – Kata Individual', 18,'F',5,'Solo performance judged',                  1,3,0,1),
('Men''s Karate – Kata Team',         18,'M',5,'Team synchronised kata',                   3,3,0,1),
('Women''s Karate – Kata Team',       18,'F',5,'Team synchronised kata',                   3,3,0,1),
('Men''s Karate – Kumite 60 kg',      18,'M',3,'Sparring under 60 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75 kg',      18,'M',3,'Sparring under 75 kg',                     1,3,0,1),
('Men''s Karate – Kumite 75+ kg',     18,'M',3,'Sparring over 75 kg',                      1,3,0,1),
('Women''s Karate – Kumite 55 kg',    18,'F',3,'Sparring under 55 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61 kg',    18,'F',3,'Sparring under 61 kg',                     1,3,0,1),
('Women''s Karate – Kumite 61+ kg',   18,'F',3,'Sparring over 61 kg',                      1,3,0,1),
('Men''s Taekwondo – 58 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 68 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80 kg',          19,'M',9,'3×3-min rounds',                           1,3,0,1),
('Men''s Taekwondo – 80+ kg',         19,'M',9,'Heavyweight division',                      1,3,0,1),
('Women''s Taekwondo – 49 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 57 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67 kg',        19,'F',9,'3×3-min rounds',                           1,3,0,1),
('Women''s Taekwondo – 67+ kg',       19,'F',9,'Heavyweight division',                      1,3,0,1),
('Men''s Fencing – Foil Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Foil Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Épée Individual',  20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Épée Individual',20,'F',9,'3×3-min periods',                          1,3,0,1),
('Men''s Fencing – Sabre Individual', 20,'M',9,'3×3-min periods',                          1,3,0,1),
('Women''s Fencing – Sabre Individual',20,'F',9,'3×3-min periods',                         1,3,0,1),
('Men''s Fencing – Foil Team',        20,'M',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Women''s Fencing – Foil Team',      20,'F',27,'3-fencer relay, 9 bouts',                 3,3,0,1),
('Men''s Fencing – Épée Team',        20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Épée Team',      20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Fencing – Sabre Team',       20,'M',27,'3-fencer relay',                           3,3,0,1),
('Women''s Fencing – Sabre Team',     20,'F',27,'3-fencer relay',                           3,3,0,1),
('Men''s Archery – Recurve Individual',21,'M',90,'70 m elimination + final',               1,3,0,1),
('Women''s Archery – Recurve Individual',21,'F',90,'70 m elimination + final',             1,3,0,1),
('Men''s Archery – Recurve Team',     21,'M',60,'3-archer team, 18 ends',                  3,3,0,1),
('Women''s Archery – Recurve Team',   21,'F',60,'3-archer team, 18 ends',                  3,3,0,1),
('Mixed Archery – Recurve Team',      21,'M',60,'1M+1F mixed team',                        2,3,0,1),
('Men''s Archery – Compound Individual',21,'M',60,'50 m, compound bow',                    1,3,0,1),
('Women''s Archery – Compound Individual',21,'F',60,'50 m, compound bow',                  1,3,0,1),
('Men''s Rowing – Single Sculls',     22,'M',8,'2000 m course',                            1,3,0,1),
('Women''s Rowing – Single Sculls',   22,'F',8,'2000 m course',                            1,3,0,1),
('Men''s Rowing – Double Sculls',     22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Double Sculls',   22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Quadruple Sculls',  22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Quadruple Sculls',22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Coxless Pair',      22,'M',7,'2000 m course',                            2,3,0,1),
('Women''s Rowing – Coxless Pair',    22,'F',7,'2000 m course',                            2,3,0,1),
('Men''s Rowing – Coxless Four',      22,'M',6,'2000 m course',                            4,3,0,1),
('Women''s Rowing – Coxless Four',    22,'F',6,'2000 m course',                            4,3,0,1),
('Men''s Rowing – Eight with Cox',    22,'M',5,'2000 m course, coxswain included',         9,3,0,1),
('Women''s Rowing – Eight with Cox',  22,'F',6,'2000 m course, coxswain included',         9,3,0,1),
('Mixed Rowing – Adaptive Single',    22,'M',8,'Paralympic AS category',                   1,3,0,1),
('Men''s Sailing – Laser/ILCA 7',     23,'M',90,'Dinghy single-handed',                    1,3,0,1),
('Women''s Sailing – Laser/ILCA 6',   23,'F',80,'Dinghy single-handed',                    1,3,0,1),
('Men''s Sailing – Finn',             23,'M',90,'Heavy-weather single-handed dinghy',       1,3,0,1),
('Mixed Sailing – 470',               23,'M',90,'Two-person dinghy',                        2,3,0,1),
('Mixed Sailing – Nacra 17 Foiling',  23,'M',60,'Mixed catamaran foiler',                   2,3,0,1),
('Men''s Sailing – 49er Skiff',       23,'M',60,'Double-handed high-performance',           2,3,0,1),
('Women''s Sailing – 49erFX Skiff',   23,'F',60,'Double-handed high-performance',           2,3,0,1),
('Mixed Sailing – RS:X Windsurfer',   23,'M',60,'Windsurfer class',                         1,3,0,1),
('Men''s Alpine Skiing – Downhill',   24,'M',2,'Speed event, single run',                  1,3,0,1),
('Women''s Alpine Skiing – Downhill', 24,'F',2,'Speed event, single run',                  1,3,0,1),
('Men''s Alpine Skiing – Slalom',     24,'M',3,'Technical event, 2 runs combined',          1,3,0,1),
('Women''s Alpine Skiing – Slalom',   24,'F',3,'Technical event, 2 runs combined',          1,3,0,1),
('Men''s Alpine Skiing – Giant Slalom',24,'M',4,'Technical event, 2 runs',                  1,3,0,1),
('Women''s Alpine Skiing – Giant Slalom',24,'F',4,'Technical event, 2 runs',                1,3,0,1),
('Men''s Alpine Skiing – Super-G',    24,'M',2,'Speed + technique combined',                1,3,0,1),
('Women''s Alpine Skiing – Super-G',  24,'F',2,'Speed + technique combined',                1,3,0,1),
('Men''s Alpine Skiing – Combined',   24,'M',5,'Downhill + slalom combined',                1,3,0,1),
('Women''s Alpine Skiing – Combined', 24,'F',5,'Downhill + slalom combined',                1,3,0,1),
('Men''s Freestyle Skiing – Moguls',  24,'M',2,'Mogul field scoring',                       1,3,0,1),
('Women''s Freestyle Skiing – Moguls',24,'F',2,'Mogul field scoring',                       1,3,0,1),
('Men''s Freestyle Skiing – Aerials', 24,'M',2,'Jump scoring',                              1,3,0,1),
('Women''s Freestyle Skiing – Aerials',24,'F',2,'Jump scoring',                             1,3,0,1),
('Men''s Ski Cross',                  24,'M',1,'Head-to-head course elimination',            1,3,0,1),
('Women''s Ski Cross',                24,'F',1,'Head-to-head course elimination',            1,3,0,1),
('Men''s Cross-Country Skiing – 50km',24,'M',120,'Classical/freestyle mass start',           1,3,0,1),
('Women''s Cross-Country – 30km',     24,'F',90,'Classical/freestyle mass start',            1,3,0,1),
('Men''s Ski Jumping – Large Hill',   24,'M',60,'Points for distance + style',              1,3,0,1),
('Women''s Ski Jumping – Normal Hill',24,'F',60,'Points for distance + style',              1,3,0,1),
('Men''s Ice Hockey',                 25,'M',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Women''s Ice Hockey',               25,'F',60,'3×20-min periods, 6-a-side',              6,3,0,1),
('Men''s Triathlon – Standard',       26,'M',120,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Women''s Triathlon – Standard',     26,'F',130,'1.5km swim / 40km bike / 10km run',      1,3,0,1),
('Men''s Triathlon – Sprint',         26,'M',55,'750m / 20km / 5km',                       1,3,0,1),
('Women''s Triathlon – Sprint',       26,'F',60,'750m / 20km / 5km',                       1,3,0,1),
('Mixed Triathlon – Relay',           26,'M',80,'2M+2F, each leg sprint distance',          4,3,0,1),
('Men''s Badminton – Singles',        27,'M',60,'Best-of-3 games to 21',                   1,3,0,1),
('Women''s Badminton – Singles',      27,'F',60,'Best-of-3 games to 21',                   1,3,0,1),
('Men''s Badminton – Doubles',        27,'M',60,'Pairs, best-of-3',                         2,3,0,1),
('Women''s Badminton – Doubles',      27,'F',60,'Pairs, best-of-3',                         2,3,0,1),
('Mixed Badminton – Doubles',         27,'M',60,'One of each gender per pair',              2,3,0,1),
('Men''s Table Tennis – Singles',     28,'M',60,'Best-of-7 games to 11',                   1,3,0,1),
('Women''s Table Tennis – Singles',   28,'F',60,'Best-of-7 games to 11',                   1,3,0,1),
('Men''s Table Tennis – Doubles',     28,'M',60,'Pairs, best-of-5',                         2,3,0,1),
('Women''s Table Tennis – Doubles',   28,'F',60,'Pairs, best-of-5',                         2,3,0,1),
('Mixed Table Tennis – Doubles',      28,'M',60,'Mixed-gender pairs',                       2,3,0,1),
('Men''s Table Tennis – Team',        28,'M',90,'3-player team, 5 singles matches',         3,3,0,1),
('Women''s Table Tennis – Team',      28,'F',90,'3-player team, 5 singles matches',         3,3,0,1),
('Men''s Squash – Singles',           29,'M',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Women''s Squash – Singles',         29,'F',60,'Best-of-5 games, PSA rules',               1,3,0,1),
('Men''s Squash – Doubles',           29,'M',60,'Pairs, hardball or softball',               2,3,0,1),
('Women''s Squash – Doubles',         29,'F',60,'Pairs',                                     2,3,0,1),
('Mixed Squash – Doubles',            29,'M',60,'Mixed-gender pairs',                        2,3,0,1),
('Men''s Water Polo',                 30,'M',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Women''s Water Polo',               30,'F',32,'4×8-min periods, 7-a-side',                7,3,0,1),
('Men''s Artistic – All-Around',      31,'M',120,'6 apparatus individual',                  1,3,0,1),
('Women''s Artistic – All-Around',    31,'F',90,'4 apparatus individual',                   1,3,0,1),
('Men''s Artistic – Team',            31,'M',180,'Team combined score, 6 apparatus',        5,3,0,1),
('Women''s Artistic – Team',          31,'F',120,'Team combined score, 4 apparatus',        5,3,0,1),
('Men''s Artistic – Floor Exercise',  31,'M',30,'Floor apparatus final',                    1,3,0,1),
('Men''s Artistic – Pommel Horse',    31,'M',30,'Pommel horse apparatus final',              1,3,0,1),
('Men''s Artistic – Rings',           31,'M',30,'Rings apparatus final',                    1,3,0,1),
('Men''s Artistic – Vault',           31,'M',30,'Vault apparatus final',                    1,3,0,1),
('Men''s Artistic – Parallel Bars',   31,'M',30,'Parallel bars apparatus final',            1,3,0,1),
('Men''s Artistic – High Bar',        31,'M',30,'High bar apparatus final',                 1,3,0,1),
('Women''s Artistic – Vault',         31,'F',30,'Vault apparatus final',                    1,3,0,1),
('Women''s Artistic – Uneven Bars',   31,'F',30,'Uneven bars apparatus final',              1,3,0,1),
('Women''s Artistic – Balance Beam',  31,'F',30,'Balance beam apparatus final',             1,3,0,1),
('Women''s Artistic – Floor Exercise',31,'F',30,'Floor exercise apparatus final',           1,3,0,1),
('Men''s Rhythmic – Group',           31,'M',90,'5-person group, hoops/clubs/ribbons',      5,3,0,1),
('Women''s Rhythmic – Individual',    31,'F',60,'Individual routine, scored',               1,3,0,1),
('Women''s Rhythmic – Group',         31,'F',90,'5-person group',                           5,3,0,1),
('Men''s Trampoline – Individual',    31,'M',10,'10 skill routine',                          1,3,0,1),
('Women''s Trampoline – Individual',  31,'F',10,'10 skill routine',                          1,3,0,1),
('Men''s Acrobatic – Team',           31,'M',25,'Partnership/group acrobatics',              3,3,0,1),
('Women''s Acrobatic – Team',         31,'F',25,'Partnership/group acrobatics',              3,3,0,1),
('Men''s Equestrian – Dressage Ind.',  32,'M',30,'Grand Prix Freestyle',                    1,3,0,1),
('Women''s Equestrian – Dressage Ind.',32,'F',30,'Grand Prix Freestyle',                    1,3,0,1),
('Mixed Equestrian – Dressage Team',  32,'M',120,'3-pair team combined',                   3,3,0,1),
('Men''s Equestrian – Jumping Ind.',  32,'M',90,'Show jumping clear round',                 1,3,0,1),
('Women''s Equestrian – Jumping Ind.',32,'F',90,'Show jumping clear round',                 1,3,0,1),
('Mixed Equestrian – Jumping Team',   32,'M',120,'3-pair team',                             3,3,0,1),
('Men''s Equestrian – Eventing Ind.', 32,'M',540,'Dressage + cross-country + jumping',      1,3,0,1),
('Women''s Equestrian – Eventing Ind.',32,'F',540,'Dressage + cross-country + jumping',     1,3,0,1),
('Mixed Equestrian – Eventing Team',  32,'M',540,'3-pair team eventing',                    3,3,0,1),
('Men''s Canoe Sprint – K1 1000m',    33,'M',4,'Kayak single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – K1 500m',   33,'F',2,'Kayak single, 500 m',                      1,3,0,1),
('Men''s Canoe Sprint – K2 1000m',    33,'M',4,'Kayak double, 1000 m',                     2,3,0,1),
('Women''s Canoe Sprint – K2 500m',   33,'F',2,'Kayak double, 500 m',                      2,3,0,1),
('Men''s Canoe Sprint – K4 500m',     33,'M',2,'Kayak four, 500 m',                        4,3,0,1),
('Women''s Canoe Sprint – K4 500m',   33,'F',2,'Kayak four, 500 m',                        4,3,0,1),
('Men''s Canoe Sprint – C1 1000m',    33,'M',5,'Canoe single, 1000 m',                     1,3,0,1),
('Women''s Canoe Sprint – C1 200m',   33,'F',1,'Canoe single, 200 m',                      1,3,0,1),
('Men''s Canoe Slalom – K1',          33,'M',3,'Whitewater kayak slalom',                   1,3,0,1),
('Women''s Canoe Slalom – K1',        33,'F',3,'Whitewater kayak slalom',                   1,3,0,1),
('Men''s Canoe Slalom – C1',          33,'M',3,'Whitewater canoe slalom',                   1,3,0,1),
('Women''s Canoe Slalom – C1',        33,'F',3,'Whitewater canoe slalom',                   1,3,0,1),
('Mixed Canoe Slalom – C2',           33,'M',3,'Mixed-gender tandem canoe',                 2,3,0,1),
('Men''s Curling',                    34,'M',150,'10 ends, 4-person team',                  4,2,1,0),
('Women''s Curling',                  34,'F',150,'10 ends, 4-person team',                  4,2,1,0),
('Mixed Doubles Curling',             34,'M',75,'5 ends, 1M+1F per team',                   2,2,1,0),
('Men''s Biathlon – Sprint 10km',     35,'M',30,'Ski + 2 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Sprint 7.5km',  35,'F',25,'Ski + 2 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Pursuit 12.5km',  35,'M',36,'Ski + 4 shooting stages',                  1,3,0,1),
('Women''s Biathlon – Pursuit 10km',  35,'F',30,'Ski + 4 shooting stages',                  1,3,0,1),
('Men''s Biathlon – Individual 20km', 35,'M',60,'Classic individual, 4 shooting stages',     1,3,0,1),
('Women''s Biathlon – Individual 15km',35,'F',50,'Classic individual, 4 shooting stages',    1,3,0,1),
('Men''s Biathlon – Mass Start 15km', 35,'M',40,'Mass start, 4 shooting stages',             1,3,0,1),
('Women''s Biathlon – Mass Start 12.5km',35,'F',36,'Mass start, 4 shooting stages',          1,3,0,1),
('Mixed Biathlon – Relay 4×6km',      35,'M',80,'2M+2F relay teams',                        4,3,0,1),
('Men''s Polo – Outdoor',             36,'M',105,'7 chukkers × 7+2 min',                    4,3,1,0),
('Men''s Polo – Arena Polo',          36,'M',42,'6 chukkers × 7 min, indoor',               3,3,1,0),
('Women''s Polo – Outdoor',           36,'F',105,'7 chukkers, women''s tournament',          4,3,1,0),
('Men''s Lacrosse – Field',           37,'M',60,'4×15-min quarters, 10-a-side',            10,3,1,0),
('Women''s Lacrosse – Field',         37,'F',60,'4×15-min quarters, 12-a-side',            12,3,1,0),
('Men''s Lacrosse – Box',             37,'M',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Women''s Lacrosse – Box',           37,'F',45,'3×15-min periods, 6-a-side',               6,3,0,1),
('Men''s Futsal',                     38,'M',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Women''s Futsal',                   38,'F',40,'2×20-min halves, 5-a-side',                5,3,1,0),
('Men''s Beach Volleyball',           39,'M',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Women''s Beach Volleyball',         39,'F',45,'Best-of-3 sets, pairs',                    2,3,0,1),
('Mixed Beach Volleyball',            39,'M',45,'1M+1F per team',                           2,3,0,1),
('Men''s Kickboxing – Point Fighting',40,'M',9,'3×3-min rounds',                            1,3,0,1),
('Women''s Kickboxing – Point Fighting',40,'F',9,'3×3-min rounds',                          1,3,0,1),
('Men''s Kickboxing – Light Contact', 40,'M',9,'3×3-min rounds, controlled contact',        1,3,0,1),
('Women''s Kickboxing – Light Contact',40,'F',9,'3×3-min rounds, controlled contact',       1,3,0,1),
('Men''s Kickboxing – Full Contact',  40,'M',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Women''s Kickboxing – Full Contact',40,'F',9,'3×3-min rounds, unlimited contact',         1,3,0,1),
('Men''s Kickboxing – Low Kick',      40,'M',9,'Full contact + low kicks',                   1,3,0,1),
('Women''s Kickboxing – Low Kick',    40,'F',9,'Full contact + low kicks',                   1,3,0,1),
('Men''s Kickboxing – K1 Rules',      40,'M',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1),
('Women''s Kickboxing – K1 Rules',    40,'F',9,'Knees + kicks + punches, 3×3 min',          1,3,0,1);

-- KONVEKCIJA: NAJMLAD PERSON 15 GODISHEN NAJSTAR 70
CREATE TEMPORARY TABLE IF NOT EXISTS temp_male_names (
    id   bigserial primary key,
    name text
);
CREATE TEMPORARY TABLE IF NOT EXISTS temp_female_names (
    id   bigserial primary key,
    name text
);
CREATE TEMPORARY TABLE IF NOT EXISTS temp_surnames (
    id      bigserial primary key,
    surname text
);
COPY temp_male_names(name)
FROM PROGRAM
'curl "https://raw.githubusercontent.com/veljkoAdzic/AdvDB_IRSON/refs/heads/master/DataFileUsed/boyNames.csv"'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
COPY temp_female_names(name)
FROM PROGRAM
'curl "https://raw.githubusercontent.com/veljkoAdzic/AdvDB_IRSON/refs/heads/master/DataFileUsed/girlNames.csv"'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
COPY temp_surnames(surname)
FROM PROGRAM
'curl "https://raw.githubusercontent.com/veljkoAdzic/AdvDB_IRSON/refs/heads/master/DataFileUsed/surnames.csv"'
WITH (FORMAT csv, HEADER true, DELIMITER ',');


WITH male_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_male_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '0'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        ((now() - interval '15 years') - (random() * interval '70 years'))::date as date_of_birth,
        'M'as gender,
        (floor(random() * 165) + 1)::int as country_id
    FROM male_names mn
        CROSS JOIN surnames s
    LIMIT 1000000
) as data
ON CONFLICT (ssn) DO NOTHING;
WITH female_names AS (
    SELECT name, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_female_names
),
surnames AS (
    SELECT surname, row_number() OVER (ORDER BY random()) AS rn
    FROM temp_surnames
)
INSERT INTO PERSON (ssn, first_name, last_name, date_of_birth, gender, country_id)
SELECT
    to_char(data.date_of_birth, 'DDMM')||
    to_char(extract(year from data.date_of_birth)::integer % 1000, 'FM009')||
    '4'||
    to_char((1 + floor(random()*8))::int, 'FM9') ||
    '5'||
    to_char(floor(random()*100)::int, 'FM09') as ssn,
    data.first_name,
    data.last_name,
    data.date_of_birth,
    data.gender,
    data.country_id
FROM (
    SELECT
        mn.name as first_name,
        s.surname as last_name,
        ((now() - interval '15 years') - (random() * interval '70 years'))::date as date_of_birth,
        'F'as gender,
        (floor(random() * 165) + 1)::int as country_id
    FROM female_names mn
        CROSS JOIN surnames s
    LIMIT 1000000
) as data
ON CONFLICT (ssn) DO NOTHING;

INSERT INTO FEDERATION (sport_id, name)
SELECT
    s.id as sport_id,
    s.name || ' Federation of ' || c.name as name
FROM SPORT s
    cross join COUNTRY c
WHERE length(s.name || ' Federation of ' || c.name) <=80
ON CONFLICT (name) DO NOTHING;
INSERT INTO FEDERATION (sport_id, name)
SELECT id as sport_id,
       'International ' || name || ' Federation' AS name
FROM SPORT
where length('International ' || name || ' Federation') <= 80
ON CONFLICT Do NOTHING;

INSERT INTO INTERNATIONAL_FEDERATION (id)
SELECT id
FROM FEDERATION
WHERE name LIKE 'International%';

INSERT INTO NATIONAL_FEDERATION (id, country_id, international_federation_id)
SELECT f.id,
       c.id,
       inf.id
FROM FEDERATION f
    join SPORT s on s.id = f.sport_id
    join COUNTRY c on f.name = s.name || ' Federation of ' || c.name
    join FEDERATION ifF on ifF.name = 'International ' || s.name || ' Federation'
    join INTERNATIONAL_FEDERATION inf on inf.id = ifF.id
ON CONFLICT DO NOTHING;

INSERT INTO SPORT_CLUB (name, is_national_representation, country_id)
select
       ('National Representation Club of ' || c.abreviation) as name,
       TRUE as is_national_representation,
       c.id as country_id
FROM COUNTRY c
CROSS JOIN sport_category sc
WHERE length('National Representation Club of' || c.abreviation) <= 150
ON CONFLICT DO NOTHING;
CREATE TEMPORARY TABLE IF NOT EXISTS temp_clubs_names (
    id      bigserial primary key,
    name text
);
COPY temp_clubs_names(name)
FROM PROGRAM
'curl "https://raw.githubusercontent.com/veljkoAdzic/AdvDB_IRSON/refs/heads/master/DataFileUsed/clubs.csv"'
WITH (FORMAT csv, HEADER true, DELIMITER ',');
INSERT INTO SPORT_CLUB (name, is_national_representation, country_id)
SELECT name, is_national_representation, country_id
FROM (
    SELECT
        tcn.name as name,
        FALSE as is_national_representation,
        c.id as country_id
    FROM (
        SELECT name, row_number() OVER (ORDER BY random()) as rn
        FROM temp_clubs_names
        WHERE length(name) <= 150
    ) as tcn
    CROSS JOIN LATERAL (
        SELECT
            c.id
        FROM COUNTRY c
        ORDER BY random() * tcn.rn
        LIMIT 1
    ) as c
) as data
LIMIT 20000
ON CONFLICT (name, country_id) DO NOTHING;

-- NACIONALNITE CLUBOVI IMAAT TIMOVI ZA SITE SPORTSKI KATEGORII TIMOVI
INSERT INTO sport_team(club_id, name, sport_category_id)
SELECT
       sc.id as club_id,
       LEFT('NT ' || c.abreviation || ' ' || scat.name, 20) as name,
       scat.id as sport_category_id
FROM sport_club sc
JOIN country c
    ON c.id = sc.country_id
CROSS JOIN sport_category scat
WHERE sc.is_national_representation = TRUE
    AND length(LEFT('NT ' || c.abreviation || ' ' || scat.name, 30)) <= 150;
-- NENACIONALNITE CLUBOVI IMAAT TIMOVI ZA RANDOM 11 ILI 14/337 SPORTSKI KATEGORII
INSERT INTO sport_team(club_id, name, sport_category_id)
SELECT
    sc.id AS club_id,
    LEFT(sc.name || ' ' || scat.name, 20) AS name,
    scat.id AS sport_category_id
FROM sport_club sc
JOIN country c ON c.id = sc.country_id
CROSS JOIN LATERAL (
    SELECT scat.id, scat.name
    FROM sport_category scat
    ORDER BY md5(sc.id::text || scat.id::text || random()::text)
    LIMIT
        CASE WHEN sc.id % 2 = 0 THEN 14
        ELSE 11 END
) AS scat
WHERE sc.is_national_representation = FALSE
    AND length(LEFT(sc.name || ' ' || scat.name, 20)) <= 150;

-- NACIONALNITE CLUBOVI CHELNUVAAT VO SITE SPORTSKI FEDERACII VO TAA DRZHAVA SE ZACHLENILE PRED [40, 50] GOD
INSERT INTO club_federation(federation_id, club_id, start_date, end_date)
SELECT nf.id, sc.id, ((now() - interval '40 years') - (random() * interval '10 years'))::date as d, null
FROM sport_club sc
CROSS JOIN SPORT s
JOIN national_federation nf
    ON nf.country_id = sc.country_id
WHERE sc.is_national_representation = TRUE
ON CONFLICT DO NOTHING ;
-- NENACIONALNITE CLUBOVI CHLENUVAAT VO SPORTSKI FEDERACII VO DRZHAVATA ZA KOI IMAAT TIMOVI PRED [30, 35] GOD
-- 5% OD TIMOVITE SE POVLECHENI VO POSLEDNITE [5, 10] GODINI
INSERT INTO club_federation(federation_id, club_id, start_date, end_date)
SELECT nf.id, sc.id,
       ((now() - interval '30 years') - (random() * interval '5 years'))::date AS start_date,
       CASE
           WHEN random() <= 0.05
           THEN ((now() - interval '5 years') - (random() * interval '5 years'))::date
       END AS end_date
FROM sport_club sc
JOIN sport_team st
    ON st.club_id = sc.id
JOIN sport_category scat
    ON scat.id = st.sport_category_id
JOIN SPORT s
    ON s.id = scat.sport_id
JOIN federation f
    ON f.sport_id = s.id
JOIN national_federation nf
    ON nf.country_id = sc.country_id
    AND f.id = nf.id
WHERE sc.is_national_representation = FALSE
ON CONFLICT DO NOTHING;

INSERT INTO REGION (name, part_of_country)
VALUES
  ('Nordic', FALSE), ('Balkans', FALSE), ('Maghreb', FALSE),
  ('Benelux', FALSE), ('Cono_sur', FALSE), ('Gcc', FALSE),
  ('Asean', FALSE), ('Visegrad', FALSE), ('Baltic', FALSE),
  ('Andean', FALSE), ('Ecowas', FALSE), ('Eac', FALSE),
  ('Levant', FALSE), ('Steppe', FALSE), ('Alpine', FALSE),
  ('Caribbean', FALSE), ('Anzac', FALSE), ('Saarc', FALSE),
  ('Melanesia', FALSE), ('Caucasus', FALSE), ('Central_america', FALSE),
  ('Iberia', FALSE), ('Nile_valley', FALSE),
  ('Cascadia', TRUE), ('Great_lakes', TRUE);
INSERT INTO REGION (name, part_of_country)
    SELECT c.name || '_North', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_South', TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_East',  TRUE FROM COUNTRY c
    UNION ALL
    SELECT c.name || '_West',  TRUE FROM COUNTRY c;

INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id
FROM COUNTRY c
JOIN REGION r ON r.name IN (
  c.name || '_North',
  c.name || '_South',
  c.name || '_East',
  c.name || '_West'
);
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nordic'
  AND c.name IN ('Norway','Sweden','Finland','Denmark','Iceland');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Balkans'
  AND c.name IN ('Serbia','Croatia','Bosnia','Slovenia','Montenegro',
                 'Kosovo','Albania','North Macedonia','Bulgaria','Romania','Greece');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Maghreb'
  AND c.name IN ('Morocco','Algeria','Tunisia','Libya','Mauritania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Benelux'
  AND c.name IN ('Belgium','Netherlands','Luxembourg');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Cono_sur'
  AND c.name IN ('Argentina','Chile','Uruguay','Paraguay','Brazil');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Gcc'
  AND c.name IN ('Saudi Arabia','UAE','Kuwait','Qatar','Bahrain','Oman');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Asean'
  AND c.name IN ('Thailand','Vietnam','Indonesia','Malaysia','Philippines',
                 'Singapore','Myanmar','Cambodia','Laos','Brunei');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Visegrad'
  AND c.name IN ('Poland','Czech Republic','Slovakia','Hungary');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Baltic'
  AND c.name IN ('Estonia','Latvia','Lithuania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Andean'
  AND c.name IN ('Colombia','Venezuela','Ecuador','Peru','Bolivia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Ecowas'
  AND c.name IN ('Nigeria','Ghana','Senegal','Mali','Burkina Faso','Guinea',
                 'Benin','Niger','Togo','Sierra Leone','Liberia','Gambia',
                 'Cape Verde','Mauritania');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Eac'
  AND c.name IN ('Kenya','Tanzania','Uganda','Rwanda','Burundi','South Sudan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Levant'
  AND c.name IN ('Lebanon','Syria','Jordan','Israel','Palestine','Iraq');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Steppe'
  AND c.name IN ('Kazakhstan','Kyrgyzstan','Tajikistan','Turkmenistan',
                 'Uzbekistan','Mongolia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Alpine'
  AND c.name IN ('Switzerland','Austria','Slovenia');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caribbean'
  AND c.name IN ('Cuba','Jamaica','Haiti','Dominican Republic','Trinidad','Bahamas');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Anzac'
  AND c.name IN ('Australia','New Zealand');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Saarc'
  AND c.name IN ('India','Pakistan','Bangladesh','Nepal','Sri Lanka',
                 'Bhutan','Maldives','Afghanistan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Melanesia'
  AND c.name IN ('Fiji');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Caucasus'
  AND c.name IN ('Georgia','Armenia','Azerbaijan');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Central_america'
  AND c.name IN ('Guatemala','Belize','El Salvador','Honduras',
                 'Nicaragua','Costa Rica','Panama');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Iberia'
  AND c.name IN ('Spain','Portugal','Andorra');
INSERT INTO COUNTRY_REGION (country_id, region_id)
SELECT c.id, r.id FROM COUNTRY c, REGION r
WHERE r.name = 'Nile_valley'
  AND c.name IN ('Egypt','Sudan','South Sudan','Ethiopia','Uganda');

INSERT INTO COMPETITION_TYPE (type_label) VALUES
-- League formats
('National League 1'),
('National League 2'),
('National League 3'),
('National League 4'),
-- Cup formats
('National Cup'),
('Regional Cup'),
-- International formats
('World Championship'),
('Continental Championship'),
('European Championship'),
('Olympic Qualification Tournament'),
('Friendly International'),
('International Friendly Tournament'),
--Other
('Exhibition Match'),
('All Star Game'),
('Playoff Series'),
('Promotion Playoff'),
('Relegation Playoff');

WITH name_cte AS (
    SELECT
        p1 || p2 || ' ' || s AS name
    FROM (
        VALUES
            ('Sport'), ('Riverside'), ('Colonial'), ('National'), ('Central'), ('Olympic'),
            ('Greenfield'), ('Mountain'), ('Lakeside'), ('City'), ('Victory'), ('Heritage'),
            ('Liberty'), ('Sunset'), ('Eastside'), ('West End'), ('North Park'), ('South Gate'),
            ('Alpha'), ('Golden Arch'), ('Springfield'), ('Mountain Side'), ('Sea Bay'),
            ('Flounder'), ('John Doe'), ('Mary Jay'), ('Simon Petrikov'), ('Jane Sandansi')
    ) AS sufix(p1)
    CROSS JOIN (
        VALUES
            (' Hall'), (' Grounds'), (' Stripe'), (' Kingson''s'), (' Calling'), (''),
            (' Fright'), (' Pirate'), (' Comb')
    ) AS midfix(p2)
    CROSS JOIN (
        VALUES
            ('Field'), ('Stadium'), ('Track'), ('Ring'), ('Arena'), ('Court'), ('Grounds'),
            ('Complex'), ('Park'), ('Center'), ('Dome'), ('Pitch'), ('Plaza')
    ) AS suffixes(s)
    ORDER BY random()
),
address_cte AS (
    SELECT p1 || ' ' || p2 || ' ' || s || ' No.' || random(1, 100)::int4 as name
    FROM (
        VALUES
        ('Main'), ('Mane'), ('Nikola'), ('Somber'), ('Dreamy'), ('Second'),
        ('Calvin'), ('Jenny'), ('Maria'), ('Loiter'), ('Tornado'), ('Big'),
        ('Small'), ('Central'), ('Outer'), ('Piggy'), ('Bronze'), ('San'),
        ('Tourist'), ('Los'), ('Part'), ('Ginger'), ('Mary'), ('Drury'),
        ('Cactus'), ('Palm'), ('Secret'), ('Jimmy'), ('Tim'), ('Magnus'),
        ('Third'), ('Fifth'), ('Prime'), ('Alternative'), ('Void'), ('Summer')
    )  first_name(p1)
    CROSS JOIN (
        VALUES
        ('Way'), ('Branch'), ('Tesla'), ('Carbon'), ('Stoker'), ('Shore'), ('Bettle'),
        ('Bench'), ('Static'), ('Quarter'), ('Third'), ('Jay'), ('Parrot'), ('Gofer'),
        ('Single'), ('Band'), ('Gain'), ('Tribe'), ('Sting'), ('Silver'), ('Gold')
    ) second_name(p2)
    CROSS JOIN (
        VALUES
        ('Street'), ('Road'), ('Boulevard'), ('Alley'), ('Path'), ('Walk'), ('Lane'),
        ('Park')
    ) sufix(s)
    ORDER BY random()
)
INSERT INTO location (country_id, name, capacity, address)
    SELECT c.id as country_id,
           loc_data.name as name,
           random(2, 500)::int4 * 100 as capacity,
           loc_data.adr as address
    FROM (
        SELECT
            id,
            floor(random(2, 30)) as loc_count
        FROM country
     ) as c
    CROSS JOIN LATERAL (
        SELECT
            name_cte.name as name,
            address_t.name as adr
        FROM name_cte
        CROSS JOIN
            (SELECT * FROM address_cte ORDER BY random() LIMIT c.loc_count*3) as address_t
        ORDER BY random()
        LIMIT c.loc_count
    ) as loc_data
ON CONFLICT (country_id, name) DO NOTHING;

CREATE TEMPORARY TABLE if not exists person_roles_idxs AS
SELECT
    1::int                       AS referee_min_idx,
    (COUNT(*) * 0.1)::int        AS referee_max_idx,
    (COUNT(*) * 0.1)::int + 1    AS coach_min_idx,
    (COUNT(*) * 0.3)::int        AS coach_max_idx,
    (COUNT(*) * 0.3)::int + 1    AS sportsman_min_idx,
    COUNT(*)::int                AS sportsman_max_idx
FROM person;
CREATE TEMPORARY TABLE if not exists person_roles AS
SELECT
    ssn,
    row_number() OVER (ORDER BY random()) AS i
FROM person;
CREATE TEMPORARY TABLE if not exists person_referee AS
SELECT pr.ssn, pr.i
FROM person_roles pr
CROSS JOIN person_roles_idxs idx
WHERE pr.i BETWEEN idx.referee_min_idx AND idx.referee_max_idx;
CREATE TEMPORARY TABLE if not exists person_coach AS
SELECT pr.ssn, pr.i
FROM person_roles pr
CROSS JOIN person_roles_idxs idx
WHERE pr.i BETWEEN idx.coach_min_idx AND idx.coach_max_idx;
CREATE TEMPORARY TABLE if not exists person_sportsman AS
SELECT pr.ssn, pr.i
FROM person_roles pr
CROSS JOIN person_roles_idxs idx
WHERE pr.i BETWEEN idx.sportsman_min_idx AND idx.sportsman_max_idx;
INSERT INTO sportsperson (ssn, sport_category_id)
SELECT
    p.ssn,
    cat.id
FROM person p
JOIN person_sportsman ps
    ON p.ssn = ps.ssn
CROSS JOIN LATERAL (
    SELECT id
    FROM sport_category
    ORDER BY random() * ps.i
    LIMIT 1
) AS cat;
INSERT INTO referee (ssn, federation_id, sport_category_id)
SELECT
    p.ssn,
    nff.id,
    cat.id
FROM person p
JOIN person_referee ps
    ON p.ssn = ps.ssn
CROSS JOIN LATERAL (
    SELECT id
    FROM sport_category
    ORDER BY random() * ps.i
    LIMIT 1
) AS cat
JOIN sport_category sc
    ON sc.id = cat.id
JOIN federation f
    ON f.sport_id = sc.sport_id
CROSS JOIN LATERAL (
    SELECT nf.id FROM national_federation nf
    WHERE nf.country_id = p.country_id
        AND f.id = nf.id
    ORDER BY random() * ps.i
    LIMIT 1
) nff;
INSERT INTO coach (ssn, federation_id, sport_category_id)
SELECT
    p.ssn,
    nff.id,
    cat.id
FROM person p
JOIN person_coach ps
    ON p.ssn = ps.ssn
CROSS JOIN LATERAL (
    SELECT id
    FROM sport_category
    ORDER BY random() * ps.i
    LIMIT 1
) AS cat
JOIN sport_category sc
    ON sc.id = cat.id
JOIN federation f
    ON f.sport_id = sc.sport_id
CROSS JOIN LATERAL (
    SELECT nf.id FROM national_federation nf
    WHERE nf.country_id = p.country_id
        AND f.id = nf.id
    ORDER BY random() * ps.i
    LIMIT 1
) nff;


INSERT INTO NATIONAL_LEAGUE (federation_id, name, date_started, date_disbanded, region_id)
select nf.id as federation_id,
    s.name || ' League of ' || c.name as name,
    (now() - interval '1 year' * (10 + floor(random() * 40)))::date as date_started,
    CASE
        WHEN random() < 0.5 THEN NULL
        ELSE (now() - interval '1 year' * floor(random() * 5))::date
    END as date_disbanded,
    (
        SELECT cr.region_id
        FROM COUNTRY_REGION cr
        WHERE cr.country_id = nf.country_id
        ORDER BY random()
        LIMIT 1
    ) as region_id
FROM NATIONAL_FEDERATION nf
    join FEDERATION f ON f.id = nf.id
    join SPORT s ON s.id = f.sport_id
    JOIN COUNTRY c ON c.id = nf.country_id
WHERE length(s.name || ' League of ' || c.name) <= 150
ON CONFLICT DO NOTHING;

INSERT INTO SEASON (national_league_id, start_date, end_date)
select nl.id as national_league_id,
       (nl.date_started + (interval '1 year' * sesonNumber)):: date as start_date,
       (nl.date_started + ((interval '1 year' *sesonNumber)+interval '10 months'))::date as end_date
from NATIONAL_LEAGUE nl
cross join generate_series(0, 999) as sesonNumber
where (nl.date_started + (interval '1 year' * sesonNumber))::date >= nl.date_started
        and (nl.date_started + (interval '1 year' * sesonNumber))::date < (now()::date + interval '10 years')
        and (Case
            when nl.date_disbanded is not null
            then (nl.date_started + (interval '1 year' * sesonNumber))::date <= nl.date_disbanded
            else True End
            )
;
INSERT INTO SPONSORSHIP (sport_team_id, sponsor_id, start_date, end_date, amount)
SELECT st.id as sport_team_id,
       s.id as sponsor_id,
       (now() - interval '40 year' * random())::date as start_date,
        CASE
            WHEN random() < 0.3 THEN null
            else (now() + interval '10 year' *random())::date
        end as end_date,
        (10000 + floor(random()*60000000))::int as amount
from (
    select id, row_number() over (order by random()) as rn, gs as offf
    from SPORT_TEAM
    cross join generate_series(1, 7) as gs
     ) as st join
    (
    select id, row_number() over (order by random()) as rn
    from SPONSOR
    ) as s on s.rn = ((st.rn*st.offf-1) % (Select count(*) from SPONSOR) + 1)
on conflict do nothing;

INSERT INTO COMPETITION (type, organizer_federation_id, season_id, name, start_date, end_date)
SELECT ct.id as type, f.id as organizer_federation_id, s.id as season_id,
        sp.name || ' '|| ct.type_label || ' '|| extract(YEAR from s.start_date)::text as name,
        s.start_date,
        CASE WHEN
            s.end_date > now()::date and random() < 0.4
            THEN NULL
            ELSE s.end_date
        END as end_date
from (
    select id, national_league_id,start_date, end_date, row_number() OVER (ORDER BY random()) AS rn
    from SEASON
--     where end_date is not null
     ) s
    join NATIONAL_LEAGUE nl on s.national_league_id=nl.id
    join FEDERATION f on nl.federation_id=f.id
    join SPORT sp on sp.id = f.sport_id
    join (
        select id, type_label, row_number() OVER (ORDER BY random()) AS rn
        from COMPETITION_TYPE
) as ct ON ct.rn = ((s.rn - 1) % (SELECT COUNT(*) FROM COMPETITION_TYPE) + 1)
WHERE length(sp.name || ' ' || ct.type_label || ' ' || EXTRACT(YEAR FROM s.start_date)::text) > 0
    and length(sp.name || ' ' || ct.type_label || ' ' || EXTRACT(YEAR FROM s.start_date)::text)<=40
limit 1000000
on conflict do nothing;


-- Temporary table for sportsperson
CREATE TEMP TABLE IF NOT EXISTS sportsperson_temp AS
    SELECT
        ssn, sport_category_id,
        floor(random()*7 + 1 )::int as num_contracts
    FROM sportsperson
    ORDER BY random()
;
-- Table for non representative clubs
CREATE TEMP TABLE tmp_clubs_by_category AS
SELECT
    sc.id AS sport_category_id,
    array_agg(c.id ORDER BY random()) AS club_ids,
    count(*)::int AS club_count
FROM sport_club c
JOIN club_federation  cf ON cf.club_id       = c.id
JOIN federation        f ON cf.federation_id = f.id
JOIN sport_category   sc ON f.sport_id       = sc.sport_id
WHERE NOT c.is_national_representation
GROUP BY sc.id;

CREATE INDEX ON tmp_clubs_by_category (sport_category_id);

-- Representation by category
CREATE TEMP TABLE tmp_rep_clubs_by_category_country AS
SELECT
    sc.id AS sport_category_id,
    nf.country_id,
    array_agg(c.id ORDER BY random()) AS club_ids,
    count(*)::int AS club_count
FROM sport_club c
JOIN club_federation   cf ON cf.club_id       = c.id
JOIN federation         f ON cf.federation_id = f.id
JOIN national_federation nf ON nf.id          = f.id
JOIN sport_category    sc ON f.sport_id       = sc.sport_id
WHERE c.is_national_representation
GROUP BY sc.id, nf.country_id;

CREATE INDEX ON tmp_rep_clubs_by_category_country (sport_category_id, country_id);

-- Generating contracts
INSERT INTO sportsperson_contract (player_ssn, club_id, start_date, end_date, payout)
WITH base AS (
    -- Join both lookups at once; person table only touched once for country_id
    SELECT
        s.ssn,
        s.sport_category_id,
        s.num_contracts,
        p.country_id,
        cbc.club_ids   AS norep_club_ids,
        cbc.club_count AS norep_club_count,
        rbc.club_ids   AS rep_club_ids,
        rbc.club_count AS rep_club_count
    FROM sportsperson_temp s
    JOIN person p
        ON p.ssn = s.ssn
    JOIN tmp_clubs_by_category cbc
        ON cbc.sport_category_id = s.sport_category_id
    LEFT JOIN tmp_rep_clubs_by_category_country rbc
        ON  rbc.sport_category_id = s.sport_category_id
        AND rbc.country_id        = p.country_id
),
-- non representative contracts
norep_pairs AS (
    SELECT
        b.ssn,
        b.norep_club_ids[1 + ((b.num_contracts + r.r) % b.norep_club_count)] AS club_id,
        r.r,
        false AS is_rep
    FROM base b
    JOIN LATERAL generate_series(1, least(b.num_contracts, 10)) AS r(r) ON true
    WHERE b.norep_club_count > 0
),
-- national-rep contracts (at most 1 active at a time)
rep_pairs AS (
    SELECT
        b.ssn,
        b.rep_club_ids[1 + ((b.num_contracts + r.r) % b.rep_club_count)] AS club_id,
        r.r,
        true AS is_rep
    FROM base b
    JOIN LATERAL generate_series(1, least(b.num_contracts, 20)) AS r(r) ON true
    WHERE b.rep_club_count > 0
),
all_pairs AS (
    SELECT * FROM norep_pairs
    UNION ALL
    SELECT * FROM rep_pairs
)
SELECT
    p.ssn AS player_ssn,
    p.club_id,
    NOW() - (p.r * INTERVAL '1 year')
          - (floor(random() * 250 - 100)::int * INTERVAL '1 day') AS start_date,
    CASE WHEN p.r = 1
        THEN NULL
        ELSE NOW() - ((p.r - 1) * INTERVAL '1 year')
                   - (floor(random() * 250 - 100)::int * INTERVAL '1 day')
    END AS end_date,
    floor(random() * 4990001 + 10000)::int4 AS payout
FROM all_pairs p;

-- removing indexes of sportsperson contract
DROP TABLE tmp_clubs_by_category;
DROP TABLE tmp_rep_clubs_by_category_country;

-- Generating duels
INSERT INTO DUEL (home_team_id, away_team_id, location_id, competition_id, start_time, sport_category_id)
(
    select home.home_id as home_team_id,
           away.away_id as away_team_id,
           l.id as location_id,
           comp.id as competition_id,
           ((comp.start_date + (random() * (comp.end_date - comp.start_date))::int)::timestamp
            + (floor(random() * 24) || ' hours')::interval) as start_time,
           home.category as sport_category_id
    from (
        --home
        SELECT st.id as home_id,
               st.sport_category_id as category,
               sc.country_id as county,
               sc.is_national_representation as nationality,
                row_number() OVER (ORDER BY random()) as rn
        from SPORT_TEAM st
        join SPORT_CLUB sc on st.club_id=sc.id
         ) home join (
        --away
        SELECT st.id as away_id,
               st.sport_category_id as category,
               sc.country_id as county,
               sc.is_national_representation as nationality,
                row_number() OVER (ORDER BY random()) as rn
        from SPORT_TEAM st
        join SPORT_CLUB sc on st.club_id=sc.id
         ) away on (home.category=away.category and home.home_id!=away.away_id and home.nationality=away.nationality
             and away.rn = ((home.rn) % (SELECT COUNT(*) FROM SPORT_TEAM) + 1))
        join (
            -- location
            select id, country_id
            from LOCATION
        ) l on l.country_id = home.county join (
        --competition
            select c.id, c.start_date, c.end_date, f.sport_id
            from COMPETITION c
            join FEDERATION f on c.organizer_federation_id=f.id
                where end_date is not null
        ) comp on comp.sport_id=(select sport_id from SPORT_CATEGORY
                                           where id = home.category)
    LIMIT 1000000
)
UNION ALL
(
    select home.home_id as home_team_id,
           away.away_id as away_team_id,
           l.id as location_id,
           NULL as competition_id,
           (
            now()::date + random() * interval '75 years'
               - interval '70 years' + interval '8 hours'
               + random() * interval '14 hour'
           )::timestamp as start_time,
           home.category as sport_category_id
    from (
        --home
        SELECT st.id as home_id,
               st.sport_category_id as category,
               sc.country_id as county,
               sc.is_national_representation as nationality,
                row_number() OVER (ORDER BY random()) as rn
        from SPORT_TEAM st
        join SPORT_CLUB sc on st.club_id=sc.id
         ) home join (
        --away
        SELECT st.id as away_id,
               st.sport_category_id as category,
               sc.country_id as county,
               sc.is_national_representation as nationality,
                row_number() OVER (ORDER BY random()) as rn
        from SPORT_TEAM st
        join SPORT_CLUB sc on st.club_id=sc.id
         ) away on (home.category=away.category and home.home_id!=away.away_id and home.nationality=away.nationality
             and away.rn = ((home.rn) % (SELECT COUNT(*) FROM SPORT_TEAM) + 1))
        join (
            -- location
            select id, country_id
            from LOCATION
        ) l on l.country_id = home.county
    LIMIT 500000
)
ON CONFLICT DO NOTHING
;

-- Generating Refereeing_duel
WITH duels AS (
    SELECT id, sport_category_id,row_number() OVER (PARTITION BY sport_category_id ORDER BY random()) AS rn
    FROM DUEL
),
referees AS (
    SELECT ssn, sport_category_id, row_number() OVER (PARTITION BY sport_category_id ORDER BY random()) AS rn,
        count(*) OVER (PARTITION BY sport_category_id) AS cnt
    FROM REFEREE
)
INSERT INTO REFEREEING_DUEL (referee_ssn, duel_id)
    SELECT
        r.ssn as referee_ssn,
        d.id as duel_id
    from duels d
    join referees r
        on d.sport_category_id = r.sport_category_id
           AND r.rn = ((d.rn - 1) % r.cnt) + 1
ON CONFLICT DO NOTHING;

WITH duels AS (
    SELECT id, sport_category_id,row_number() OVER (PARTITION BY sport_category_id ORDER BY random()) AS rn
    FROM DUEL
    where id in (
        select duel_id
        from REFEREEING_DUEL
        group by duel_id
        having count(*) < 4
        )
),
referees AS (
    SELECT ssn, sport_category_id, row_number() OVER (PARTITION BY sport_category_id ORDER BY random()) AS rn,
        count(*) OVER (PARTITION BY sport_category_id) AS cnt
    FROM REFEREE
)
INSERT INTO REFEREEING_DUEL (referee_ssn, duel_id)
    SELECT
        r.ssn as referee_ssn,
        d.id as duel_id
    from duels d
    join referees r
        on d.sport_category_id=r.sport_category_id
        AND r.rn = ((d.rn - 1) % r.cnt) + 1
    limit 4000000
ON CONFLICT DO NOTHING;

INSERT INTO TEAM_ROSTER(player_ssn, team_id, duel_id, start_time, end_time)
WITH duel_info AS (
    SELECT
        d.id AS duel_id,
        d.sport_category_id,
        d.home_team_id,
        d.away_team_id,
        d.start_time::date AS duel_date,   -- derive date from duel timestamp
        h_t.club_id AS home_club_id,
        a_t.club_id AS away_club_id,
        cat.team_capacity,
        cat.duration_minutes
    FROM duel d
    JOIN sport_team     h_t ON h_t.id  = d.home_team_id
    JOIN sport_team     a_t ON a_t.id  = d.away_team_id
    JOIN sport_category cat ON cat.id  = d.sport_category_id
    WHERE d.competition_id IS NOT NULL
),
-- Deduplicate first (multiple contracts → same player), then rank
players_home AS (
    SELECT
        duel_id, home_team_id AS team_id,
        player_ssn, team_capacity,
        duration_minutes,
        ROW_NUMBER() OVER (PARTITION BY duel_id ORDER BY random()) AS rn
    FROM (
        SELECT DISTINCT ON (d.duel_id, sc.player_ssn)
            d.duel_id, d.home_team_id,
            d.team_capacity, d.duration_minutes,
            sc.player_ssn
        FROM duel_info d
        JOIN sportsperson_contract sc
            ON sc.club_id = d.home_club_id
        -- Ensure player actually plays this sport category
        JOIN sportsperson sp
            ON sp.ssn = sc.player_ssn
            AND sp.sport_category_id = d.sport_category_id
        WHERE sc.start_date < d.duel_date
          AND (sc.end_date IS NULL OR sc.end_date > d.duel_date)
    ) deduped_home
),
players_away AS (
    SELECT
        duel_id, away_team_id AS team_id,
        player_ssn, team_capacity,
        duration_minutes,
        ROW_NUMBER() OVER (PARTITION BY duel_id ORDER BY random()) AS rn
    FROM (
        SELECT DISTINCT ON (d.duel_id, sc.player_ssn)
            d.duel_id, d.away_team_id,
            d.team_capacity, d.duration_minutes,
            sc.player_ssn
        FROM duel_info d
        JOIN sportsperson_contract sc
            ON sc.club_id = d.away_club_id
        JOIN sportsperson sp
            ON sp.ssn = sc.player_ssn
            AND sp.sport_category_id = d.sport_category_id
        WHERE sc.start_date < d.duel_date
          AND (sc.end_date IS NULL OR sc.end_date > d.duel_date)
    ) deduped_away
),
all_players AS (
    SELECT *
    FROM players_home
    WHERE rn <= team_capacity
    UNION ALL
    SELECT *
    FROM players_away
    WHERE rn <= team_capacity
)
SELECT
    p.player_ssn,
    p.team_id,
    p.duel_id,
    -- Players start at kick-off
    '00:00:00'::time AS start_time,
    CASE WHEN random() < 0.8
        THEN NULL
        ELSE (INTERVAL '1 minute'
              * floor(random() * p.duration_minutes + 1))::time
    END AS end_time
FROM all_players p
ON CONFLICT (player_ssn, team_id, duel_id) DO NOTHING;

-- Generating season-team relation
INSERT INTO season_sport_team(season_id, sport_team_id)
    SELECT s.id, st.id
    FROM season s
    JOIN national_league nl
        ON s.national_league_id = nl.id
    JOIN federation f
        ON f.id = nl.federation_id
    JOIN national_federation nf
        ON nf.id = f.id
    CROSS JOIN LATERAL (
        SELECT st.id
        FROM sport_team st
        JOIN sport_club sc
            ON st.club_id = sc.id
        JOIN sport_category scat
            ON st.sport_category_id = scat.id
        WHERE
            sc.country_id = nf.country_id
            AND scat.sport_id = f.sport_id
        ORDER BY random()
        LIMIT 20
) AS st;

-- Gnerating for Coaching_Team
WITH coaches AS (
    SELECT
        c.ssn,
        c.sport_category_id,
        row_number() over (PARTITION BY c.sport_category_id ORDER BY c.ssn) as rn
    FROM COACH c
),
sport_team AS (
    SELECT
        st.id,
        st.sport_category_id,
        row_number() over (PARTITION BY st.sport_category_id ORDER BY st.id) as rn
    FROM SPORT_TEAM st
)
INSERT INTO COACHING_TEAM (team_id, coach_ssn, start_date, end_date)
SELECT
    st.id as team_id,
    c.ssn as coach_ssn,
    (now() - (interval '7 year' * random()))::date AS start_date,
    CASE
        WHEN random() < 0.3 THEN NULL
        ELSE (now() + (interval '5 year' * random()))::date
    END AS end_date
FROM coaches c
JOIN sport_team st
    ON c.sport_category_id = st.sport_category_id
   AND c.rn = st.rn;
INSERT INTO COACHING_TEAM (team_id, coach_ssn, start_date, end_date)
SELECT
    st.id as team_id,
    c.ssn as coach_ssn,
    (now() - (interval '7 year' * random()))::date AS start_date,
    CASE
        WHEN random() < 0.3 THEN NULL
        ELSE (now() + (interval '5 year' * random()))::date
    END AS end_date
FROM COACH c
JOIN LATERAL (
    SELECT *
    FROM SPORT_TEAM st
    WHERE st.sport_category_id = c.sport_category_id
    ORDER BY random()
    LIMIT 1
) st ON TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM COACHING_TEAM ct
    WHERE ct.coach_ssn = c.ssn
);


--- Generating Scores
CREATE TEMP TABLE tmp_duel_outcome AS
    SELECT
        duel_id, home_team_id, away_team_id, duration_minutes, outcome,
        CASE
            WHEN outcome = 'home' THEN winner_goals
            WHEN outcome = 'away' THEN floor(random() * winner_goals)::int
            ELSE draw_goals
        END AS home_goals,
        CASE
            WHEN outcome = 'away' THEN winner_goals
            WHEN outcome = 'home' THEN floor(random() * winner_goals)::int
            ELSE draw_goals
        END AS away_goals
    FROM (
        SELECT
            d.id             AS duel_id,
            d.home_team_id,
            d.away_team_id,
            greatest(cat.duration_minutes, 1) AS duration_minutes,  -- guard against 0
            CASE
                WHEN rv < 0.34 THEN 'home'
                WHEN rv < 0.67 THEN 'away'
                ELSE                'draw'
            END                           AS outcome,
            floor(random() * 4 + 1)::int  AS winner_goals,   -- 1–4 goals for the winner
            floor(random() * 4    )::int  AS draw_goals       -- 0–3 goals each in a draw
        FROM duel d
        JOIN sport_category cat ON cat.id = d.sport_category_id
        -- Single random() call per duel — evaluated once, used for all three branches
        CROSS JOIN LATERAL (SELECT random()) AS x(rv)
    ) sub;

--- Agregating players
CREATE TEMP TABLE tmp_roster_arrays AS
    SELECT
        duel_id, team_id,
        array_agg(player_ssn ORDER BY random()) AS players,
        count(*)::int AS player_count
    FROM team_roster
    GROUP BY duel_id, team_id
;

CREATE INDEX ON tmp_roster_arrays (duel_id, team_id);

-- Generating scores
INSERT INTO SCORE (duel_id, player_ssn, time_score)
WITH home_scores AS (
    SELECT
        o.duel_id,
        r.players[1 + ((g.n - 1) % r.player_count)] AS player_ssn,
        (floor(random() * o.duration_minutes) * INTERVAL '1 minute')::time AS time_score
    FROM tmp_duel_outcome o
    JOIN LATERAL
        generate_series(1, o.home_goals) AS g(n)
        ON true
    JOIN tmp_roster_arrays r
        ON r.duel_id = o.duel_id
        AND r.team_id = o.home_team_id
),
away_scores AS (
    SELECT
        o.duel_id,
        r.players[1 + ((g.n - 1) % r.player_count)] AS player_ssn,
        (floor(random() * o.duration_minutes) * INTERVAL '1 minute')::time AS time_score
    FROM tmp_duel_outcome o
    JOIN LATERAL
        generate_series(1, o.away_goals) AS g(n)
        ON true
    JOIN tmp_roster_arrays r
        ON r.duel_id = o.duel_id
        AND r.team_id = o.away_team_id
)
SELECT
    duel_id, player_ssn, time_score
FROM home_scores
UNION ALL
SELECT
    duel_id, player_ssn, time_score
FROM away_scores;

DROP TABLE tmp_duel_outcome;
DROP TABLE tmp_roster_arrays;



--- Final report
SELECT 'club_federation' AS tablename, COUNT(*) FROM club_federation UNION ALL
SELECT 'coach', COUNT(*) FROM coach UNION ALL
SELECT 'coaching_team', COUNT(*) FROM coaching_team UNION ALL
SELECT 'competition', COUNT(*) FROM competition UNION ALL
SELECT 'competition_type', COUNT(*) FROM competition_type UNION ALL
SELECT 'country', COUNT(*) FROM country UNION ALL
SELECT 'country_region', COUNT(*) FROM country_region UNION ALL
SELECT 'duel', COUNT(*) FROM duel UNION ALL
SELECT 'federation', COUNT(*) FROM federation UNION ALL
SELECT 'international_federation', COUNT(*) FROM international_federation UNION ALL
SELECT 'national_federation', COUNT(*) FROM national_federation UNION ALL
SELECT 'national_league', COUNT(*) FROM national_league UNION ALL
SELECT 'location', COUNT(*) FROM location UNION ALL
SELECT 'person', COUNT(*) FROM person UNION ALL
SELECT 'referee', COUNT(*) FROM referee UNION ALL
SELECT 'refereeing_duel', COUNT(*) FROM refereeing_duel UNION ALL
SELECT 'region', COUNT(*) FROM region UNION ALL
SELECT 'score', COUNT(*) FROM score UNION ALL
SELECT 'season', COUNT(*) FROM season UNION ALL
SELECT 'season_sport_team', COUNT(*) FROM season_sport_team UNION ALL
SELECT 'sponsor', COUNT(*) FROM sponsor UNION ALL
SELECT 'sponsorship', COUNT(*) FROM sponsorship UNION ALL
SELECT 'sport', COUNT(*) FROM sport UNION ALL
SELECT 'sport_category', COUNT(*) FROM sport_category UNION ALL
SELECT 'sport_club', COUNT(*) FROM sport_club UNION ALL
SELECT 'sport_team', COUNT(*) FROM sport_team UNION ALL
SELECT 'sportsperson', COUNT(*) FROM sportsperson UNION ALL
SELECT 'sportsperson_contract', COUNT(*) FROM sportsperson_contract UNION ALL
SELECT 'team_roster', COUNT(*) FROM team_roster
ORDER BY tablename;


