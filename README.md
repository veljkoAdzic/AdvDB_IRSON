# Sports Management Database - IRSON

A relational database system for managing sports competitions, clubs, players, referees, and leagues. Designed to handle the full lifecycle of organized sport — from federation structure down to individual match rosters and scoring.

---

## Overview

This database models a hierarchical sports organization system covering:

- International and national federation structures
- Sport clubs, teams, and player contracts
- League seasons and competitions
- Match (duel) scheduling, rosters, and scoring
- Referee assignments and availability
- Sponsorship and donations

---

## Schema Structure

### Sports & Categories
- **SPORT** — top-level sport (e.g. Football, Basketball)
- **SPORT_CATEGORY** — a specific variant of a sport defined by gender, duration, team capacity, and point rules

### Geography
- **COUNTRY** — countries with abbreviations
- **REGION** — regions, optionally part of a country
- **COUNTRY_REGION** — many-to-many link between countries and regions

### Federations
- **FEDERATION** — base federation entity tied to a sport
- **INTERNATIONAL_FEDERATION** — specialization of FEDERATION at international level
- **NATIONAL_FEDERATION** — specialization of FEDERATION at national level, linked to a country and its international parent

### Clubs & Teams
- **SPORT_CLUB** — a club registered under a national federation; can be a national representation
- **CLUB_FEDERATION** — tracks a club's federation membership over time
- **SPORT_TEAM** — a team within a club
- **SEASON_SPORT_TEAM** — teams participating in a given season

### Leagues & Seasons
- **NATIONAL_LEAGUE** — a league organized by a national federation, optionally tied to a region
- **SEASON** — a time-bounded season within a league

### People
- **PERSON** — base entity for all individuals (SSN, name, DOB, gender, country)
- **SPORTSPERSON** — a PERSON who competes, linked to a sport category
- **COACH** — a PERSON who coaches, linked to a sport category and federation
- **REFEREE** — a PERSON who referees, linked to a sport category and federation

### Contracts & Rosters
- **SPORTSPERSON_CONTRACT** — a player's contract with a club over a date range
- **COACHING_TEAM** — assignment of a coach to a team over a date range
- **TEAM_ROSTER** — a player's participation in a specific duel, with substitution support via start/end time

### Competitions & Duels
- **COMPETITION_TYPE** — classification of competition format
- **COMPETITION** — a competition organized by a federation, optionally tied to a season
- **DUEL** — a single match between two teams at a location, under a sport category
- **SCORE** — individual scoring events within a duel
- **REFEREEING_DUEL** — assignment of referees to duels

### Venues & Sponsors
- **LOCATION** — a venue with capacity, tied to a country
- **SPONSOR** — a sponsoring entity
- **DONATION** — a donation from a sponsor to a team on a specific date

---

## Business Rules & Triggers

### `trg_check_contract` → `check_contract_club()`
Fires on `SPORTSPERSON_CONTRACT` insert/update. Enforces:
- A player cannot sign with a national team from a different country
- A player cannot have two overlapping club contracts
- A player cannot have two overlapping national team contracts

### `trg_check_team_roster` → `check_team_roster_contract()`
Fires on `TEAM_ROSTER` insert/update. Enforces:
- Active players on the field cannot exceed the sport category's `team_capacity`
- Substitutions are allowed — a player is considered active while `end_time IS NULL`
- A player must have an active contract with the team's club on the duel date
- A player cannot be rostered for two different teams in the same duel

### `trg_check_team_sport_and_rep` → `check_duel_validity()`
Fires on `DUEL` insert/update. Enforces:
- Both teams must belong to the same sport as the duel's sport category
- Both teams must have the same representation status (club vs national)
- Both clubs must have an active federation membership on the match date

### `trg_limit_referee_daily_duels` → `check_referee_availability()`
Fires on `REFEREEING_DUEL` insert/update. Enforces:
- The referee's sport category must match the duel's sport category
- The referee cannot be assigned to two overlapping duels (based on start time + duration)

---

## Helper Function

```sql
valid_date_range(start_date date, end_date date) RETURNS boolean
```
Returns `true` if `end_date` is NULL or strictly after `start_date`. Used across multiple tables to validate date ranges consistently.

---

## Key Design Decisions

- **Inheritance via FK** — `INTERNATIONAL_FEDERATION` and `NATIONAL_FEDERATION` both extend `FEDERATION` using a shared primary key with a cascading foreign key, implementing table-per-type inheritance.
- **Substitution model** — `TEAM_ROSTER` uses `start_time` and `end_time` (type `time`) to track when a player is on the field during a duel. Setting `end_time` on a player before inserting their replacement allows substitutions without breaching capacity.
- **Soft membership** — `CLUB_FEDERATION` tracks federation membership over time with start/end dates rather than a simple foreign key, allowing historical records.
- **National representation** — `SPORT_CLUB.is_national_representation` distinguishes club teams from national teams, enforced at the contract and duel level.

---

## Entity Relationship Diagram

See the included ERD diagram for a full visual overview of table relationships.
