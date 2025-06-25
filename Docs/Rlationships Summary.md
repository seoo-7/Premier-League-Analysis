# Reporting Layer: Star Schema Relationships

## Dimension Tables
| View          | Key Column    | Description                     |
|---------------|---------------|---------------------------------|
| `dim_date`    | `date_key`    | Calendar dates for all events   |
| `dim_player`  | `player_key`  | Player names and positions      |
| `dim_season`  | `season_key`  | Football seasons               |
| `dim_club`    | `club_key`    | Clubs with league classification|

## Fact Tables and Their Relationships
### 1. `fact_match` (Match Statistics)
- **Links to:**
  - `dim_date` via `date_key`
  - `dim_season` via `season_key`
  - `dim_club` via:
    - `home_club_key`
    - `away_club_key`
    - `winning_club_key`
    - `losing_club_key`

### 2. `fact_transfer` (Player Transfers)
- **Links to:**
  - `dim_player` via `player_key`
  - `dim_season` via `season_key`
  - `dim_club` via:
    - `selling_club_key`
    - `buying_club_key`

### 3. `fact_injuries` (Player Injuries)
- **Links to:**
  - `dim_season` via `season_key`
  - `dim_club` via `club_key`
  - `dim_date` via `date_key` (injury start date)

### 4. `fact_player_performance` (Seasonal Performance)
- **Links to:**
  - `dim_player` via `player_key`
  - `dim_season` via `season_key`
  - `dim_club` via `club_key`

