SELECT
	  night
	, TRIM(keepsake) AS keepsake
	, keepsake_num
FROM bronze.keepsake_log;

SELECT
	  night
	-- Ensuring no leading or trailing whitespaces
	, TRIM(weapon) AS weapon
	, TRIM(aspect) AS aspect
	, TRIM(upgrade) AS upgrade
FROM bronze.weapon_log;

SELECT *
FROM bronze.vow_log;

SELECT *
FROM bronze.arcana_log;

SELECT *
FROM bronze.boon_log;

-- Converting the time duration (in the format of mm:ss.nn) to milliseconds for the silver schema
SELECT 
	  night
	, TRIM(world) AS world
	, TRIM(weapon) AS weapon
	, TRIM(familiar) AS familiar
	  -- 'time' is a keyword in SQL, add the identifiers
	, TRIM([time]) AS [time]
	, CAST(SUBSTRING([time], 1, CHARINDEX(':', [time])-1) AS INT) AS minutes
	, CAST(SUBSTRING([time], CHARINDEX(':', [time])+1, 2) AS INT) AS seconds
	, CAST(SUBSTRING([time], CHARINDEX('.', [time])+1, 2) AS INT) AS milliseconds
	, TRIM(outcome) AS outcome
	, TRIM(killed_in) AS killed_in
	, TRIM(slain_by) AS slain_by
	, TRIM(specific_enemy) AS cause_of_death
	, fear
	, TRIM(run_type) AS run_type
FROM bronze.run_log;

SELECT *
FROM bronze.run_log;
