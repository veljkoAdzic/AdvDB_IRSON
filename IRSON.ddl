CREATE OR REPLACE FUNCTION valid_date_range(start_date date, end_date date)
RETURNS boolean
LANGUAGE sql
AS $$
    SELECT end_date IS NULL OR start_date < end_date;
$$;
-- test
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
    federation_id              int4         NOT NULL,
    name                       varchar(40)  NOT NULL,
    is_national_representation bool         NOT NULL,
    country_id                 int4         NOT NULL,
    PRIMARY KEY (id),
    UNIQUE(name, country_id),
    FOREIGN KEY (country_id) REFERENCES COUNTRY (id) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT nat_fed_fk FOREIGN KEY (federation_id) REFERENCES NATIONAL_FEDERATION (id) ON DELETE RESTRICT ON UPDATE CASCADE
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
    id        SERIAL NOT NULL,
    club_id   int4 NOT NULL,
    name      varchar(40) NOT NULL,
    PRIMARY KEY (id),
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

CREATE OR REPLACE FUNCTION check_duel_validity()
RETURNS TRIGGER AS $$
DECLARE
    match_date DATE;
    duel_sport_id INT;

    home_club_id INT;
    away_club_id INT;

    home_is_rep BOOLEAN;
    away_is_rep BOOLEAN;

    home_federation_active BOOLEAN;
    away_federation_active BOOLEAN;
BEGIN
    match_date := NEW.start_time::DATE;

    SELECT sport_id
    INTO duel_sport_id
    FROM sport_category
    WHERE id = NEW.sport_category_id;

    IF duel_sport_id IS NULL THEN
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
        FROM sport_club c
        JOIN federation f ON f.id = c.federation_id
        WHERE c.id = home_club_id
          AND f.sport_id = duel_sport_id
    ) THEN
        RAISE EXCEPTION
            'Home team must play the same sport as the duel.';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM sport_club c
        JOIN federation f ON f.id = c.federation_id
        WHERE c.id = away_club_id
          AND f.sport_id = duel_sport_id
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

