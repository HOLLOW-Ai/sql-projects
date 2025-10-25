CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

	PRINT '====================';
	PRINT 'Loading Bronze Layer';
	PRINT '====================';

	PRINT '>> Truncating Table: silver.run_log';
	TRUNCATE TABLE silver.run_log;

	PRINT '>> Loading Data into Table: silver.run_log';
	INSERT INTO silver.run_log (night, world, weapon, familiar, recorded_time, [minutes], seconds, milliseconds, outcome, killed_in, cause_of_death, specific_cause, fear, run_type)
	SELECT 
		  night
		, TRIM(world) AS world
		, TRIM(weapon) AS weapon
		, TRIM(familiar) AS familiar
		, TRIM([time]) AS recorded_time
		, CAST(SUBSTRING([time], 1, CHARINDEX(':', [time])-1) AS INT) AS [minutes]
		, CAST(SUBSTRING([time], CHARINDEX(':', [time])+1, 2) AS INT) AS seconds
		, CAST(SUBSTRING([time], CHARINDEX('.', [time])+1, 2) AS INT) AS milliseconds
		, TRIM(outcome) AS outcome
		, TRIM(killed_in) AS killed_in
		, TRIM(slain_by) AS cause_of_death
		, TRIM(specific_enemy) AS specific_cause
		, fear
		, TRIM(run_type) AS run_type
	FROM bronze.run_log;

	---------------------------------------------------------------------

	PRINT '>> Truncating Table: silver.keepsake_log';
	TRUNCATE TABLE silver.keepsake_log;

	PRINT '>> Loading Data into Table: silver.keepsake_log';
	SELECT
		  night
		, TRIM(keepsake) AS keepsake
		, keepsake_num
	FROM bronze.keepsake_log;

	---------------------------------------------------------------------

	PRINT '>> Truncating Table: silver.weapon_log';
	TRUNCATE TABLE silver.weapon_log;

	PRINT '>> Loading Data into Table: silver.weapon_log';
	SELECT
		  night
		, TRIM(weapon) AS weapon
		, TRIM(aspect) AS aspect
		, TRIM(upgrade) AS upgrade
	FROM bronze.weapon_log;

	---------------------------------------------------------------------

	PRINT '>> Truncating Table: silver.vow_log';
	TRUNCATE TABLE silver.vow_log;

	PRINT '>> Loading Data into Table: silver.vow_log';
	SELECT
		  night
		, TRIM(vow) AS vow
	FROM bronze.vow_log;

	---------------------------------------------------------------------

	PRINT '>> Truncating Table: silver.arcana_log';
	TRUNCATE TABLE silver.arcana_log;

	PRINT '>> Loading Data into Table: silver.arcana_log';
	SELECT
		  night
		, TRIM(arcana) AS arcana
		, grasp
	FROM bronze.arcana_log;

	---------------------------------------------------------------------
	PRINT '>> Truncating Table: silver.boon_log';
	TRUNCATE TABLE silver.boon_log;

	PRINT '>> Loading Data into Table: silver.boon_log';
	SELECT
		  night
		, TRIM(origin) AS origin
		, TRIM(name) AS char_name
		, TRIM(effect) AS effect
		, TRIM(boon) AS boon
	FROM bronze.boon_log;

END
