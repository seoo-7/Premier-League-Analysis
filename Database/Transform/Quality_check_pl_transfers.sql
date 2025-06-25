/*
===============================================================================
Quality Checks
=============================================================================== 
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'transform' layer
*/ 

select * from staging.pl_transfers
-- ====================================================================
-- Checking 'staging.pl_transfer' -> Identify data issues before loaded to transform layer
-- ====================================================================

-- 1.check of Data Standardization & Consistency
select
	distinct club_name
from staging.pl_transfers 

-- the club name it's not Standardization from the clubs in pl_match we should update it
-- Standardization the club name 
-- Preview transformations
SELECT distinct
    club_name AS original_name,
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
		
		--Remove 'FC' suffix 
		WHEN club_name LIKE '% FC' THEN TRIM(REPLACE(club_name, ' FC', ''))
		
		--Remove 'AFC ' prefix
        WHEN club_name LIKE 'AFC %' THEN TRIM(REPLACE(club_name, 'AFC ', ''))
		--Remove 'AFC ' suffix
		WHEN club_name like '% AFC'THEN TRIM(REPLACE(club_name, ' AFC', ''))

		--Remove 'City' suffix for clubs that need it
        WHEN club_name IN ('Manchester City','Hull City', 'Leicester City', 'Norwich City','Cardiff City','Swansea City') 
            THEN TRIM(REPLACE(club_name, ' City', ''))
			
		--Remove 'Uinted' suffix for clubs that need it
		WHEN club_name IN ('Leeds United','Newcastle United','Sheffield United','West Ham United') 
            THEN TRIM(REPLACE(club_name, ' United', ''))
        ELSE club_name
    END AS club_name
FROM staging.pl_transfers
ORDER BY club_name;
-------------------------------------------------------------------------------------------------------
--2. check of Data issue in fee and the fee_cleaned
select * 
from staging.pl_transfers
where fee = '-' and fee_cleaned is null

/*
 there is many issue in this column "fee" and fee_cleaned i will transform it :
 
    -2.1 first if the player come from yoth team such `Arsenal U18 or U21` it's "fee" should be Academic and fee_cleaned 0
	-2.2 seconf if the player come from retired or without club it's "fee" shold be free and fee_cleaned 0 
*/

-- first if the player come from yoth team such `Arsenal U18 or U21` it's "fee" should be Academic and fee_cleaned 0
select 
    club_name,
    player_name,
    age,
    position,
    club_involved_name,
	fee
from (
SELECT 
    club_name,
    player_name,
    age,
    position,
    club_involved_name,
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
            OR club_involved_name = 'Ban'  -- Special case from your data
            THEN 'Free'
        
        -- Keep original value if none of the conditions match
        ELSE fee
    END AS fee,
    
    transfer_movement,
    transfer_period,    
    league_name,
    year,
    season,
    country
FROM staging.pl_transfers )q
where fee = '-';

--seconf if the player come from retired or without club it's "fee" shold be free and fee_cleaned 0 
select 
    club_name,
    player_name,
    age,
    position,
    club_involved_name,
	fee_cleaned
from (
SELECT 
    club_name,
    player_name,
    age,
    position,
    club_involved_name,           
    transfer_movement,
    transfer_period,
    
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
        
        -- Keep original value if none of the conditions match
        ELSE fee_cleaned
    END AS fee_cleaned,
    
    league_name,
    year,
    season,
    country
FROM staging.pl_transfers 

)q
where fee_cleaned is null and 
 club_involved_name LIKE '%U18%' 
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
            OR club_involved_name = 'Ban'; 

