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