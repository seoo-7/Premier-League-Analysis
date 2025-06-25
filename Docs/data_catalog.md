# Data Catalog for Transform Layer

## Overview
The Transform Layer structures raw data into an analysis-ready format optimized for business intelligence. It contains denormalized tables with cleaned, integrated data ready for the reporting Layer.

---
### 1. **transform.pl_match**
- **Purpose:** Stores comprehensive match statistics for Premier League games
- **Columns:**

| Column Name    | Data Type     | Description                                                                 |
|----------------|---------------|-----------------------------------------------------------------------------|
| HomeTeam       | VARCHAR(50)   | Name of the home team                                                       |
| FTHG           | INT           | Full-time home goals scored                                                 |
| AwayTeam       | VARCHAR(50)   | Name of the away team                                                       |
| FTAG           | INT           | Full-time away goals scored                                                 |
| FTR            | CHAR(1)       | Full-time result (H=Home win, A=Away win, D=Draw)                          |
| Season         | VARCHAR(10)   | Football season identifier (e.g., "2021/2022")                              |
| Year           | INT           | Year of the match                                                           |
| Month          | VARCHAR(10)   | Month of the match                                                          |
| Day            | INT           | Day of the month                                                            |
| HTHG           | INT           | Half-time home goals scored                                                 |
| HTAG           | INT           | Half-time away goals scored                                                 |
| HTR            | CHAR(1)       | Half-time result (H/A/D)                                                    |
| HomeShot       | INT           | Total shots taken by home team                                              |
| AwayShot       | INT           | Total shots taken by away team                                              |
| HSTarget       | INT           | Shots on target by home team                                                |
| ASTarget       | INT           | Shots on target by away team                                                |
| HomeFouls      | INT           | Fouls committed by home team                                                |
| AwayFouls      | INT           | Fouls committed by away team                                                |
| HomeCorner     | INT           | Corners won by home team                                                    |
| AwayCorner     | INT           | Corners won by away team                                                    |
| HomeYellowC    | INT           | Yellow cards for home team                                                  |
| AwayYellowC    | INT           | Yellow cards for away team                                                  |
| HomeRedC       | INT           | Red cards for home team                                                     |
| AwayRedC       | INT           | Red cards for away team                                                     |

---

### 2. **transform.pl_transfers**
- **Purpose:** Contains player transfer records within the Premier League
- **Columns:**

| Column Name         | Data Type     | Description                                                                 |
|---------------------|---------------|-----------------------------------------------------------------------------|
| club_name           | VARCHAR(50)   | Current club receiving/selling player                                       |
| player_name         | VARCHAR(50)   | Full name of transferred player                                             |
| age                 | FLOAT         | Player's age at time of transfer                                            |
| position            | VARCHAR(50)   | Player's position (e.g., Forward, Midfielder)                              |
| club_involved_name  | VARCHAR(50)   | Counterparty club in transfer                                               |
| fee                 | VARCHAR(100)  | Original transfer fee description (raw)                                     |
| transfer_movement   | VARCHAR(10)   | Direction (in/out) relative to main club                                    |
| transfer_period     | VARCHAR(10)   | Transfer window period (e.g., Summer, Winter)                               |
| fee_cleaned         | FLOAT         | Normalized transfer fee in numerical format                                |
| league_name         | VARCHAR(50)   | League name (default: Premier League)                                       |
| year                | INT           | Calendar year of transfer                                                   |
| season              | VARCHAR(10)   | Football season of transfer                                                 |
| country             | VARCHAR(50)   | Player's nationality                                                        |
| transfer_type       | VARCHAR(50)   | Type of transfer (e.g., Permanent, Loan)                                    |

---

### 3. **transform.pl_injuries**
- **Purpose:** Tracks player injury records in the Premier League
- **Columns:**

| Column Name        | Data Type     | Description                                                                 |
|--------------------|---------------|-----------------------------------------------------------------------------|
| player_name        | VARCHAR(50)   | Full name of injured player                                                |
| season             | VARCHAR(10)   | Football season of injury                                                   |
| injury             | VARCHAR(100)  | Type/description of injury                                                  |
| from_date          | DATE          | Injury start date                                                           |
| until_date         | DATE          | Estimated recovery date                                                     |
| days_missed        | INT           | Total days player unavailable                                               |
| games_missed       | INT           | Matches player missed due to injury                                         |
| club               | VARCHAR(50)   | Player's club at time of injury                                             |
| position           | VARCHAR(50)   | Player's position                                                           |
| injury_severity    | VARCHAR(30)   | Classification of injury severity (e.g., Minor, Major)                      |

---

### 4. **transform.topscores_Goals**
- **Purpose:** Contains seasonal top goal scorers in Premier League
- **Columns:**

| Column Name    | Data Type     | Description                                                                 |
|----------------|---------------|-----------------------------------------------------------------------------|
| Season         | VARCHAR(9)    | Football season identifier (e.g., "2021/22")                                |
| Player         | VARCHAR(50)   | Name of top-scoring player                                                  |
| Club           | VARCHAR(30)   | Player's club during the season                                             |
| Goals          | INTEGER       | Total goals scored in the season                                            |

---

### 5. **transform.topscores_Assists**
- **Purpose:** Contains seasonal top assist providers in Premier League
- **Columns:**

| Column Name    | Data Type     | Description                                                                 |
|----------------|---------------|-----------------------------------------------------------------------------|
| Season         | VARCHAR(9)    | Football season identifier                                                  |
| Player         | VARCHAR(50)   | Name of player with most assists                                            |
| Club           | VARCHAR(30)   | Player's club during the season                                             |
| Assists        | INTEGER       | Total assists provided in the season                                        |