/* 
Stored Procedure => Load Staging Layer (Sorce -> Staging)
=========================================================================
Script Purpose:
    This stored procedure loads data into the 'Staging' schema from external CSV files. 
    It performs the following actions:
    - Truncates the Staging tables before loading data.
    - Uses the `COPY` command to load data from csv Files to Staging tables.
	
Usage Example:
    CALl  staging.load_staging ;
*/

CREATE OR REPLACE PROCEDURE staging.load_staging ()
LANGUAGE plpgsql
AS $$
BEGIN

	-- load the pl_match table to the staging layer 
    TRUNCATE TABLE staging.pl_match; 

    COPY staging.pl_match FROM 'D:\power Bi project\football analysis\dataset\pl_match.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
	
	RAISE NOTICE 'pl_match table its loaded completly successfully';
	
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	-- load the pl_transfer table to the staging layer 
    TRUNCATE TABLE staging.pl_transfers; 

    COPY staging.pl_transfers FROM 'D:\power Bi project\football analysis\dataset\pl_transfer.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
	
	RAISE NOTICE 'pl_transfers table its loaded completly successfully';
	
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	-- load the pl_injuries table to the staging layer 
    TRUNCATE TABLE staging.pl_injuries; 

    COPY staging.pl_injuries FROM 'D:\power Bi project\football analysis\dataset\pl_injuries.csv'
    WITH (FORMAT CSV, HEADER, DELIMITER ',');
	
	RAISE NOTICE 'pl_injuries table its loaded completly successfully';

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	-- load the top scores goals in the staging layer
	TRUNCATE TABLE staging.topscores_Goals ;

	COPY staging.topscores_Goals FROM 'D:\power Bi project\football analysis\dataset\Top_Scores_Goals.csv'
	WITH (FORMAT CSV , HEADER , DELIMITER ',') ; 

	RAISE NOTICE 'topscores_Goals table its loaded completly successflly';	
	
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

	--load the top scores assists in staging layer 
	TRUNCATE staging.topscores_Assists ;

	COPY staging.topscores_Assists FROM 'D:\power Bi project\football analysis\dataset\Top_Scores_Assists.csv'
	WITH (FORMAT CSV , HEADER , DELIMITER ',');

	RAISE NOTICE 'topscores_Assists table its loaded completly successflly';	

END;
$$ ; 

-- to execute the Stored Procedure
CALL staging.load_staging ()

