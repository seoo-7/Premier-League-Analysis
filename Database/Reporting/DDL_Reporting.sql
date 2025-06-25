/*
===============================================================================
DDL Script: Create Reporting Schema Views for Football Analysis
===============================================================================
Script Purpose:
    This script creates a star schema for football analytics in the 'reporting' schema. 
    It includes dimension and fact views that transform raw data into an analysis-ready format.
*/

-- Create reporting schema
CREATE SCHEMA IF NOT EXISTS reporting;

-- Cleanup existing views
DROP VIEW IF EXISTS reporting.dim_date CASCADE;
DROP VIEW IF EXISTS reporting.dim_player CASCADE;
DROP VIEW IF EXISTS reporting.dim_season CASCADE;
DROP VIEW IF EXISTS reporting.dim_club CASCADE;
DROP VIEW IF EXISTS reporting.fact_match CASCADE;
DROP VIEW IF EXISTS reporting.fact_transfer CASCADE;
DROP VIEW IF EXISTS reporting.fact_injuries CASCADE;
DROP VIEW IF EXISTS reporting.fact_player_performance CASCADE;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- 1. dim_date view
CREATE OR REPLACE VIEW reporting.dim_date AS
SELECT DISTINCT
    CAST(TO_CHAR(d::DATE, 'YYYYMMDD') AS INTEGER) AS date_key,
    d::DATE AS date,
    EXTRACT(YEAR FROM d) AS year,
    EXTRACT(QUARTER FROM d) AS quarter,
    EXTRACT(MONTH FROM d) AS month,
    TO_CHAR(d, 'Month') AS month_name,
    EXTRACT(DAY FROM d) AS day,
    EXTRACT(DOW FROM d) AS day_of_week,
    TO_CHAR(d, 'Day') AS day_name
FROM (
    SELECT from_date AS d FROM transform.pl_injuries WHERE from_date IS NOT NULL
    UNION 
    SELECT until_date FROM transform.pl_injuries WHERE until_date IS NOT NULL
    UNION
    SELECT 
        MAKE_DATE(
            year, 
            CASE
                WHEN month ILIKE 'January' THEN 1
                WHEN month ILIKE 'February' THEN 2
                WHEN month ILIKE 'March' THEN 3
                WHEN month ILIKE 'April' THEN 4
                WHEN month ILIKE 'May' THEN 5
                WHEN month ILIKE 'June' THEN 6
                WHEN month ILIKE 'July' THEN 7
                WHEN month ILIKE 'August' THEN 8
                WHEN month ILIKE 'September' THEN 9
                WHEN month ILIKE 'October' THEN 10
                WHEN month ILIKE 'November' THEN 11
                WHEN month ILIKE 'December' THEN 12
            END,
            day
        ) AS d 
    FROM transform.pl_match 
    WHERE year IS NOT NULL AND month IS NOT NULL AND day IS NOT NULL
) dates;

-- 2. dim_player view
CREATE OR REPLACE VIEW reporting.dim_player AS
SELECT 
    player_name AS player_key,
    player_name,
    COALESCE(
        MAX(CASE WHEN position IS NOT NULL THEN position END),
        'Unknown'
    ) AS position
FROM (
    SELECT player_name, position FROM transform.pl_transfers 
    UNION ALL
    SELECT Player AS player_name, NULL AS position FROM transform.topscores_Goals
    UNION ALL
    SELECT Player AS player_name, NULL AS position FROM transform.topscores_Assists
) players
WHERE player_name IS NOT NULL
GROUP BY player_name;

-- 3. dim_season view
CREATE OR REPLACE VIEW reporting.dim_season AS
SELECT 
    season AS season_key,
    season,
    ROW_NUMBER() OVER (ORDER BY season) AS season_sort_order
FROM (
    SELECT DISTINCT season 
    FROM transform.pl_match
    WHERE season IS NOT NULL
    UNION
    SELECT DISTINCT season 
    FROM transform.pl_transfers
    WHERE season IS NOT NULL
    UNION
    SELECT DISTINCT season 
    FROM transform.pl_injuries
    WHERE season IS NOT NULL
    UNION
    SELECT DISTINCT Season 
    FROM transform.topscores_Goals
    WHERE Season IS NOT NULL
    UNION
    SELECT DISTINCT Season 
    FROM transform.topscores_Assists
    WHERE Season IS NOT NULL
) seasons;

-- 4. dim_club view
CREATE OR REPLACE VIEW reporting.dim_club AS
WITH premier_league_clubs AS (
    SELECT DISTINCT club_name
    FROM (
        SELECT HomeTeam AS club_name FROM transform.pl_match
        UNION
        SELECT AwayTeam FROM transform.pl_match
    ) match_clubs
    WHERE club_name IS NOT NULL
),
all_club_data AS (
    SELECT DISTINCT club_name
    FROM (
        SELECT HomeTeam AS club_name FROM transform.pl_match
        UNION
        SELECT AwayTeam FROM transform.pl_match
        UNION
        SELECT club_name FROM transform.pl_transfers
        UNION
        SELECT club_involved_name FROM transform.pl_transfers
        UNION
        SELECT club FROM transform.pl_injuries
        UNION
        SELECT Club FROM transform.topscores_Goals
        UNION
        SELECT Club FROM transform.topscores_Assists
    ) clubs
    WHERE club_name IS NOT NULL
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY club_name) AS club_key,
    club_name,
    CASE 
        WHEN club_name IN (SELECT club_name FROM premier_league_clubs) 
        THEN 'Premier League'
        ELSE 'Other League'
    END AS league_type
FROM all_club_data;

-- =====================================================
-- FACT TABLES 
-- =====================================================
CREATE OR REPLACE VIEW reporting.fact_match AS
SELECT 
    -- Surrogate key for the match
    ROW_NUMBER() OVER (ORDER BY s.season_key, 
                      TO_CHAR(TO_DATE(CAST(m.year AS TEXT) || ' ' || m.month || ' ' || m.day, 'YYYY Month DD'), 'YYYYMMDD')::INT,
                      hc.club_key, ac.club_key) AS match_key,
    
    -- Date and season keys 
    TO_CHAR(TO_DATE(CAST(m.year AS TEXT) || ' ' || m.month || ' ' || m.day, 'YYYY Month DD'), 'YYYYMMDD')::INT AS date_key,
    s.season_key,
    
    -- Club keys (these are the keys that will connect to dim_club)
    hc.club_key AS home_club_key,
    ac.club_key AS away_club_key,
    
    -- Match result and scores
    m.FTR AS full_time_result,
    m.FTHG AS full_time_home_goals,
    m.FTAG AS full_time_away_goals,
    m.HTHG AS half_time_home_goals,
    m.HTAG AS half_time_away_goals,
    
    -- Match statistics
	COALESCE(m.hstarget, 0) AS home_shots_target,
    COALESCE(m.astarget, 0) AS away_shots_target,
    COALESCE(m.HomeShot, 0) AS home_shots,
    COALESCE(m.AwayShot, 0) AS away_shots,
    COALESCE(m.HomeFouls, 0) AS home_fouls,
    COALESCE(m.AwayFouls, 0) AS away_fouls,
    COALESCE(m.HomeCorner, 0) AS home_corners,
    COALESCE(m.AwayCorner, 0) AS away_corners,
    COALESCE(m.HomeYellowC, 0) AS home_yellow_cards,
    COALESCE(m.AwayYellowC, 0) AS away_yellow_cards,
    COALESCE(m.HomeRedC, 0) AS home_red_cards,
    COALESCE(m.AwayRedC, 0) AS away_red_cards,
    
    -- Calculated fields for easier DAX
    CASE 
        WHEN m.FTR = 'H' THEN hc.club_key
        WHEN m.FTR = 'A' THEN ac.club_key
        ELSE NULL
    END AS winning_club_key,
    
    CASE 
        WHEN m.FTR = 'H' THEN ac.club_key
        WHEN m.FTR = 'A' THEN hc.club_key
        ELSE NULL
    END AS losing_club_key,
    
    -- Goal difference from home team perspective
    (m.FTHG - m.FTAG) AS home_goal_difference
    
FROM transform.pl_match m
JOIN reporting.dim_season s ON m.Season = s.season_key
JOIN reporting.dim_club hc ON m.HomeTeam = hc.club_name
JOIN reporting.dim_club ac ON m.AwayTeam = ac.club_name
WHERE m.year IS NOT NULL AND m.month IS NOT NULL AND m.day IS NOT NULL;


-- 2. fact_transfer 
CREATE OR REPLACE VIEW reporting.fact_transfer AS
SELECT 
    p.player_key,
    s.season_key,
    t.fee,
    COALESCE(t.fee_cleaned, 0) AS transfer_fee,
    COALESCE(t.age, 0) AS age,
    t.transfer_movement,   
	t.transfer_period,

	  CASE 
            WHEN fee ILIKE '%loan%' THEN 'Loan'
            WHEN fee = 'Free' OR fee = 'Academy' OR fee = '%free%' THEN 'Free'
            ELSE 'Permanent'
        END AS transfer_type , 
    -- Selling club key (for relationship with dim_club)
    CASE 
        WHEN t.transfer_movement = 'in' THEN selling_club.club_key  -- Player coming FROM the other club
        WHEN t.transfer_movement = 'out' THEN reporting_club.club_key -- Player going FROM this club
        ELSE selling_club.club_key  -- Default fallback
    END AS selling_club_key,
    
    -- Buying club key (for relationship with dim_club)
    CASE 
        WHEN t.transfer_movement = 'in' THEN reporting_club.club_key  -- Player coming TO this club
        WHEN t.transfer_movement = 'out' THEN buying_club.club_key -- Player going TO the other club
        ELSE reporting_club.club_key 
    END AS buying_club_key,
    
    -- Club names for reference
    CASE 
        WHEN t.transfer_movement = 'in' THEN t.club_involved_name  -- Player coming FROM the other club
        WHEN t.transfer_movement = 'out' THEN t.club_name -- Player going FROM this club
        ELSE t.club_involved_name  
    END AS selling_club_name,
    
    CASE 
        WHEN t.transfer_movement = 'in' THEN t.club_name  -- Player coming TO this club
        WHEN t.transfer_movement = 'out' THEN t.club_involved_name -- Player going TO the other club
        ELSE t.club_name  
    END AS buying_club_name
    
FROM transform.pl_transfers t
JOIN reporting.dim_season s ON t.season = s.season_key
JOIN reporting.dim_player p ON t.player_name = p.player_key
JOIN reporting.dim_club reporting_club ON t.club_name = reporting_club.club_name
JOIN reporting.dim_club selling_club ON 
    CASE 
        WHEN t.transfer_movement = 'in' THEN t.club_involved_name
        WHEN t.transfer_movement = 'out' THEN t.club_name
        ELSE t.club_involved_name
    END = selling_club.club_name
JOIN reporting.dim_club buying_club ON 
    CASE 
        WHEN t.transfer_movement = 'in' THEN t.club_name
        WHEN t.transfer_movement = 'out' THEN t.club_involved_name
        ELSE t.club_name
    END = buying_club.club_name
-- Include all transfers that involve at least one Premier League club
WHERE reporting_club.league_type = 'Premier League' 
   OR selling_club.league_type = 'Premier League' 
   OR buying_club.league_type = 'Premier League';

-- 3. fact_injuries 
CREATE OR REPLACE VIEW reporting.fact_injuries AS
SELECT 
	i.player_name,
    c.club_key,
    s.season_key,
    CAST(TO_CHAR(i.from_date, 'YYYYMMDD') AS INTEGER) AS date_key,
    i.days_missed,
    i.games_missed, 
	i.injury,
    i.injury_severity,
    i.position
FROM transform.pl_injuries i
JOIN reporting.dim_season s ON i.season = s.season_key
JOIN reporting.dim_club c ON i.club = c.club_name


-- 4. fact_player_performance 
CREATE OR REPLACE VIEW reporting.fact_player_performance AS
SELECT 
    p.player_key,
    c.club_key,
    s.season_key,
    g.Goals,
    a.Assists,
FROM transform.topscores_Goals g
FULL OUTER JOIN transform.topscores_Assists a
    ON g.Player = a.Player 
    AND g.Club = a.Club 
    AND g.Season = a.Season
JOIN reporting.dim_season s 
    ON COALESCE(g.Season, a.Season) = s.season_key
JOIN reporting.dim_club c 
    ON COALESCE(g.Club, a.Club) = c.club_name
JOIN reporting.dim_player p 
    ON COALESCE(g.Player, a.Player) = p.player_key
WHERE c.league_type = 'Premier League';