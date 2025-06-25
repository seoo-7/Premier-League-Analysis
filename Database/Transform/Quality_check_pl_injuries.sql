/*
===============================================================================
Quality Checks - Injuries Data
=============================================================================== 
Script Purpose:
    This script performs quality checks for data standardization, consistency, 
    and missing value handling in the 'staging.pl_injuries' table
*/ 

-- ====================================================================
-- Checking 'staging.pl_injuries' -> Identify data issues before loaded to transform layer
-- ====================================================================

-- 1. Check for season format inconsistencies
-- Preview distinct seasons
select distinct season from staging.pl_injuries;

-- Standardize season formatting
SELECT 
    player_name,
    CASE 
        WHEN season = '10-Sep' THEN '10/11'
        WHEN season = '11-Oct' THEN '11/12'
        WHEN season = '12-Nov' THEN '12/13'
        WHEN season = '13-Dec' THEN '13/14'
        ELSE season 
    END AS season,
    injury,
    from_date,
    Until_date,
    days_missed,
    games_missed,
    club,
    position
FROM staging.pl_injuries;

-----------------------------------------------------------------------
-- 2. Check for club name standardization
-- Preview distinct clubs
SELECT DISTINCT club FROM staging.pl_injuries;

-- Standardize club names
SELECT DISTINCT
    club AS before_standardization,
    CASE 
        WHEN club IN ('Newcastle United', 'West Ham United') THEN TRIM(REPLACE(club, ' United', ''))  
        WHEN club = 'Manchester United' THEN 'Man United'
        WHEN club = 'Manchester City' THEN 'Man City'
        WHEN club = 'Leicester City' THEN 'Leicester' 
        WHEN club = 'Nottingham Forest' THEN 'Nottm Forest'
        ELSE club
    END AS after_standardization
FROM staging.pl_injuries;

-----------------------------------------------------------------------
-- 3. Check for missing games_missed values
-- Identify null games_missed records
SELECT * FROM staging.pl_injuries WHERE games_missed IS NULL;

-- Impute missing games_missed values
SELECT 
    player_name,
    season,
    injury,
    from_date,
    until_date,
    days_missed,
    club,
    position,
    -- Calculate games_missed: use existing value if not null, otherwise calculate
    CASE 
        WHEN games_missed IS NOT NULL THEN games_missed
        ELSE
             CASE 
                -- Check if injury occurs during the season (16 August to 22 May)
                WHEN (
                    -- Injury starts during season
                    (
                        (EXTRACT(MONTH FROM from_date::DATE) = 8 AND EXTRACT(DAY FROM from_date::DATE) >= 16) OR                      
                        (EXTRACT(MONTH FROM from_date::DATE) = 5 AND EXTRACT(DAY FROM from_date::DATE) <= 22)
                    ) OR
                    -- Injury ends during season
                    (
                        (EXTRACT(MONTH FROM until_date::DATE) = 8 AND EXTRACT(DAY FROM until_date::DATE) >= 16) OR                      
                        (EXTRACT(MONTH FROM until_date::DATE) = 5 AND EXTRACT(DAY FROM until_date::DATE) <= 22)
                    )
                ) THEN 
                    -- Calculate games missed: every 3+ days = 1 game missed
                    CASE 
                        WHEN days_missed >= 3 THEN (days_missed / 3)::INTEGER
                        ELSE 0
                    END
                ELSE 
                    -- Injury during off-season (23 May to 15 August) = 0 games missed
                    0
            END
    END AS games_missed,
FROM staging.pl_injuries;