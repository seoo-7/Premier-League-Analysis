/* 
DDL Script to Build => Staging Layer 
this tables its :
	- pl_transfer 
	- pl_match 
	-pl_injuries
	-topscores_Goals
	-topscores_Assists
============================================================================================ 
*/

CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.pl_match;

-- pl_match table => this table contain all info about each match statistics in premier league

CREATE TABLE staging.pl_match (
    HomeTeam VARCHAR(50),
    FTHG INT,
    AwayTeam VARCHAR(50),
    FTAG INT,
    FTR CHAR(1),
    Season VARCHAR(10),
    Year INT,
    Month VARCHAR(10),
    Day INT,
    HTHG INT,
    HTAG INT,
    HTR CHAR(1),
    HomeShot INT,
    AwayShot INT,
    HSTarget INT,
    ASTarget INT,
    HomeFouls INT,
    AwayFouls INT,
    HomeCorner INT,
    AwayCorner INT,
    HomeYellowC INT,
    AwayYellowC INT,
    HomeRedC INT,
    AwayRedC INT
)
-----------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS staging.pl_transfers  

-- pl_transfers table => this table contain info about transfers happend in premier league 
CREATE TABLE staging.pl_transfers (
    club_name VARCHAR(50),
    player_name VARCHAR(50),
    age FLOAT,
    position VARCHAR(50),
    club_involved_name VARCHAR(50),
    fee VARCHAR(100),
    transfer_movement VARCHAR(10),
    transfer_period VARCHAR(10),
    fee_cleaned FLOAT,
    league_name VARCHAR(50),
    year INT,
    season VARCHAR(10),
    country VARCHAR(50)
	
)
------------------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS staging.pl_injuries

-- pl_injury table => contain about the injuries happend in premier league

CREATE TABLE staging.pl_injuries (
    player_name VARCHAR(50),
    season VARCHAR(10),
    injury VARCHAR(100),
    from_date DATE,
    until_date DATE,
    days_missed INT,
    games_missed INT,
    club VARCHAR(50),
    position VARCHAR(50)
	
)
------------------------------------------------------------------------------------

DROP TABLE IF EXISTS staging.topscores_Goals 

-- topscores_Goals table => contain info about the top scores goals in each season

CREATE TABLE staging.topscores_Goals (
    Season VARCHAR(9),       
    Player VARCHAR(50),     
    Club VARCHAR(30),       
    Goals INTEGER           
)

---------------------------------------------------------------------------------------

DROP TABLE IF EXISTS staging.topscores_Assists 

-- topscores_Assits table => contain info about the top scores goals in each season

CREATE TABLE staging.topscores_Assists (
    Season VARCHAR(9),       
    Player VARCHAR(50),      
    Club VARCHAR(30),        
    Assists INTEGER          
)