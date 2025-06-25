/* 
Stored Procedure => Load Transform Layer (Staging -> Transform)
=========================================================================
Script Purpose:
    This stored procedure loads data into the 'transform' schema from staging tables.
    It performs the following actions:
    - Applies data quality checks and standardizations
    - Handles data transformations
    - Loads clean data into transform tables

Usage Example:
    CALL transform.load_transform();
*/
--select * from transform.pl_transfers

CREATE OR REPLACE PROCEDURE transform.load_transform()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Clear transform tables before loading
    TRUNCATE TABLE transform.pl_transfers;
    
    -- Load transfers data with all transformations and quality fixes
    INSERT INTO transform.pl_transfers (
        club_name,
        player_name,
        age,
        position,
        club_involved_name,
        fee,
        transfer_movement,
        transfer_period,
        fee_cleaned,
        league_name,
        year,
        season,
        country,
       
    )
    SELECT 
        -- Standardize club names
        CASE 
            WHEN club_name = 'Wolverhampton Wanderers' THEN 'Wolves'
            WHEN club_name = 'West Bromwich Albion' THEN 'West Brom'
            WHEN club_name = 'Queens Park Rangers' THEN 'QPR'
            WHEN club_name = 'Tottenham Hotspur' THEN 'Tottenham'
            WHEN club_name = 'Brighton & Hove Albion' THEN 'Brighton'
            WHEN club_name = 'Blackburn Rovers' THEN 'Blackburn'
            WHEN club_name = 'Bolton Wanderers' THEN 'Bolton'
            WHEN club_name = 'Huddersfield Town' THEN 'Huddersfield'
            WHEN club_name = 'Nottingham Forest' THEN 'Nottm Forest'
            WHEN club_name = 'Wigan Athletic' THEN 'Wigan'
			when club_name = 'Manchester United' Then 'Man United'
			when club_name = 'Manchester City' Then 'Man City'

			--Remove 'FC' suffix 
            WHEN club_name LIKE '% FC' THEN TRIM(REPLACE(club_name, ' FC', ''))
			--Remove 'AFC ' prefix
            WHEN club_name LIKE 'AFC %' THEN TRIM(REPLACE(club_name, 'AFC ', ''))
			--Remove 'AFC ' suffix
            WHEN club_name like '% AFC' THEN TRIM(REPLACE(club_name, ' AFC', ''))
			
		--Remove 'City' suffix for clubs 
            WHEN club_name IN ('Hull City', 'Leicester City', 'Norwich City','Cardiff City','Swansea City') 
                THEN TRIM(REPLACE(club_name, ' City', ''))
				
				--Remove 'Uinted' suffix for clubs 
            WHEN club_name IN ('Leeds United','Newcastle United','Sheffield United','West Ham United') 
                THEN TRIM(REPLACE(club_name, ' United', ''))
            ELSE club_name
        END AS club_name,
        
        player_name,
        age,
        position,
        
        -- Standardize involved club names (same as club_name)
        CASE 
            WHEN club_involved_name = 'Wolverhampton Wanderers' THEN 'Wolves'
            WHEN club_involved_name = 'West Bromwich Albion' THEN 'West Brom'
            WHEN club_involved_name = 'Queens Park Rangers' THEN 'QPR'
            WHEN club_involved_name = 'Tottenham Hotspur' THEN 'Tottenham'
            WHEN club_involved_name = 'Brighton & Hove Albion' THEN 'Brighton'
            WHEN club_involved_name = 'Blackburn Rovers' THEN 'Blackburn'
            WHEN club_involved_name = 'Bolton Wanderers' THEN 'Bolton'
            WHEN club_involved_name = 'Huddersfield Town' THEN 'Huddersfield'
            WHEN club_involved_name = 'Nottingham Forest' THEN 'Nottm Forest'
            WHEN club_involved_name = 'Wigan Athletic' THEN 'Wigan'
			when club_involved_name  = 'Manchester United' Then 'Man United'
			when club_involved_name  = 'Manchester City' Then 'Man City'
			
            WHEN club_involved_name LIKE '% FC' THEN TRIM(REPLACE(club_involved_name, ' FC', ''))
            WHEN club_involved_name LIKE 'AFC %' THEN TRIM(REPLACE(club_involved_name, 'AFC ', ''))
            WHEN club_involved_name like '% AFC' THEN TRIM(REPLACE(club_involved_name, ' AFC', ''))
			
            WHEN club_involved_name IN ('Hull City', 'Leicester City', 'Norwich City','Cardiff City','Swansea City') 
                THEN TRIM(REPLACE(club_involved_name, ' City', ''))
				
            WHEN club_involved_name IN ('Leeds United','Newcastle United','Sheffield United','West Ham United') 
                THEN TRIM(REPLACE(club_involved_name, ' United', ''))
            ELSE club_involved_name
        END AS club_involved_name,
        
        -- Handle fee values
        CASE 
            -- Youth team transfers
            WHEN club_involved_name LIKE '%U18%' 
                OR club_involved_name LIKE '%U21%'
                OR club_involved_name LIKE '%U23%'
                OR club_involved_name LIKE '%Res.%'
                OR club_involved_name LIKE '%Reserves%'
                OR club_involved_name LIKE '%Youth%'
                OR club_involved_name LIKE '% B' 
                OR club_involved_name LIKE '%Academy%'
                THEN 'Academy'
            
            -- Retired/Without Club transfers
            WHEN club_involved_name = 'Retired'
                OR club_involved_name = 'Without Club'
                OR club_involved_name = 'Career break'
                OR club_involved_name = 'Ban'
                THEN 'Free'           
     
            ELSE fee
        END AS fee,
        
        transfer_movement,
        transfer_period,
        
        -- Handle fee_cleaned values
        CASE 
            -- Both youth teams and retired/without club get 0
            WHEN club_involved_name LIKE '%U18%' 
                OR club_involved_name LIKE '%U21%'
                OR club_involved_name LIKE '%U23%'
                OR club_involved_name LIKE '%Res.%'
                OR club_involved_name LIKE '%Reserves%'
                OR club_involved_name LIKE '%Youth%'
                OR club_involved_name LIKE '% B'
                OR club_involved_name LIKE '%Academy%'
                OR club_involved_name = 'Retired'
                OR club_involved_name = 'Without Club'
                OR club_involved_name = 'Career break'
                OR club_involved_name = 'Ban'
                THEN 0         
           
            ELSE fee_cleaned
        END AS fee_cleaned,
        
        league_name,
        year,
		  -- convert season from 2011/2012 to 11/12
          CONCAT(
			    SUBSTRING(season, 3, 2),
			    '/',
			    SUBSTRING(season, 8, 2)
			  ),
        country,
        -- Added transfer type calculation
		/*
        CASE 
            WHEN fee ILIKE '%loan%' THEN 'Loan'
            WHEN fee = 'Free' OR fee = 'Academy' THEN 'Free'
            ELSE 'Permanent'
        END AS transfer_type*/
    FROM staging.pl_transfers;
    
    RAISE NOTICE 'pl_transfers table transformed and loaded successfully';


----------------------------------------------------------------------------------
--  select * from transform.pl_injuries
-- pl_injuries table : 
	
	TRUNCATE TABLE transform.pl_injuries;
	 -- Load transfers data with all transformations and quality fixes
  INSERT INTO transform.pl_injuries(
    player_name,
    season,
    injury,
    from_date,
    until_date,
    days_missed,
    games_missed,
    club,
    position,
    injury_severity  
)  
SELECT 
    player_name,
    -- Fixed season transformation 
    CASE 
        WHEN season = '10-Sep' THEN '10/11'
        WHEN season = '11-Oct' THEN '11/12'
        WHEN season = '12-Nov' THEN '12/13'
        WHEN season = '13-Dec' THEN '13/14'
        ELSE season 
    END AS season,
    injury,  
    -- Explicitly cast dates 
    from_date::DATE AS from_date,
    until_date::DATE AS until_date,
    days_missed, 
    -- Fixed games_missed calculation 
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
                ELSE 0                   
            END
    END AS games_missed,
    -- Fixed club transformation 
    CASE 
        WHEN club IN ('Newcastle United', 'West Ham United') THEN TRIM(REPLACE(club, ' United', ''))  
        WHEN club = 'Manchester United' THEN 'Man United'
        WHEN club = 'Manchester City' THEN 'Man City'
        WHEN club = 'Leicester City' THEN 'Leicester' 
        WHEN club = 'Nottingham Forest' THEN 'Nottm Forest'
        ELSE club
    END AS club,
    position,  
    -- Added injury severity calculation
    CASE
        WHEN days_missed <= 7 THEN 'minor'
        WHEN days_missed > 7 AND days_missed <= 28 THEN 'moderate'
        WHEN days_missed > 28 THEN 'severe'
        ELSE NULL
    END AS injury_severity
FROM staging.pl_injuries;
	
	RAISE NOTICE 'pl_injuries table transformed and loaded successfully';

-------------------------------------------------------------------------------------------------------
	 TRUNCATE TABLE transform.pl_match
  -- Load match data (no transformations needed)
    INSERT INTO transform.pl_match
    SELECT * FROM staging.pl_match;
    
    RAISE NOTICE 'pl_match table loaded successfully';

-------------------------------------------------------------------------------------------

  -- Load top goals data with club standardization
    INSERT INTO transform.topscores_Goals (Season, Player, Club, Goals)
    SELECT 
        CONCAT(SUBSTRING(season, 3, 2), '/', SUBSTRING(season, 8, 2)) AS season,
        Player,
        CASE 
            WHEN club = 'Manchester United' THEN 'Man United'
            WHEN club = 'Manchester City' THEN 'Man City'
            WHEN club = 'Tottenham Hotspur' THEN 'Tottenham'
            WHEN club = 'Leicester City' THEN 'Leicester'
            WHEN club = 'Arsenal FC' THEN 'Arsenal'
            WHEN club = 'Liverpool FC' THEN 'Liverpool'
            ELSE club
        END AS club,
        Goals
    FROM staging.topscores_Goals;
    
    RAISE NOTICE 'topscores_Goals table transformed and loaded successfully';

----------------------------------------------------------------------------------------------------------------

	  -- Load top assists data with club standardization
    INSERT INTO transform.topscores_Assists (Season, Player, Club, Assists)
    SELECT 
        CONCAT(SUBSTRING(season, 3, 2), '/', SUBSTRING(season, 8, 2)) AS season,
        Player,
        CASE 
           WHEN club = 'Manchester City' THEN 'Man City'
            WHEN club = 'Tottenham Hotspur' THEN 'Tottenham'
            WHEN club = 'Liverpool FC' THEN 'Liverpool'
            ELSE club
        END AS club,
        Assists
    FROM staging.topscores_Assists;
    
    RAISE NOTICE 'topscores_Assists table transformed and loaded successfully';

   
END;
$$;

 
-- Execute the stored procedure
CALL transform.load_transform();